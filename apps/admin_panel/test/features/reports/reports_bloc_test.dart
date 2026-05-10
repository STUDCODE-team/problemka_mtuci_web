import 'package:admin_panel/features/reports/bloc/reports_bloc.dart';
import 'package:admin_panel/features/reports/models/report.dart';
import 'package:admin_panel/features/reports/repositories/reports_repository.dart';
import 'package:admin_panel/features/users/models/user_info.dart';
import 'package:admin_panel/features/users/repositories/users_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Fake репозитории
// ---------------------------------------------------------------------------

class _FakeReportsRepository implements ReportsRepository {
  Future<List<ReportListItem>> Function({ReportStatus? status})? onGetReports;
  Future<ReportDetail> Function(String id)? onGetReportById;
  Future<ReportDetail> Function(String id, ReportStatus status)? onChangeStatus;
  Future<ReportDetail> Function(String id, ReportStatus status)? onForceChangeStatus;
  Future<List<ReportComment>> Function(String id)? onGetComments;
  Future<ReportComment> Function(String id, String text)? onAddComment;
  Future<List<StatusHistoryEntry>> Function(String id)? onGetStatusHistory;
  Future<void> Function(String id)? onDeleteReport;

  _FakeReportsRepository({
    this.onGetReports,
    this.onGetReportById,
    this.onChangeStatus,
    this.onForceChangeStatus,
    this.onGetComments,
    this.onAddComment,
    this.onGetStatusHistory,
    this.onDeleteReport,
  });

  @override
  Future<List<ReportListItem>> getReports({ReportStatus? status, int limit = 50, int offset = 0}) =>
      onGetReports?.call(status: status) ?? Future.value([]);

  @override
  Future<ReportDetail> getReportById(String id) =>
      onGetReportById?.call(id) ?? Future.error(StateError('not configured'));

  @override
  Future<ReportDetail> changeStatus(String id, ReportStatus status) =>
      onChangeStatus?.call(id, status) ?? Future.error(StateError('not configured'));

  @override
  Future<ReportDetail> forceChangeStatus(String id, ReportStatus status) =>
      onForceChangeStatus?.call(id, status) ?? Future.error(StateError('not configured'));

  @override
  Future<List<ReportComment>> getComments(String reportId) =>
      onGetComments?.call(reportId) ?? Future.value([]);

  @override
  Future<ReportComment> addComment(String reportId, String text) =>
      onAddComment?.call(reportId, text) ?? Future.error(StateError('not configured'));

  @override
  Future<List<StatusHistoryEntry>> getStatusHistory(String reportId) =>
      onGetStatusHistory?.call(reportId) ?? Future.value([]);

  @override
  Future<void> deleteReport(String id) => onDeleteReport?.call(id) ?? Future.value();
}

class _FakeUsersRepository implements UsersRepository {
  Future<List<UserInfo>> Function()? onGetUsers;
  Future<UserInfo> Function(String id)? onGetUserById;
  Future<UserInfo> Function(String id, String role)? onSetRole;

  // ignore: unused_element_parameter
  _FakeUsersRepository({this.onGetUsers, this.onGetUserById, this.onSetRole});

  @override
  Future<List<UserInfo>> getUsers() => onGetUsers?.call() ?? Future.value([]);

  @override
  Future<UserInfo> getUserById(String userId) =>
      onGetUserById?.call(userId) ?? Future.error(StateError('not configured'));

  @override
  Future<UserInfo> setRole(String userId, String role) =>
      onSetRole?.call(userId, role) ?? Future.error(StateError('not configured'));
}

// ---------------------------------------------------------------------------
// Фабрики тестовых данных
// ---------------------------------------------------------------------------

ReportListItem _makeListItem({String id = 'r-1', ReportStatus status = ReportStatus.newReport}) =>
    ReportListItem(
      id: id,
      title: 'Тестовая заявка',
      location: 'Корпус А',
      category: 'electrical',
      priority: 'medium',
      status: status,
      createdAt: DateTime(2024, 1, 1),
    );

ReportDetail _makeDetail({
  String id = 'r-1',
  String reporterId = 'u-1',
  ReportStatus status = ReportStatus.newReport,
}) => ReportDetail(
  id: id,
  title: 'Тестовая заявка',
  description: 'Описание',
  location: 'Корпус А',
  category: 'electrical',
  priority: 'medium',
  type: 'report',
  status: status,
  reporterId: reporterId,
  createdAt: DateTime(2024, 1, 1),
);

UserInfo _makeUser({String id = 'u-1', String role = 'user'}) => UserInfo(
  id: id,
  email: 'user@mtuci.ru',
  role: role,
  isActive: true,
  createdAt: DateTime(2024, 1, 1),
);

