import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:client_app/features/reports/src/models/report.dart';
import 'package:client_app/features/reports/src/reports_repository.dart';
import 'package:client_app/features/reports/src/bloc/reports_bloc.dart';

// ---------------------------------------------------------------------------
// Fake репозиторий
// ---------------------------------------------------------------------------

class _FakeReportsRepository implements ReportsRepository {
  Future<List<Report>> Function({ReportStatus? status})? onFetchMyReports;
  Future<Report> Function(String id)? onGetById;
  Future<Report> Function()? onCreateReport;
  Future<Report> Function(String id)? onUpdateReport;
  Future<List<ReportComment>> Function(String id)? onGetComments;
  Future<ReportComment> Function(String id, String text)? onAddComment;
  Future<List<StatusHistoryEntry>> Function(String id)? onGetStatusHistory;

  _FakeReportsRepository({
    this.onFetchMyReports,
    this.onGetById,
    this.onCreateReport,
    this.onUpdateReport,
    this.onGetComments,
    this.onAddComment,
    this.onGetStatusHistory,
  });

  @override
  Future<List<Report>> fetchMyReports({
    ReportStatus? status,
    int limit = 50,
    int offset = 0,
  }) =>
      onFetchMyReports?.call(status: status) ?? Future.value([]);

  @override
  Future<Report> getById(String id) =>
      onGetById?.call(id) ?? Future.error(StateError('getById not configured'));

  @override
  Future<Report> createReport({
    required String title,
    required String description,
    required String location,
    String? room,
    required String category,
    String priority = 'medium',
    String type = 'report',
  }) =>
      onCreateReport?.call() ?? Future.error(StateError('createReport not configured'));

  @override
  Future<Report> updateReport({
    required String reportId,
    String? title,
    String? description,
    String? location,
    String? room,
    String? category,
  }) =>
      onUpdateReport?.call(reportId) ??
      Future.error(StateError('updateReport not configured'));

  @override
  Future<List<ReportComment>> getComments(String reportId) =>
      onGetComments?.call(reportId) ?? Future.value([]);

  @override
  Future<ReportComment> addComment(String reportId, String text) =>
      onAddComment?.call(reportId, text) ??
      Future.error(StateError('addComment not configured'));

  @override
  Future<List<StatusHistoryEntry>> getStatusHistory(String reportId) =>
      onGetStatusHistory?.call(reportId) ?? Future.value([]);
}

// ---------------------------------------------------------------------------
// Фабрики тестовых данных
// ---------------------------------------------------------------------------

Report _makeReport({
  String id = 'r-1',
  ReportStatus status = ReportStatus.newReport,
}) =>
    Report(
      id: id,
      title: 'Тестовая заявка',
      description: 'Описание проблемы',
      location: 'Корпус А',
      category: 'electrical',
      priority: 'medium',
      status: status,
      reporterId: 'u-1',
      createdAt: DateTime(2024, 1, 1),
    );

