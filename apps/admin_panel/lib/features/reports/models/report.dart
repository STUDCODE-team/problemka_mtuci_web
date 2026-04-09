enum ReportStatus {
  newReport,
  inProgress,
  resolved,
  rejected;

  String get apiValue {
    switch (this) {
      case ReportStatus.newReport:
        return 'new';
      case ReportStatus.inProgress:
        return 'in_progress';
      case ReportStatus.resolved:
        return 'resolved';
      case ReportStatus.rejected:
        return 'rejected';
    }
  }

  String get label {
    switch (this) {
      case ReportStatus.newReport:
        return 'Новое';
      case ReportStatus.inProgress:
        return 'В работе';
      case ReportStatus.resolved:
        return 'Решено';
      case ReportStatus.rejected:
        return 'Отклонено';
    }
  }

  List<ReportStatus> get allowedTransitions {
    switch (this) {
      case ReportStatus.newReport:
        return [ReportStatus.inProgress, ReportStatus.rejected];
      case ReportStatus.inProgress:
        return [ReportStatus.resolved, ReportStatus.rejected];
      case ReportStatus.resolved:
      case ReportStatus.rejected:
        return [];
    }
  }

  static ReportStatus fromApi(String value) {
    switch (value) {
      case 'new':
        return ReportStatus.newReport;
      case 'in_progress':
        return ReportStatus.inProgress;
      case 'resolved':
        return ReportStatus.resolved;
      case 'rejected':
        return ReportStatus.rejected;
      default:
        return ReportStatus.newReport;
    }
  }
}

class ReportListItem {
  final String id;
  final String title;
  final String location;
  final String category;
  final String priority;
  final ReportStatus status;
  final DateTime createdAt;

  const ReportListItem({
    required this.id,
    required this.title,
    required this.location,
    required this.category,
    required this.priority,
    required this.status,
    required this.createdAt,
  });

  factory ReportListItem.fromJson(Map<String, dynamic> json) {
    return ReportListItem(
      id: json['id'] as String,
      title: json['title'] as String,
      location: json['location'] as String,
      category: json['category'] as String,
      priority: json['priority'] as String,
      status: ReportStatus.fromApi(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class ReportDetail {
  final String id;
  final String title;
  final String description;
  final String location;
  final String? room;
  final String category;
  final String priority;
  final String type;
  final ReportStatus status;
  final String reporterId;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ReportDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    this.room,
    required this.category,
    required this.priority,
    required this.type,
    required this.status,
    required this.reporterId,
    this.photoUrl,
    required this.createdAt,
    this.updatedAt,
  });

  factory ReportDetail.fromJson(Map<String, dynamic> json) {
    return ReportDetail(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      room: json['room'] as String?,
      category: json['category'] as String,
      priority: json['priority'] as String,
      type: json['type'] as String? ?? 'report',
      status: ReportStatus.fromApi(json['status'] as String),
      reporterId: json['reporter_id'] as String,
      photoUrl: json['photo_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}
