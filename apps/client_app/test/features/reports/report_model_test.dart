import 'package:flutter_test/flutter_test.dart';
import 'package:client_app/features/reports/src/models/report.dart';

void main() {
  group('ReportStatus.fromApi', () {
    test('парсит "new" как newReport', () {
      expect(ReportStatus.fromApi('new'), ReportStatus.newReport);
    });
    test('парсит "in_progress" как inProgress', () {
      expect(ReportStatus.fromApi('in_progress'), ReportStatus.inProgress);
    });
    test('парсит "resolved" как resolved', () {
      expect(ReportStatus.fromApi('resolved'), ReportStatus.resolved);
    });
    test('парсит "rejected" как rejected', () {
      expect(ReportStatus.fromApi('rejected'), ReportStatus.rejected);
    });
    test('неизвестное значение возвращает newReport по умолчанию', () {
      expect(ReportStatus.fromApi('unknown_value'), ReportStatus.newReport);
    });
    test('пустая строка возвращает newReport по умолчанию', () {
      expect(ReportStatus.fromApi(''), ReportStatus.newReport);
    });
  });

  group('ReportStatus.apiValue', () {
    test('newReport → "new"', () {
      expect(ReportStatus.newReport.apiValue, 'new');
    });
    test('inProgress → "in_progress"', () {
      expect(ReportStatus.inProgress.apiValue, 'in_progress');
    });
    test('resolved → "resolved"', () {
      expect(ReportStatus.resolved.apiValue, 'resolved');
    });
    test('rejected → "rejected"', () {
      expect(ReportStatus.rejected.apiValue, 'rejected');
    });
  });

  group('ReportStatus roundtrip fromApi → apiValue', () {
    for (final status in ReportStatus.values) {
      test('${status.name} сохраняется при конвертации', () {
        expect(ReportStatus.fromApi(status.apiValue), status);
      });
    }
  });

  group('ReportCategory.apiValue', () {
    test('electrical → "electrical"', () {
      expect(ReportCategory.electrical.apiValue, 'electrical');
    });
    test('plumbing → "plumbing"', () {
      expect(ReportCategory.plumbing.apiValue, 'plumbing');
    });
    test('furniture → "furniture"', () {
      expect(ReportCategory.furniture.apiValue, 'furniture');
    });
    test('itEquipment → "it_equipment"', () {
      expect(ReportCategory.itEquipment.apiValue, 'it_equipment');
    });
    test('cleaning → "cleaning"', () {
      expect(ReportCategory.cleaning.apiValue, 'cleaning');
    });
    test('heating → "heating"', () {
      expect(ReportCategory.heating.apiValue, 'heating');
    });
    test('other → "other"', () {
      expect(ReportCategory.other.apiValue, 'other');
    });
  });

  group('ReportCategory.label', () {
    test('electrical → "Электрика"', () {
      expect(ReportCategory.electrical.label, 'Электрика');
    });
    test('itEquipment → "IT-оборудование"', () {
      expect(ReportCategory.itEquipment.label, 'IT-оборудование');
    });
    test('other → "Другое"', () {
      expect(ReportCategory.other.label, 'Другое');
    });
  });

  group('Report.fromJson', () {
    final fullJson = {
      'id': 'r-1',
      'title': 'Сломана лампа',
      'description': 'Лампа в 301 аудитории не работает',
      'location': 'Корпус А',
      'room': '301',
      'category': 'electrical',
      'priority': 'high',
      'type': 'report',
      'status': 'in_progress',
      'reporter_id': 'u-1',
      'photo_url': 'https://example.com/photo.jpg',
      'created_at': '2024-01-15T10:00:00.000Z',
      'updated_at': '2024-01-16T12:00:00.000Z',
    };

    test('парсит все обязательные поля', () {
      final report = Report.fromJson(fullJson);
      expect(report.id, 'r-1');
      expect(report.title, 'Сломана лампа');
      expect(report.description, 'Лампа в 301 аудитории не работает');
      expect(report.location, 'Корпус А');
      expect(report.category, 'electrical');
      expect(report.priority, 'high');
      expect(report.type, 'report');
      expect(report.status, ReportStatus.inProgress);
      expect(report.reporterId, 'u-1');
    });

    test('парсит опциональные поля когда они заданы', () {
      final report = Report.fromJson(fullJson);
      expect(report.room, '301');
      expect(report.photoUrl, 'https://example.com/photo.jpg');
      expect(report.updatedAt, isNotNull);
    });

    test('null поля корректно обрабатываются', () {
      final json = Map<String, dynamic>.from(fullJson)
        ..['room'] = null
        ..['photo_url'] = null
        ..['updated_at'] = null;
      final report = Report.fromJson(json);
      expect(report.room, isNull);
      expect(report.photoUrl, isNull);
      expect(report.updatedAt, isNull);
    });

    test('type по умолчанию "report" если поле отсутствует', () {
      final json = Map<String, dynamic>.from(fullJson)..remove('type');
      final report = Report.fromJson(json);
      expect(report.type, 'report');
    });

    test('createdAt корректно парсится из ISO8601', () {
      final report = Report.fromJson(fullJson);
      expect(report.createdAt, DateTime.parse('2024-01-15T10:00:00.000Z'));
    });

    test('updatedAt корректно парсится из ISO8601', () {
      final report = Report.fromJson(fullJson);
      expect(report.updatedAt, DateTime.parse('2024-01-16T12:00:00.000Z'));
    });
  });

  group('Report.fromListJson', () {
    final listJson = {
      'id': 'r-2',
      'title': 'Протечка',
      'location': 'Корпус Б',
      'category': 'plumbing',
      'priority': 'medium',
      'status': 'new',
      'created_at': '2024-02-01T08:00:00.000Z',
    };

    test('парсит поля из сокращённого ответа списка', () {
      final report = Report.fromListJson(listJson);
      expect(report.id, 'r-2');
      expect(report.title, 'Протечка');
      expect(report.location, 'Корпус Б');
      expect(report.status, ReportStatus.newReport);
    });

    test('description пуст в сокращённом ответе', () {
      final report = Report.fromListJson(listJson);
      expect(report.description, '');
    });

    test('reporterId пуст в сокращённом ответе', () {
      final report = Report.fromListJson(listJson);
      expect(report.reporterId, '');
    });
  });

  group('ReportComment.fromJson', () {
    final json = {
      'id': 'c-1',
      'report_id': 'r-1',
      'author_id': 'u-2',
      'text': 'Принято в работу',
      'created_at': '2024-01-16T09:00:00.000Z',
    };

    test('парсит все поля корректно', () {
      final comment = ReportComment.fromJson(json);
      expect(comment.id, 'c-1');
      expect(comment.reportId, 'r-1');
      expect(comment.authorId, 'u-2');
      expect(comment.text, 'Принято в работу');
    });

    test('createdAt корректно парсится', () {
      final comment = ReportComment.fromJson(json);
      expect(comment.createdAt, DateTime.parse('2024-01-16T09:00:00.000Z'));
    });
  });

  group('StatusHistoryEntry.fromJson', () {
    final json = {
      'id': 'h-1',
      'report_id': 'r-1',
      'old_status': 'new',
      'new_status': 'in_progress',
      'changed_by': 'admin-1',
      'changed_at': '2024-01-16T10:00:00.000Z',
    };

    test('парсит все поля корректно', () {
      final entry = StatusHistoryEntry.fromJson(json);
      expect(entry.id, 'h-1');
      expect(entry.reportId, 'r-1');
      expect(entry.oldStatus, 'new');
      expect(entry.newStatus, 'in_progress');
      expect(entry.changedBy, 'admin-1');
    });

    test('changedAt корректно парсится', () {
      final entry = StatusHistoryEntry.fromJson(json);
      expect(entry.changedAt, DateTime.parse('2024-01-16T10:00:00.000Z'));
    });
  });
}
