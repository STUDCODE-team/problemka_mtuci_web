enum ReportStatus { newReport, inProgress, resolved }

class Report {
  final String id;
  final String title;
  final String description;
  final String location;
  final String category;
  final String priority;
  final String room;
  final String reporter;
  final DateTime createdAt;
  final ReportStatus status;

  const Report({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.category,
    required this.priority,
    required this.room,
    required this.reporter,
    required this.createdAt,
    required this.status,
  });
}