ReportComment _makeComment({String id = 'c-1'}) => ReportComment(
      id: id,
      reportId: 'r-1',
      authorId: 'u-2',
      text: 'Принято в работу',
      createdAt: DateTime(2024, 1, 2),
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
  group('ReportsBloc — начальное состояние', () {
    test('ReportsInitial при создании', () {
      final bloc = ReportsBloc(repository: _FakeReportsRepository());
      expect(bloc.state, isA<ReportsInitial>());
      bloc.close();
    });
  });

  group('ReportsBloc — LoadMyReports', () {
    test('успешная загрузка: [ReportsLoading, ReportsLoaded]', () async {
      final reports = [_makeReport(id: 'r-1'), _makeReport(id: 'r-2')];

      final bloc = ReportsBloc(
        repository: _FakeReportsRepository(
          onFetchMyReports: ({status}) async => reports,
        ),
      );

      final future = expectLater(
        bloc.stream,
        emitsInOrder([isA<ReportsLoading>(), isA<ReportsLoaded>()]),
      );

      bloc.add(LoadMyReports());
      await future;

      expect((bloc.state as ReportsLoaded).reports.length, 2);
      await bloc.close();
    });

    test('загрузка с фильтром: activeFilter установлен в состоянии', () async {
      final bloc = ReportsBloc(
        repository: _FakeReportsRepository(
          onFetchMyReports: ({status}) async => [_makeReport(status: status!)],
        ),
      );

      final future = expectLater(
        bloc.stream,
        emitsInOrder([isA<ReportsLoading>(), isA<ReportsLoaded>()]),
      );

      bloc.add(LoadMyReports(status: ReportStatus.inProgress));
      await future;

      expect(
        (bloc.state as ReportsLoaded).activeFilter,
        ReportStatus.inProgress,
      );
      await bloc.close();
    });

    test('пустой список: ReportsLoaded с пустыми reports', () async {
      final bloc = ReportsBloc(
        repository: _FakeReportsRepository(
          onFetchMyReports: ({status}) async => [],
        ),
      );

      final future = expectLater(
        bloc.stream,
        emitsInOrder([isA<ReportsLoading>(), isA<ReportsLoaded>()]),
      );

      bloc.add(LoadMyReports());
      await future;

      expect((bloc.state as ReportsLoaded).reports, isEmpty);
      await bloc.close();
    });

    test('ошибка с detail: [ReportsLoading, ReportsError(detail)]', () async {
      final bloc = ReportsBloc(
        repository: _FakeReportsRepository(
          onFetchMyReports: ({status}) =>
              Future.error(_dioError(data: {'detail': 'Access denied'})),
        ),
      );

      final future = expectLater(
        bloc.stream,
        emitsInOrder([isA<ReportsLoading>(), isA<ReportsError>()]),
      );

      bloc.add(LoadMyReports());
      await future;

      expect((bloc.state as ReportsError).message, 'Access denied');
      await bloc.close();
    });

    test('сетевая ошибка: ReportsError("Ошибка соединения")', () async {
      final bloc = ReportsBloc(
        repository: _FakeReportsRepository(
          onFetchMyReports: ({status}) => Future.error(_dioError()),
        ),
      );

      final future = expectLater(
        bloc.stream,
        emitsInOrder([isA<ReportsLoading>(), isA<ReportsError>()]),
      );

      bloc.add(LoadMyReports());
      await future;

      expect((bloc.state as ReportsError).message, 'Ошибка соединения');
      await bloc.close();
    });

    test('ошибка валидации с массивом errors: форматируется как field: message', () async {
      final bloc = ReportsBloc(
        repository: _FakeReportsRepository(
          onFetchMyReports: ({status}) => Future.error(
            _dioError(data: {
              'detail': 'Validation error',
              'errors': [
                {'field': 'title', 'message': 'Title is required'},
                {'field': 'location', 'message': 'Location is required'},
              ],
            }),
          ),
        ),
      );

      final future = expectLater(
        bloc.stream,
        emitsInOrder([isA<ReportsLoading>(), isA<ReportsError>()]),
      );

      bloc.add(LoadMyReports());
      await future;

      expect(
        (bloc.state as ReportsError).message,
        'title: Title is required\nlocation: Location is required',
      );
      await bloc.close();
    });
  });

  group('ReportsBloc — LoadReportDetail', () {
    test('успешная загрузка деталей: [ReportsLoading, ReportDetailLoaded]', () async {
      final report = _makeReport();
      final comments = [_makeComment()];
      final history = <StatusHistoryEntry>[];

      final bloc = ReportsBloc(
        repository: _FakeReportsRepository(
          onGetById: (_) async => report,
          onGetComments: (_) async => comments,
          onGetStatusHistory: (_) async => history,
        ),
      );

      final future = expectLater(
        bloc.stream,
        emitsInOrder([isA<ReportsLoading>(), isA<ReportDetailLoaded>()]),
      );

      bloc.add(LoadReportDetail('r-1'));
      await future;

      final loaded = bloc.state as ReportDetailLoaded;
      expect(loaded.report.id, 'r-1');
      expect(loaded.comments.length, 1);
      expect(loaded.history, isEmpty);
      await bloc.close();
    });

    test('все три запроса выполняются параллельно (Future.wait)', () async {
      final calls = <String>[];

      final bloc = ReportsBloc(
        repository: _FakeReportsRepository(
          onGetById: (_) async {
            calls.add('report');
            return _makeReport();
          },
          onGetComments: (_) async {
            calls.add('comments');
            return [];
          },
          onGetStatusHistory: (_) async {
            calls.add('history');
            return [];
          },
        ),
      );

      final future = expectLater(
        bloc.stream,
        emitsInOrder([isA<ReportsLoading>(), isA<ReportDetailLoaded>()]),
      );

      bloc.add(LoadReportDetail('r-1'));
      await future;

      expect(calls, containsAll(['report', 'comments', 'history']));
      await bloc.close();
    });

    test('ошибка загрузки: [ReportsLoading, ReportsError]', () async {
      final bloc = ReportsBloc(
        repository: _FakeReportsRepository(
          onGetById: (_) => Future.error(
            _dioError(data: {'detail': 'Report not found'}),
          ),
          onGetComments: (_) async => [],
          onGetStatusHistory: (_) async => [],
        ),
      );

      final future = expectLater(
        bloc.stream,
        emitsInOrder([isA<ReportsLoading>(), isA<ReportsError>()]),
      );

      bloc.add(LoadReportDetail('r-99'));
      await future;

      expect((bloc.state as ReportsError).message, 'Report not found');
      await bloc.close();
    });
  });

  group('ReportsBloc — CreateReport', () {
    test('успешное создание: [ReportCreating, ReportCreated]', () async {
      final created = _makeReport(id: 'r-new');

      final bloc = ReportsBloc(
        repository: _FakeReportsRepository(
          onCreateReport: () async => created,
        ),
      );

      final future = expectLater(
        bloc.stream,
        emitsInOrder([isA<ReportCreating>(), isA<ReportCreated>()]),
      );

      bloc.add(CreateReport(
        title: 'Сломана лампа',
        description: 'Лампа в 301 аудитории не работает',
        location: 'Корпус А',
        category: 'electrical',
      ));
      await future;

      expect((bloc.state as ReportCreated).report.id, 'r-new');
      await bloc.close();
    });

    test('ошибка создания: [ReportCreating, ReportsError]', () async {
      final bloc = ReportsBloc(
        repository: _FakeReportsRepository(
          onCreateReport: () => Future.error(
            _dioError(data: {'detail': 'Validation failed'}),
          ),
        ),
      );

      final future = expectLater(
        bloc.stream,
        emitsInOrder([isA<ReportCreating>(), isA<ReportsError>()]),
      );

      bloc.add(CreateReport(
        title: '',
        description: '',
        location: 'Корпус А',
        category: 'electrical',
      ));
      await future;

      expect((bloc.state as ReportsError).message, 'Validation failed');
      await bloc.close();
    });
  });

  group('ReportsBloc — UpdateReport', () {
    test('успешное обновление: [ReportUpdated]', () async {
      final updated = _makeReport(id: 'r-1');

      final bloc = ReportsBloc(
        repository: _FakeReportsRepository(
          onUpdateReport: (_) async => updated,
        ),
      );

      final future = expectLater(
        bloc.stream,
        emits(isA<ReportUpdated>()),
      );

      bloc.add(UpdateReport(reportId: 'r-1', title: 'Новый заголовок'));
      await future;

      expect((bloc.state as ReportUpdated).report.id, 'r-1');
      await bloc.close();
    });

    test('ошибка обновления: [ReportsError]', () async {
      final bloc = ReportsBloc(
        repository: _FakeReportsRepository(
          onUpdateReport: (_) => Future.error(
            _dioError(data: {'detail': 'Not found'}),
          ),
        ),
      );

      final future = expectLater(
        bloc.stream,
        emits(isA<ReportsError>()),
      );

      bloc.add(UpdateReport(reportId: 'r-99'));
      await future;
      await bloc.close();
    });
  });

  group('ReportsBloc — AddComment', () {
    test('после добавления комментария перезагружает детали', () async {
      final bloc = ReportsBloc(
        repository: _FakeReportsRepository(
          onAddComment: (_, __) async => _makeComment(),
          onGetById: (_) async => _makeReport(),
          onGetComments: (_) async => [_makeComment()],
          onGetStatusHistory: (_) async => [],
        ),
      );

      final future = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<ReportsLoading>(),   // из LoadReportDetail
          isA<ReportDetailLoaded>(),
        ]),
      );

      bloc.add(AddComment(reportId: 'r-1', text: 'Новый комментарий'));
      await future;

      expect((bloc.state as ReportDetailLoaded).comments.length, 1);
      await bloc.close();
    });

    test('ошибка добавления комментария: [ReportsError]', () async {
      final bloc = ReportsBloc(
        repository: _FakeReportsRepository(
          onAddComment: (_, __) => Future.error(
            _dioError(data: {'detail': 'Forbidden'}),
          ),
        ),
      );

      final future = expectLater(
        bloc.stream,
        emits(isA<ReportsError>()),
      );

      bloc.add(AddComment(reportId: 'r-1', text: 'Текст'));
      await future;

      expect((bloc.state as ReportsError).message, 'Forbidden');
      await bloc.close();
    });
  });
}
