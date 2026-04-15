import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:admin_panel/features/reports/models/report.dart';
import 'package:admin_panel/features/reports/repositories/reports_repository.dart';
import 'package:admin_panel/features/users/models/user_info.dart';
import 'package:admin_panel/features/users/repositories/users_repository.dart';

// --- Events ---

abstract class ReportsEvent {}

class LoadReports extends ReportsEvent {
  final ReportStatus? status;
  LoadReports({this.status});
}

class ChangeReportStatus extends ReportsEvent {
  final String reportId;
  final ReportStatus status;
  ChangeReportStatus({required this.reportId, required this.status});
}

class LoadAdminReportDetail extends ReportsEvent {
  final String reportId;
  LoadAdminReportDetail(this.reportId);
}

class AddAdminComment extends ReportsEvent {
  final String reportId;
  final String text;
  AddAdminComment({required this.reportId, required this.text});
}

class ForceChangeStatus extends ReportsEvent {
  final String reportId;
  final ReportStatus status;
  ForceChangeStatus({required this.reportId, required this.status});
}

class DeleteReport extends ReportsEvent {
  final String reportId;
  DeleteReport(this.reportId);
}

// --- States ---

abstract class ReportsState {}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {}

class ReportsLoaded extends ReportsState {
  final List<ReportListItem> reports;
  final ReportStatus? activeFilter;
  ReportsLoaded(this.reports, {this.activeFilter});
}

class ReportsError extends ReportsState {
  final String message;
  ReportsError(this.message);
}

class ReportStatusChanged extends ReportsState {
  final ReportDetail report;
  ReportStatusChanged(this.report);
}

class AdminReportDetailLoaded extends ReportsState {
  final ReportDetail report;
  final List<ReportComment> comments;
  final List<StatusHistoryEntry> history;
  final UserInfo? reporter;

  AdminReportDetailLoaded({
    required this.report,
    required this.comments,
    required this.history,
    this.reporter,
  });
}

class AdminDetailLoading extends ReportsState {}

class AdminDetailError extends ReportsState {
  final String message;
  AdminDetailError(this.message);
}

class ReportDeleted extends ReportsState {}

class ReportDeleteError extends ReportsState {
  final String message;
  ReportDeleteError(this.message);
}

// --- BLoC ---

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final ReportsRepository _repository;
  final UsersRepository? _usersRepository;
  ReportStatus? _currentFilter;

  ReportsBloc({
    required ReportsRepository repository,
    UsersRepository? usersRepository,
  })  : _repository = repository,
        _usersRepository = usersRepository,
        super(ReportsInitial()) {
    on<LoadReports>(_onLoad);
    on<ChangeReportStatus>(_onChangeStatus);
    on<LoadAdminReportDetail>(_onLoadDetail);
    on<AddAdminComment>(_onAddComment);
    on<ForceChangeStatus>(_onForceChangeStatus);
    on<DeleteReport>(_onDeleteReport);
  }

  Future<void> _onLoad(LoadReports event, Emitter<ReportsState> emit) async {
    _currentFilter = event.status;
    emit(ReportsLoading());
    try {
      final reports = await _repository.getReports(status: event.status);
      emit(ReportsLoaded(reports, activeFilter: event.status));
    } on DioException catch (e) {
      emit(ReportsError(_extractError(e)));
    }
  }

  Future<void> _onChangeStatus(
    ChangeReportStatus event,
    Emitter<ReportsState> emit,
  ) async {
    try {
      final updated = await _repository.changeStatus(event.reportId, event.status);
      emit(ReportStatusChanged(updated));
      add(LoadReports(status: _currentFilter));
    } on DioException catch (e) {
      emit(ReportsError(_extractError(e)));
      add(LoadReports(status: _currentFilter));
    }
  }

  Future<void> _onLoadDetail(
    LoadAdminReportDetail event,
    Emitter<ReportsState> emit,
  ) async {
    emit(AdminDetailLoading());
    try {
      final results = await Future.wait([
        _repository.getReportById(event.reportId),
        _repository.getComments(event.reportId),
        _repository.getStatusHistory(event.reportId),
      ]);

      final report = results[0] as ReportDetail;
      final comments = results[1] as List<ReportComment>;
      final history = results[2] as List<StatusHistoryEntry>;

      UserInfo? reporter;
      if (_usersRepository != null) {
        try {
          reporter = await _usersRepository.getUserById(report.reporterId);
        } catch (_) {
          // reporter info is optional — silently ignore
        }
      }

      emit(AdminReportDetailLoaded(
        report: report,
        comments: comments,
        history: history,
        reporter: reporter,
      ));
    } on DioException catch (e) {
      emit(AdminDetailError(_extractError(e)));
    }
  }

  Future<void> _onAddComment(
    AddAdminComment event,
    Emitter<ReportsState> emit,
  ) async {
    try {
      await _repository.addComment(event.reportId, event.text);
      add(LoadAdminReportDetail(event.reportId));
    } on DioException catch (e) {
      emit(AdminDetailError(_extractError(e)));
    }
  }

  Future<void> _onForceChangeStatus(
    ForceChangeStatus event,
    Emitter<ReportsState> emit,
  ) async {
    try {
      await _repository.forceChangeStatus(event.reportId, event.status);
      add(LoadAdminReportDetail(event.reportId));
    } on DioException catch (e) {
      emit(AdminDetailError(_extractError(e)));
    }
  }

  Future<void> _onDeleteReport(
    DeleteReport event,
    Emitter<ReportsState> emit,
  ) async {
    try {
      await _repository.deleteReport(event.reportId);
      emit(ReportDeleted());
    } on DioException catch (e) {
      emit(ReportDeleteError(_extractError(e)));
    }
  }

  String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final errors = data['errors'];
      if (errors is List && errors.isNotEmpty) {
        return errors
            .whereType<Map<String, dynamic>>()
            .map((e) => '${e['field']}: ${e['message']}')
            .join('\n');
      }
      final detail = data['detail'];
      if (detail is String) return detail;
    }
    return 'Ошибка соединения';
  }
}