DioException _dioError({Map<String, dynamic>? data}) => DioException(
  requestOptions: RequestOptions(path: ''),
  response: data != null
      ? Response(
          requestOptions: RequestOptions(path: ''),
          data: data,
          statusCode: 400,
        )
      : null,
);

// ---------------------------------------------------------------------------
// Тесты
// ---------------------------------------------------------------------------

void main() {
  group('ReportsBloc (admin) — LoadReports', () {
    test('успешная загрузка: [ReportsLoading, ReportsLoaded]', () async {
      final items = [_makeListItem(id: 'r-1'), _makeListItem(id: 'r-2')];

      final bloc = ReportsBloc(
        repository: _FakeReportsRepository(onGetReports: ({status}) async => items),
      );

      final future = expectLater(
        bloc.stream,
        emitsInOrder([isA<ReportsLoading>(), isA<ReportsLoaded>()]),
      );

      bloc.add(LoadReports());
      await future;

      expect((bloc.state as ReportsLoaded).reports.length, 2);
      await bloc.close();
    });

    test('фильтр по статусу передаётся в репозиторий', () async {
      ReportStatus? capturedStatus;

      final bloc = ReportsBloc(
        repository: _FakeReportsRepository(
          onGetReports: ({status}) async {
            capturedStatus = status;
            return [];
          },
        ),
      );

      final future = expectLater(
        bloc.stream,
        emitsInOrder([isA<ReportsLoading>(), isA<ReportsLoaded>()]),
      );

      bloc.add(LoadReports(status: ReportStatus.inProgress));
      await future;

      expect(capturedStatus, ReportStatus.inProgress);
      expect((bloc.state as ReportsLoaded).activeFilter, ReportStatus.inProgress);
      await bloc.close();
    });

    test('ошибка: [ReportsLoading, ReportsError]', () async {
      final bloc = ReportsBloc(
        repository: _FakeReportsRepository(
          onGetReports: ({status}) => Future.error(_dioError(data: {'detail': 'Forbidden'})),
        ),
      );

      final future = expectLater(
        bloc.stream,
        emitsInOrder([isA<ReportsLoading>(), isA<ReportsError>()]),
      );

      bloc.add(LoadReports());
      await future;

      expect((bloc.state as ReportsError).message, 'Forbidden');
      await bloc.close();
    });
  });

  group('ReportsBloc (admin) — LoadAdminReportDetail', () {
    test('успешная загрузка деталей: [AdminDetailLoading, AdminReportDetailLoaded]', () async {
      final bloc = ReportsBloc(
        repository: _FakeReportsRepository(
          onGetReportById: (_) async => _makeDetail(),
          onGetComments: (_) async => [],
          onGetStatusHistory: (_) async => [],
        ),
      );

      final future = expectLater(
        bloc.stream,
        emitsInOrder([isA<AdminDetailLoading>(), isA<AdminReportDetailLoaded>()]),
      );

      bloc.add(LoadAdminReportDetail('r-1'));
      await future;

      expect((bloc.state as AdminReportDetailLoaded).report.id, 'r-1');
      await bloc.close();
    });

    test('репортёр загружается при наличии usersRepository', () async {
      final reporter = _makeUser(id: 'u-5');

      final bloc = ReportsBloc(
        repository: _FakeReportsRepository(
          onGetReportById: (_) async => _makeDetail(reporterId: 'u-5'),
          onGetComments: (_) async => [],
          onGetStatusHistory: (_) async => [],
        ),
        usersRepository: _FakeUsersRepository(onGetUserById: (_) async => reporter),
      );

      final future = expectLater(
        bloc.stream,
        emitsInOrder([isA<AdminDetailLoading>(), isA<AdminReportDetailLoaded>()]),
      );

      bloc.add(LoadAdminReportDetail('r-1'));
      await future;

      expect((bloc.state as AdminReportDetailLoaded).reporter?.id, 'u-5');
      await bloc.close();
    });

    test('ошибка загрузки репортёра игнорируется — reporter равен null', () async {
      final bloc = ReportsBloc(
        repository: _FakeReportsRepository(
          onGetReportById: (_) async => _makeDetail(),
          onGetComments: (_) async => [],
          onGetStatusHistory: (_) async => [],
        ),
        usersRepository: _FakeUsersRepository(
          onGetUserById: (_) => Future.error(Exception('Not found')),
        ),
      );

      final future = expectLater(
        bloc.stream,
        emitsInOrder([isA<AdminDetailLoading>(), isA<AdminReportDetailLoaded>()]),
      );

      bloc.add(LoadAdminReportDetail('r-1'));
      await future;

      expect((bloc.state as AdminReportDetailLoaded).reporter, isNull);
      await bloc.close();
    });

    test('ошибка загрузки деталей: [AdminDetailLoading, AdminDetailError]', () async {
      final bloc = ReportsBloc(
        repository: _FakeReportsRepository(
          onGetReportById: (_) => Future.error(_dioError(data: {'detail': 'Not found'})),
          onGetComments: (_) async => [],
          onGetStatusHistory: (_) async => [],
        ),
      );

      final future = expectLater(
        bloc.stream,
        emitsInOrder([isA<AdminDetailLoading>(), isA<AdminDetailError>()]),
      );

      bloc.add(LoadAdminReportDetail('r-99'));
      await future;

      expect((bloc.state as AdminDetailError).message, 'Not found');
      await bloc.close();
    });
  });

  group('ReportsBloc (admin) — ChangeReportStatus', () {
    test('смена статуса: [ReportStatusChanged, ReportsLoading, ReportsLoaded]', () async {
      final updated = _makeDetail(status: ReportStatus.inProgress);

      final bloc = ReportsBloc(
        repository: _FakeReportsRepository(
          onChangeStatus: (_, __) async => updated,
          onGetReports: ({status}) async => [],
        ),
      );

      final future = expectLater(
        bloc.stream,
        emitsInOrder([isA<ReportStatusChanged>(), isA<ReportsLoading>(), isA<ReportsLoaded>()]),
      );

      bloc.add(ChangeReportStatus(reportId: 'r-1', status: ReportStatus.inProgress));
      await future;
      await bloc.close();
    });

    test('ReportStatusChanged содержит обновлённый отчёт', () async {
      final updated = _makeDetail(id: 'r-1', status: ReportStatus.inProgress);

      final bloc = ReportsBloc(
        repository: _FakeReportsRepository(
          onChangeStatus: (_, __) async => updated,
          onGetReports: ({status}) async => [],
        ),
      );

      bloc.add(ChangeReportStatus(reportId: 'r-1', status: ReportStatus.inProgress));

      final state =
          await bloc.stream.firstWhere((s) => s is ReportStatusChanged) as ReportStatusChanged;

      expect(state.report.status, ReportStatus.inProgress);
      await bloc.close();
    });
  });

  group('ReportsBloc (admin) — DeleteReport', () {
    test('успешное удаление: [ReportDeleted]', () async {
      final bloc = ReportsBloc(repository: _FakeReportsRepository(onDeleteReport: (_) async {}));

      final future = expectLater(bloc.stream, emits(isA<ReportDeleted>()));

      bloc.add(DeleteReport('r-1'));
      await future;
      await bloc.close();
    });

    test('ошибка удаления: [ReportDeleteError]', () async {
      final bloc = ReportsBloc(
        repository: _FakeReportsRepository(
          onDeleteReport: (_) => Future.error(_dioError(data: {'detail': 'Cannot delete'})),
        ),
      );

      final future = expectLater(bloc.stream, emits(isA<ReportDeleteError>()));

      bloc.add(DeleteReport('r-1'));
      await future;

      expect((bloc.state as ReportDeleteError).message, 'Cannot delete');
      await bloc.close();
    });
  });

  group('ReportsBloc (admin) — ForceChangeStatus', () {
    test('принудительная смена статуса перезагружает детали', () async {
      final bloc = ReportsBloc(
        repository: _FakeReportsRepository(
          onForceChangeStatus: (_, __) async => _makeDetail(),
          onGetReportById: (_) async => _makeDetail(status: ReportStatus.resolved),
          onGetComments: (_) async => [],
          onGetStatusHistory: (_) async => [],
        ),
      );

      final future = expectLater(
        bloc.stream,
        emitsInOrder([isA<AdminDetailLoading>(), isA<AdminReportDetailLoaded>()]),
      );

      bloc.add(ForceChangeStatus(reportId: 'r-1', status: ReportStatus.resolved));
      await future;
      await bloc.close();
    });
  });

  group('ReportsBloc (admin) — AddAdminComment', () {
    test('добавление комментария перезагружает детали', () async {
      final bloc = ReportsBloc(
        repository: _FakeReportsRepository(
          onAddComment: (_, __) async => ReportComment(
            id: 'c-1',
            reportId: 'r-1',
            authorId: 'admin-1',
            text: 'Принято',
            createdAt: DateTime(2024),
          ),
          onGetReportById: (_) async => _makeDetail(),
          onGetComments: (_) async => [],
          onGetStatusHistory: (_) async => [],
        ),
      );

      final future = expectLater(
        bloc.stream,
        emitsInOrder([isA<AdminDetailLoading>(), isA<AdminReportDetailLoaded>()]),
      );

      bloc.add(AddAdminComment(reportId: 'r-1', text: 'Текст комментария'));
      await future;
      await bloc.close();
    });
  });
}
