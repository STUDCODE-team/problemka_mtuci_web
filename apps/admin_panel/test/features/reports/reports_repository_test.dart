import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:admin_panel/core/api/api_client.dart';
import 'package:admin_panel/core/auth/token_repository.dart';
import 'package:admin_panel/features/reports/models/report.dart';
import 'package:admin_panel/features/reports/repositories/reports_repository.dart';

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

final _listItemJson = {
  'id': 'r1',
  'title': 'Broken light',
  'location': 'Room 101',
  'category': 'electrical',
  'priority': 'medium',
  'status': 'new',
  'created_at': '2024-01-01T00:00:00.000Z',
};

final _detailJson = {
  'id': 'r1',
  'title': 'Broken light',
  'description': 'The ceiling light is broken',
  'location': 'Room 101',
  'room': '101',
  'category': 'electrical',
  'priority': 'medium',
  'type': 'report',
  'status': 'new',
  'reporter_id': 'u1',
  'photo_url': null,
  'created_at': '2024-01-01T00:00:00.000Z',
  'updated_at': null,
};

final _commentJson = {
  'id': 'c1',
  'report_id': 'r1',
  'author_id': 'u1',
  'text': 'Looking into it',
  'created_at': '2024-01-01T00:00:00.000Z',
};

final _historyJson = {
  'id': 'h1',
  'report_id': 'r1',
  'old_status': 'new',
  'new_status': 'in_progress',
  'changed_by': 'u1',
  'changed_at': '2024-01-01T00:00:00.000Z',
};

