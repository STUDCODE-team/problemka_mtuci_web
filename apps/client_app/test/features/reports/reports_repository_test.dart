import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:client_app/core/api/api_client.dart';
import 'package:client_app/core/auth/token_repository.dart';
import 'package:client_app/features/reports/src/models/report.dart';
import 'package:client_app/features/reports/src/reports_repository.dart';

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

final _listJson = {
  'id': 'r1',
  'title': 'Broken light',
  'location': 'Room 101',
  'category': 'electrical',
  'priority': 'medium',
  'status': 'new',
  'created_at': '2024-01-01T00:00:00.000Z',
};

final _fullJson = {
  'id': 'r1',
  'title': 'Broken light',
  'description': 'The ceiling light does not work',
  'location': 'Room 101',
  'room': '101A',
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
  'text': 'We will fix it tomorrow',
  'created_at': '2024-01-02T00:00:00.000Z',
};

final _historyJson = {
  'id': 'h1',
  'report_id': 'r1',
  'old_status': 'new',
  'new_status': 'in_progress',
  'changed_by': 'u2',
  'changed_at': '2024-01-02T00:00:00.000Z',
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

  group('fetchMyReports', () {
    test('returns list of Report from list JSON', () async {
      mock.when((opts) => Response(
            requestOptions: opts,
            data: [_listJson],
            statusCode: 200,
          ));

      final reports = await repo.fetchMyReports();

      expect(reports, hasLength(1));
      expect(reports.first.id, 'r1');
      expect(reports.first.status, ReportStatus.newReport);
    });

    test('returns empty list when API returns []', () async {
      mock.when((opts) => Response(requestOptions: opts, data: [], statusCode: 200));
      expect(await repo.fetchMyReports(), isEmpty);
    });

    test('passes status filter as query parameter', () async {
      late Map<String, dynamic> params;
      mock.when((opts) {
        params = opts.queryParameters;
        return Response(requestOptions: opts, data: [], statusCode: 200);
      });

      await repo.fetchMyReports(status: ReportStatus.resolved);

      expect(params['status'], 'resolved');
    });

    test('does not include status param when not specified', () async {
      late Map<String, dynamic> params;
      mock.when((opts) {
        params = opts.queryParameters;
        return Response(requestOptions: opts, data: [], statusCode: 200);
      });

      await repo.fetchMyReports();

      expect(params.containsKey('status'), isFalse);
    });

    test('makes GET to /api/reports/my', () async {
      late String requestPath;
      mock.when((opts) {
        requestPath = opts.path;
        return Response(requestOptions: opts, data: [], statusCode: 200);
      });

      await repo.fetchMyReports();

      expect(requestPath, '/api/reports/my');
    });
  });

  group('getById', () {
    test('returns full Report from detail JSON', () async {
      mock.when((opts) => Response(
            requestOptions: opts,
            data: _fullJson,
            statusCode: 200,
          ));

      final report = await repo.getById('r1');

      expect(report.id, 'r1');
      expect(report.description, 'The ceiling light does not work');
      expect(report.room, '101A');
      expect(report.reporterId, 'u1');
    });

    test('makes GET to correct path', () async {
      late String requestPath;
      mock.when((opts) {
        requestPath = opts.path;
        return Response(requestOptions: opts, data: _fullJson, statusCode: 200);
      });

      await repo.getById('xyz-456');

      expect(requestPath, '/api/reports/xyz-456');
    });
  });

  group('createReport', () {
    test('sends all fields in POST body', () async {
      late Map<String, dynamic> sentBody;
      mock.when((opts) {
        sentBody = opts.data as Map<String, dynamic>;
        return Response(requestOptions: opts, data: _fullJson, statusCode: 201);
      });

      await repo.createReport(
        title: 'Broken light',
        description: 'The ceiling light does not work',
        location: 'Room 101',
        room: '101A',
        category: 'electrical',
      );

      expect(sentBody['title'], 'Broken light');
      expect(sentBody['description'], 'The ceiling light does not work');
      expect(sentBody['location'], 'Room 101');
      expect(sentBody['room'], '101A');
      expect(sentBody['category'], 'electrical');
      expect(sentBody['priority'], 'medium');
      expect(sentBody['type'], 'report');
    });

    test('returns created Report', () async {
      mock.when((opts) => Response(requestOptions: opts, data: _fullJson, statusCode: 201));

      final report = await repo.createReport(
        title: 'Broken light',
        description: 'desc',
        location: 'Room 101',
        category: 'electrical',
      );

      expect(report.id, 'r1');
      expect(report.title, 'Broken light');
    });

    test('makes POST to /api/reports/', () async {
      late String requestPath;
      mock.when((opts) {
        requestPath = opts.path;
        return Response(requestOptions: opts, data: _fullJson, statusCode: 201);
      });

      await repo.createReport(
        title: 'T', description: 'D', location: 'L', category: 'other',
      );

      expect(requestPath, '/api/reports/');
    });

    test('throws DioException on validation error', () async {
      mock.whenError((opts) => DioException(
            requestOptions: opts,
            response: Response(
              requestOptions: opts,
              statusCode: 422,
              data: {'errors': ['title: This field is required']},
            ),
            type: DioExceptionType.badResponse,
          ));

      expect(
        () => repo.createReport(
          title: '', description: '', location: '', category: '',
        ),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('updateReport', () {
    test('sends only provided fields in PATCH body', () async {
      late Map<String, dynamic> sentBody;
      mock.when((opts) {
        sentBody = opts.data as Map<String, dynamic>;
        return Response(requestOptions: opts, data: _fullJson, statusCode: 200);
      });

      await repo.updateReport(reportId: 'r1', title: 'New Title');

      expect(sentBody.containsKey('title'), isTrue);
      expect(sentBody['title'], 'New Title');
      expect(sentBody.containsKey('description'), isFalse);
    });

    test('sends all provided fields', () async {
      late Map<String, dynamic> sentBody;
      mock.when((opts) {
        sentBody = opts.data as Map<String, dynamic>;
        return Response(requestOptions: opts, data: _fullJson, statusCode: 200);
      });

      await repo.updateReport(
        reportId: 'r1',
        title: 'Updated',
        description: 'New desc',
        location: 'Room 200',
        room: '200B',
        category: 'plumbing',
      );

      expect(sentBody['title'], 'Updated');
      expect(sentBody['description'], 'New desc');
      expect(sentBody['location'], 'Room 200');
      expect(sentBody['room'], '200B');
      expect(sentBody['category'], 'plumbing');
    });

    test('makes PATCH to correct path', () async {
      late String requestPath;
      mock.when((opts) {
        requestPath = opts.path;
        return Response(requestOptions: opts, data: _fullJson, statusCode: 200);
      });

      await repo.updateReport(reportId: 'r1', title: 'X');

      expect(requestPath, '/api/reports/r1');
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
      expect(comments.first.text, 'We will fix it tomorrow');
    });
  });

  group('addComment', () {
    test('sends text in POST body', () async {
      late Map<String, dynamic> sentBody;
      mock.when((opts) {
        sentBody = opts.data as Map<String, dynamic>;
        return Response(requestOptions: opts, data: _commentJson, statusCode: 200);
      });

      await repo.addComment('r1', 'We will fix it tomorrow');

      expect(sentBody['text'], 'We will fix it tomorrow');
    });

    test('returns created ReportComment', () async {
      mock.when((opts) => Response(
            requestOptions: opts,
            data: _commentJson,
            statusCode: 200,
          ));

      final comment = await repo.addComment('r1', 'text');

      expect(comment.id, 'c1');
      expect(comment.reportId, 'r1');
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
      expect(history.first.changedBy, 'u2');
    });

    test('makes GET to correct path', () async {
      late String requestPath;
      mock.when((opts) {
        requestPath = opts.path;
        return Response(requestOptions: opts, data: [], statusCode: 200);
      });

      await repo.getStatusHistory('r1');

      expect(requestPath, '/api/reports/r1/history');
    });
  });
}
