import 'package:client_app/features/reports/src/models/report.dart';

class AppNotification {
  final String id;
  final String reporterId;
  final String reportId;
  final String reportTitle;
  final ReportStatus oldStatus;
  final ReportStatus newStatus;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.reporterId,
    required this.reportId,
    required this.reportTitle,
    required this.oldStatus,
    required this.newStatus,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      reporterId: json['reporter_id'] as String,
      reportId: json['report_id'] as String,
      reportTitle: json['report_title'] as String,
      oldStatus: ReportStatus.fromApi(json['old_status'] as String),
      newStatus: ReportStatus.fromApi(json['new_status'] as String),
      isRead: json['is_read'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      reporterId: reporterId,
      reportId: reportId,
      reportTitle: reportTitle,
      oldStatus: oldStatus,
      newStatus: newStatus,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}
