import 'package:client_app/features/reports/src/models/report.dart';

class MockReportsRepository {
  MockReportsRepository._();

  static final MockReportsRepository instance = MockReportsRepository._();

  final List<Report> _reports = [
    Report(
      id: 'r1',
      title: 'Не работает свет в аудитории А',
      description:
          'Вчера в 3:10 лампы перестали мигать. Студенты пытаются перемещаться по лестнице.',
      location: 'Учебный корпус 2, 3 этаж',
      category: 'Электрика',
      priority: 'Средний',
      room: 'А-312',
      reporter: 'Иван П.',
      createdAt: DateTime(2025, 10, 11, 8, 30),
      status: ReportStatus.inProgress,
    ),
    Report(
      id: 'r2',
      title: 'Протекает кран в туалете',
      description:
          'В женском туалете на 2 этаже постоянно капает вода из крана.',
      location: 'Учебный корпус 5, 2 этаж',
      category: 'Сантехника',
      priority: 'Низкий',
      room: 'WC-2',
      reporter: 'Мария И.',
      createdAt: DateTime(2025, 10, 10, 15, 10),
      status: ReportStatus.newReport,
    ),
    Report(
      id: 'r3',
      title: 'Не горит свет в коридоре',
      description:
          'Три лампы в коридоре перегорели, освещение слабое.',
      location: 'Учебный корпус 4, 4 этаж',
      category: 'Электрика',
      priority: 'Средний',
      room: 'Коридор',
      reporter: 'Светлана К.',
      createdAt: DateTime(2025, 10, 9, 12, 20),
      status: ReportStatus.resolved,
    ),
  ];

  List<Report> fetchReports() => List<Report>.unmodifiable(_reports);

  Report? getById(String id) {
    for (final report in _reports) {
      if (report.id == id) return report;
    }
    return null;
  }
}
