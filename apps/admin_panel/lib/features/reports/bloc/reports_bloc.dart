import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:admin_panel/features/reports/models/report.dart';
import 'package:admin_panel/features/reports/repositories/reports_repository.dart';

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

// --- BLoC ---

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final ReportsRepository _repository;
  ReportStatus? _currentFilter;

  ReportsBloc({required ReportsRepository repository})
      : _repository = repository,
        super(ReportsInitial()) {
    on<LoadReports>(_onLoad);
    on<ChangeReportStatus>(_onChangeStatus);
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
