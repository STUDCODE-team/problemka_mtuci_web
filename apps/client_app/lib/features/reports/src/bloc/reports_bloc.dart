import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_app/features/reports/src/models/report.dart';
import 'package:client_app/features/reports/src/reports_repository.dart';

// --- Events ---

abstract class ReportsEvent {}

class LoadMyReports extends ReportsEvent {
  final ReportStatus? status;
  LoadMyReports({this.status});
}

class LoadReportDetail extends ReportsEvent {
  final String reportId;
  LoadReportDetail(this.reportId);
}

class CreateReport extends ReportsEvent {
  final String title;
  final String description;
  final String location;
  final String? room;
  final String category;
  final String priority;

  CreateReport({
    required this.title,
    required this.description,
    required this.location,
    this.room,
    required this.category,
    this.priority = 'medium',
  });
}

class AddComment extends ReportsEvent {
  final String reportId;
  final String text;
  AddComment({required this.reportId, required this.text});
}

// --- States ---

abstract class ReportsState {}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {}

class ReportsLoaded extends ReportsState {
  final List<Report> reports;
  final ReportStatus? activeFilter;
  ReportsLoaded(this.reports, {this.activeFilter});
}

class ReportsError extends ReportsState {
  final String message;
  ReportsError(this.message);
}

class ReportDetailLoaded extends ReportsState {
  final Report report;
  final List<ReportComment> comments;
  final List<StatusHistoryEntry> history;
  ReportDetailLoaded({
    required this.report,
    required this.comments,
    required this.history,
  });
}

class ReportCreating extends ReportsState {}

class ReportCreated extends ReportsState {
  final Report report;
  ReportCreated(this.report);
}

// --- BLoC ---

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final ReportsRepository _repository;

  ReportsBloc({required ReportsRepository repository})
      : _repository = repository,
        super(ReportsInitial()) {
    on<LoadMyReports>(_onLoadMyReports);
    on<LoadReportDetail>(_onLoadDetail);
    on<CreateReport>(_onCreateReport);
    on<AddComment>(_onAddComment);
  }

  Future<void> _onLoadMyReports(LoadMyReports event, Emitter<ReportsState> emit) async {
    emit(ReportsLoading());
    try {
      final reports = await _repository.fetchMyReports(status: event.status);
      emit(ReportsLoaded(reports, activeFilter: event.status));
    } on DioException catch (e) {
      emit(ReportsError(_extractError(e)));
    }
  }

  Future<void> _onLoadDetail(LoadReportDetail event, Emitter<ReportsState> emit) async {
    emit(ReportsLoading());
    try {
      final results = await Future.wait([
        _repository.getById(event.reportId),
        _repository.getComments(event.reportId),
        _repository.getStatusHistory(event.reportId),
      ]);
      emit(ReportDetailLoaded(
        report: results[0] as Report,
        comments: results[1] as List<ReportComment>,
        history: results[2] as List<StatusHistoryEntry>,
      ));
    } on DioException catch (e) {
      emit(ReportsError(_extractError(e)));
    }
  }

  Future<void> _onCreateReport(CreateReport event, Emitter<ReportsState> emit) async {
    emit(ReportCreating());
    try {
      final report = await _repository.createReport(
        title: event.title,
        description: event.description,
        location: event.location,
        room: event.room,
        category: event.category,
        priority: event.priority,
      );
      emit(ReportCreated(report));
    } on DioException catch (e) {
      emit(ReportsError(_extractError(e)));
    }
  }

  Future<void> _onAddComment(AddComment event, Emitter<ReportsState> emit) async {
    try {
      await _repository.addComment(event.reportId, event.text);
      add(LoadReportDetail(event.reportId));
    } on DioException catch (e) {
      emit(ReportsError(_extractError(e)));
    }
  }

  String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic> && data.containsKey('detail')) {
      return data['detail'] as String;
    }
    return 'Connection error';
  }
}
