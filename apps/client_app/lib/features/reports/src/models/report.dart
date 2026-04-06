enum ReportCategory {
  electrical,
  plumbing,
  furniture,
  itEquipment,
  cleaning,
  heating,
  other;

  String get apiValue {
    switch (this) {
      case ReportCategory.electrical:
        return 'electrical';
      case ReportCategory.plumbing:
        return 'plumbing';
      case ReportCategory.furniture:
        return 'furniture';
      case ReportCategory.itEquipment:
        return 'it_equipment';
      case ReportCategory.cleaning:
        return 'cleaning';
      case ReportCategory.heating:
        return 'heating';
      case ReportCategory.other:
        return 'other';
    }
  }

  String get label {
    switch (this) {
      case ReportCategory.electrical:
        return 'Электрика';
      case ReportCategory.plumbing:
        return 'Сантехника';
      case ReportCategory.furniture:
        return 'Мебель';
      case ReportCategory.itEquipment:
        return 'IT-оборудование';
      case ReportCategory.cleaning:
        return 'Уборка';
      case ReportCategory.heating:
        return 'Отопление';
      case ReportCategory.other:
        return 'Другое';
    }
  }
}

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

class Report {
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

  const Report({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    this.room,
    required this.category,
    required this.priority,
    this.type = 'report',
    required this.status,
    required this.reporterId,
    this.photoUrl,
    required this.createdAt,
    this.updatedAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
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

  /// From list endpoint (fewer fields)
  factory Report.fromListJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as String,
      title: json['title'] as String,
      description: '',
      location: json['location'] as String,
      category: json['category'] as String,
      priority: json['priority'] as String,
      status: ReportStatus.fromApi(json['status'] as String),
      reporterId: '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class ReportComment {
  final String id;
  final String reportId;
  final String authorId;
  final String text;
  final DateTime createdAt;

  const ReportComment({
    required this.id,
    required this.reportId,
    required this.authorId,
    required this.text,
    required this.createdAt,
  });

  factory ReportComment.fromJson(Map<String, dynamic> json) {
    return ReportComment(
      id: json['id'] as String,
      reportId: json['report_id'] as String,
      authorId: json['author_id'] as String,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class StatusHistoryEntry {
  final String id;
  final String reportId;
  final String oldStatus;
  final String newStatus;
  final String changedBy;
  final DateTime changedAt;

  const StatusHistoryEntry({
    required this.id,
    required this.reportId,
    required this.oldStatus,
    required this.newStatus,
    required this.changedBy,
    required this.changedAt,
  });

  factory StatusHistoryEntry.fromJson(Map<String, dynamic> json) {
    return StatusHistoryEntry(
      id: json['id'] as String,
      reportId: json['report_id'] as String,
      oldStatus: json['old_status'] as String,
      newStatus: json['new_status'] as String,
      changedBy: json['changed_by'] as String,
      changedAt: DateTime.parse(json['changed_at'] as String),
    );
  }
}