void main() {
  late _MockInterceptor mock;
  late ReportsRepository repo;

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
    repo = ReportsRepository(apiClient: apiClient);
  });

  group('getReports', () {
    test('returns list of ReportListItem parsed from JSON', () async {
      mock.when((opts) => Response(
            requestOptions: opts,
            data: [_listItemJson],
            statusCode: 200,
          ));

      final reports = await repo.getReports();

      expect(reports, hasLength(1));
      expect(reports.first.id, 'r1');
      expect(reports.first.title, 'Broken light');
      expect(reports.first.status, ReportStatus.newReport);
    });

    test('returns empty list when API returns []', () async {
      mock.when((opts) => Response(requestOptions: opts, data: [], statusCode: 200));

      final reports = await repo.getReports();

      expect(reports, isEmpty);
    });

    test('passes status filter as query parameter', () async {
      late Map<String, dynamic> queryParams;
      mock.when((opts) {
        queryParams = opts.queryParameters;
        return Response(requestOptions: opts, data: [], statusCode: 200);
      });

      await repo.getReports(status: ReportStatus.inProgress);

      expect(queryParams['status'], 'in_progress');
    });

    test('passes limit and offset as query parameters', () async {
      late Map<String, dynamic> queryParams;
      mock.when((opts) {
        queryParams = opts.queryParameters;
        return Response(requestOptions: opts, data: [], statusCode: 200);
      });

      await repo.getReports(limit: 10, offset: 20);

      expect(queryParams['limit'], 10);
      expect(queryParams['offset'], 20);
    });

    test('does not include status in params when not specified', () async {
      late Map<String, dynamic> queryParams;
      mock.when((opts) {
        queryParams = opts.queryParameters;
        return Response(requestOptions: opts, data: [], statusCode: 200);
      });

      await repo.getReports();

      expect(queryParams.containsKey('status'), isFalse);
    });

    test('throws DioException on server error', () async {
      mock.whenError((opts) => DioException(
            requestOptions: opts,
            type: DioExceptionType.badResponse,
            response: Response(requestOptions: opts, statusCode: 500),
          ));

      expect(() => repo.getReports(), throwsA(isA<DioException>()));
    });
  });

  group('getReportById', () {
    test('returns ReportDetail parsed from JSON', () async {
      mock.when((opts) => Response(
            requestOptions: opts,
            data: _detailJson,
            statusCode: 200,
          ));

      final report = await repo.getReportById('r1');

      expect(report.id, 'r1');
      expect(report.description, 'The ceiling light is broken');
      expect(report.room, '101');
      expect(report.status, ReportStatus.newReport);
    });

    test('makes GET to correct path', () async {
      late String requestPath;
      mock.when((opts) {
        requestPath = opts.path;
        return Response(requestOptions: opts, data: _detailJson, statusCode: 200);
      });

      await repo.getReportById('abc-123');

      expect(requestPath, '/api/reports/abc-123');
    });
  });

  group('changeStatus', () {
    test('sends status apiValue in PATCH body', () async {
      late Map<String, dynamic> sentBody;
      mock.when((opts) {
        sentBody = opts.data as Map<String, dynamic>;
        return Response(requestOptions: opts, data: _detailJson, statusCode: 200);
      });

      await repo.changeStatus('r1', ReportStatus.inProgress);

      expect(sentBody['status'], 'in_progress');
    });

    test('returns updated ReportDetail', () async {
      final updatedDetail = Map<String, dynamic>.from(_detailJson)
        ..['status'] = 'in_progress';
      mock.when((opts) => Response(
            requestOptions: opts,
            data: updatedDetail,
            statusCode: 200,
          ));

      final result = await repo.changeStatus('r1', ReportStatus.inProgress);

      expect(result.status, ReportStatus.inProgress);
    });

    test('makes PATCH to correct path', () async {
      late String requestPath;
      mock.when((opts) {
        requestPath = opts.path;
        return Response(requestOptions: opts, data: _detailJson, statusCode: 200);
      });

      await repo.changeStatus('r1', ReportStatus.resolved);

      expect(requestPath, '/api/reports/r1/status');
    });
  });

  group('forceChangeStatus', () {
    test('makes PATCH to /status/force path', () async {
      late String requestPath;
      mock.when((opts) {
        requestPath = opts.path;
        return Response(requestOptions: opts, data: _detailJson, statusCode: 200);
      });

      await repo.forceChangeStatus('r1', ReportStatus.resolved);

      expect(requestPath, '/api/reports/r1/status/force');
    });
  });

  group('getComments', () {
    test('returns list of ReportComment', () async {
      mock.when((opts) => Response(
            requestOptions: opts,
            data: [_commentJson],
            statusCode: 200,
          ));

      final comments = await repo.getComments('r1');

      expect(comments, hasLength(1));
      expect(comments.first.id, 'c1');
      expect(comments.first.text, 'Looking into it');
    });
  });

  group('addComment', () {
    test('sends text in POST body and returns created comment', () async {
      late Map<String, dynamic> sentBody;
      mock.when((opts) {
        sentBody = opts.data as Map<String, dynamic>;
        return Response(requestOptions: opts, data: _commentJson, statusCode: 200);
      });

      final comment = await repo.addComment('r1', 'Looking into it');

      expect(sentBody['text'], 'Looking into it');
      expect(comment.text, 'Looking into it');
    });

    test('makes POST to correct path', () async {
      late String requestPath;
      mock.when((opts) {
        requestPath = opts.path;
        return Response(requestOptions: opts, data: _commentJson, statusCode: 200);
      });

      await repo.addComment('r1', 'text');

      expect(requestPath, '/api/reports/r1/comments');
    });
  });

  group('getStatusHistory', () {
    test('returns list of StatusHistoryEntry', () async {
      mock.when((opts) => Response(
            requestOptions: opts,
            data: [_historyJson],
            statusCode: 200,
          ));

      final history = await repo.getStatusHistory('r1');

      expect(history, hasLength(1));
      expect(history.first.oldStatus, 'new');
      expect(history.first.newStatus, 'in_progress');
    });
  });

  group('deleteReport', () {
    test('makes DELETE to correct path', () async {
      late String requestPath;
      late String requestMethod;
      mock.when((opts) {
        requestPath = opts.path;
        requestMethod = opts.method;
        return Response(requestOptions: opts, data: null, statusCode: 204);
      });

      await repo.deleteReport('r1');

      expect(requestPath, '/api/reports/r1');
      expect(requestMethod, 'DELETE');
    });
  });
}
