import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:client_app/features/notifications/src/models/notification.dart';
import 'package:client_app/features/notifications/src/notifications_repository.dart';
import 'package:client_app/features/notifications/src/bloc/notifications_bloc.dart';
import 'package:client_app/features/reports/src/models/report.dart';

class _FakeNotificationsRepository implements NotificationsRepository {
  final Future<List<AppNotification>> Function()? _fetchMyNotifications;
  final Future<void> Function(String id)? _markRead;
  final Future<void> Function()? _markAllRead;

  _FakeNotificationsRepository({
    Future<List<AppNotification>> Function()? fetchMyNotifications,
    Future<void> Function(String)? markRead,
    Future<void> Function()? markAllRead,
  })  : _fetchMyNotifications = fetchMyNotifications,
        _markRead = markRead,
        _markAllRead = markAllRead;

  @override
  Future<List<AppNotification>> fetchMyNotifications() =>
      _fetchMyNotifications?.call() ?? Future.value([]);

  @override
  Future<void> markRead(String notificationId) =>
      _markRead?.call(notificationId) ?? Future.value();

  @override
  Future<void> markAllRead() => _markAllRead?.call() ?? Future.value();
}

AppNotification _makeNotification({String id = 'n-1', bool isRead = false}) {
  return AppNotification(
    id: id,
    reporterId: 'u-1',
    reportId: 'r-1',
    reportTitle: 'Тест',
    oldStatus: ReportStatus.newReport,
    newStatus: ReportStatus.inProgress,
    isRead: isRead,
    createdAt: DateTime(2024, 1, 1),
  );
}

void main() {
  group('NotificationsLoaded — unreadCount', () {
    test('считает непрочитанные уведомления', () {
      final state = NotificationsLoaded([
        _makeNotification(id: 'n-1', isRead: false),
        _makeNotification(id: 'n-2', isRead: true),
        _makeNotification(id: 'n-3', isRead: false),
      ]);
      expect(state.unreadCount, 2);
    });

    test('возвращает 0 если все прочитаны', () {
      final state = NotificationsLoaded([
        _makeNotification(id: 'n-1', isRead: true),
        _makeNotification(id: 'n-2', isRead: true),
      ]);
      expect(state.unreadCount, 0);
    });

    test('возвращает 0 для пустого списка', () {
      expect(NotificationsLoaded([]).unreadCount, 0);
    });
  });

  group('NotificationsBloc — загрузка при старте', () {
    test('загружает уведомления при создании блока', () async {
      final notifications = [_makeNotification()];

      final bloc = NotificationsBloc(
        repository: _FakeNotificationsRepository(
          fetchMyNotifications: () async => notifications,
        ),
      );

      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<NotificationsLoaded>()
              .having((s) => s.notifications.length, 'length', 1),
        ),
      );

      await bloc.close();
    });

    test('сетевая ошибка при загрузке: состояние остаётся NotificationsInitial', () async {
      final bloc = NotificationsBloc(
        repository: _FakeNotificationsRepository(
          fetchMyNotifications: () =>
              Future.error(DioException(requestOptions: RequestOptions(path: ''))),
        ),
      );

      // Ошибка при начальной загрузке игнорируется, состояние не меняется
      await Future.delayed(const Duration(milliseconds: 50));
      expect(bloc.state, isA<NotificationsInitial>());

      await bloc.close();
    });
  });

  group('NotificationsBloc — MarkNotificationRead', () {
    test('оптимистично помечает уведомление прочитанным', () async {
      final bloc = NotificationsBloc(
        repository: _FakeNotificationsRepository(
          fetchMyNotifications: () async => [_makeNotification(isRead: false)],
          markRead: (_) async {},
        ),
      );

      // Дождёмся начальной загрузки
      await bloc.stream.firstWhere((s) => s is NotificationsLoaded);

      final future = expectLater(
        bloc.stream,
        emits(
          isA<NotificationsLoaded>().having(
            (s) => s.notifications.first.isRead,
            'isRead после оптимистичного обновления',
            isTrue,
          ),
        ),
      );

      bloc.add(MarkNotificationRead('n-1'));
      await future;
      await bloc.close();
    });

    test('unreadCount уменьшается после прочтения', () async {
      final bloc = NotificationsBloc(
        repository: _FakeNotificationsRepository(
          fetchMyNotifications: () async => [
            _makeNotification(id: 'n-1', isRead: false),
            _makeNotification(id: 'n-2', isRead: false),
          ],
          markRead: (_) async {},
        ),
      );

      await bloc.stream.firstWhere((s) => s is NotificationsLoaded);

      bloc.add(MarkNotificationRead('n-1'));

      final nextState = await bloc.stream.firstWhere((s) => s is NotificationsLoaded)
          as NotificationsLoaded;

      expect(nextState.unreadCount, 1);
      await bloc.close();
    });
  });

  group('NotificationsBloc — MarkAllNotificationsRead', () {
    test('оптимистично помечает все уведомления прочитанными', () async {
      final bloc = NotificationsBloc(
        repository: _FakeNotificationsRepository(
          fetchMyNotifications: () async => [
            _makeNotification(id: 'n-1', isRead: false),
            _makeNotification(id: 'n-2', isRead: false),
          ],
          markAllRead: () async {},
        ),
      );

      await bloc.stream.firstWhere((s) => s is NotificationsLoaded);

      final future = expectLater(
        bloc.stream,
        emits(
          isA<NotificationsLoaded>().having(
            (s) => s.notifications.every((n) => n.isRead),
            'все прочитаны',
            isTrue,
          ),
        ),
      );

      bloc.add(MarkAllNotificationsRead());
      await future;
      await bloc.close();
    });

    test('unreadCount становится 0 после прочтения всех', () async {
      final bloc = NotificationsBloc(
        repository: _FakeNotificationsRepository(
          fetchMyNotifications: () async => [
            _makeNotification(id: 'n-1', isRead: false),
            _makeNotification(id: 'n-2', isRead: true),
            _makeNotification(id: 'n-3', isRead: false),
          ],
          markAllRead: () async {},
        ),
      );

      await bloc.stream.firstWhere((s) => s is NotificationsLoaded);

      bloc.add(MarkAllNotificationsRead());

      final nextState = await bloc.stream.firstWhere((s) => s is NotificationsLoaded)
          as NotificationsLoaded;

      expect(nextState.unreadCount, 0);
      await bloc.close();
    });
  });
}
