import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:client_app/core/api/api_client.dart';
import 'package:client_app/core/auth/token_repository.dart';
import 'package:client_app/features/notifications/src/notifications_repository.dart';

class _MockInterceptor extends Interceptor {
  Response<dynamic> Function(RequestOptions)? _resolver;
  DioException Function(RequestOptions)? _errorResolver;

  void when(Response<dynamic> Function(RequestOptions) fn) => _resolver = fn;
  void whenError(DioException Function(RequestOptions) fn) => _errorResolver = fn;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_errorResolver != null) {
      handler.reject(_errorResolver!(options));
    } else if (_resolver != null) {
      handler.resolve(_resolver!(options));
    } else {
      handler.next(options);
    }
  }
}

final _notificationJson = {
  'id': 'n1',
  'reporter_id': 'u1',
  'report_id': 'r1',
  'report_title': 'Broken light',
  'old_status': 'new',
  'new_status': 'in_progress',
  'is_read': false,
  'created_at': '2024-01-01T00:00:00.000Z',
};

void main() {
  late _MockInterceptor mock;
  late NotificationsRepository repo;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    final tokenRepo = TokenRepository();
    final apiClient = ApiClient(
      baseUrl: 'http://test',
      tokenRepository: tokenRepo,
      onSessionExpired: () {},
      enableTalkerLogs: false,
    );
    mock = _MockInterceptor();
    apiClient.dio.interceptors.insert(0, mock);
    repo = NotificationsRepository(apiClient: apiClient);
  });

  group('fetchMyNotifications', () {
    test('returns list of AppNotification parsed from JSON', () async {
      mock.when((opts) => Response(
            requestOptions: opts,
            data: [_notificationJson],
            statusCode: 200,
          ));

      final notifications = await repo.fetchMyNotifications();

      expect(notifications, hasLength(1));
      expect(notifications.first.id, 'n1');
      expect(notifications.first.reportId, 'r1');
      expect(notifications.first.reportTitle, 'Broken light');
      expect(notifications.first.isRead, isFalse);
    });

    test('returns empty list when API returns []', () async {
      mock.when((opts) => Response(requestOptions: opts, data: [], statusCode: 200));
      expect(await repo.fetchMyNotifications(), isEmpty);
    });

    test('makes GET to /api/reports/notifications/my', () async {
      late String requestPath;
      mock.when((opts) {
        requestPath = opts.path;
        return Response(requestOptions: opts, data: [], statusCode: 200);
      });

      await repo.fetchMyNotifications();

      expect(requestPath, '/api/reports/notifications/my');
    });

    test('parses multiple notifications', () async {
      final second = Map<String, dynamic>.from(_notificationJson)
        ..['id'] = 'n2'
        ..['is_read'] = true;
      mock.when((opts) => Response(
            requestOptions: opts,
            data: [_notificationJson, second],
            statusCode: 200,
          ));

      final notifications = await repo.fetchMyNotifications();

      expect(notifications, hasLength(2));
      expect(notifications[0].isRead, isFalse);
      expect(notifications[1].isRead, isTrue);
    });

    test('throws DioException on server error', () async {
      mock.whenError((opts) => DioException(
            requestOptions: opts,
            type: DioExceptionType.badResponse,
            response: Response(requestOptions: opts, statusCode: 401),
          ));

      expect(() => repo.fetchMyNotifications(), throwsA(isA<DioException>()));
    });
  });

  group('markRead', () {
    test('makes PATCH to correct path', () async {
      late String requestPath;
      late String requestMethod;
      mock.when((opts) {
        requestPath = opts.path;
        requestMethod = opts.method;
        return Response(requestOptions: opts, data: null, statusCode: 204);
      });

      await repo.markRead('n1');

      expect(requestPath, '/api/reports/notifications/n1/read');
      expect(requestMethod, 'PATCH');
    });

    test('completes without error on success', () async {
      mock.when((opts) => Response(requestOptions: opts, data: null, statusCode: 204));
      await expectLater(repo.markRead('n1'), completes);
    });

    test('throws DioException when notification not found', () async {
      mock.whenError((opts) => DioException(
            requestOptions: opts,
            type: DioExceptionType.badResponse,
            response: Response(requestOptions: opts, statusCode: 404),
          ));

      expect(() => repo.markRead('unknown'), throwsA(isA<DioException>()));
    });
  });

  group('markAllRead', () {
    test('makes POST to /api/reports/notifications/read-all', () async {
      late String requestPath;
      late String requestMethod;
      mock.when((opts) {
        requestPath = opts.path;
        requestMethod = opts.method;
        return Response(requestOptions: opts, data: null, statusCode: 204);
      });

      await repo.markAllRead();

      expect(requestPath, '/api/reports/notifications/read-all');
      expect(requestMethod, 'POST');
    });

    test('completes without error on success', () async {
      mock.when((opts) => Response(requestOptions: opts, data: null, statusCode: 204));
      await expectLater(repo.markAllRead(), completes);
    });
  });
}
