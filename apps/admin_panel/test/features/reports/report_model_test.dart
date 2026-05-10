import 'package:flutter_test/flutter_test.dart';
import 'package:admin_panel/features/reports/models/report.dart';

void main() {
  group('ReportStatus.fromApi (admin)', () {
    test('парсит все известные значения', () {
      expect(ReportStatus.fromApi('new'), ReportStatus.newReport);
      expect(ReportStatus.fromApi('in_progress'), ReportStatus.inProgress);
      expect(ReportStatus.fromApi('resolved'), ReportStatus.resolved);
      expect(ReportStatus.fromApi('rejected'), ReportStatus.rejected);
    });

    test('неизвестное значение возвращает newReport по умолчанию', () {
      expect(ReportStatus.fromApi('invalid'), ReportStatus.newReport);
    });
  });

  group('ReportStatus.allowedTransitions', () {
    test('newReport → [inProgress, rejected]', () {
      final transitions = ReportStatus.newReport.allowedTransitions;
      expect(transitions, containsAll([ReportStatus.inProgress, ReportStatus.rejected]));
      expect(transitions.length, 2);
    });

    test('inProgress → [resolved, rejected]', () {
      final transitions = ReportStatus.inProgress.allowedTransitions;
      expect(transitions, containsAll([ReportStatus.resolved, ReportStatus.rejected]));
      expect(transitions.length, 2);
    });

    test('resolved — конечный статус, нет переходов', () {
      expect(ReportStatus.resolved.allowedTransitions, isEmpty);
    });

    test('rejected — конечный статус, нет переходов', () {
      expect(ReportStatus.rejected.allowedTransitions, isEmpty);
    });

    test('из newReport нельзя перейти напрямую в resolved', () {
      expect(
        ReportStatus.newReport.allowedTransitions,
        isNot(contains(ReportStatus.resolved)),
      );
    });

    test('из inProgress нельзя вернуться в newReport', () {
      expect(
        ReportStatus.inProgress.allowedTransitions,
        isNot(contains(ReportStatus.newReport)),
      );
    });
  });

  group('ReportStatus.label (admin)', () {
    test('возвращает русские названия', () {
      expect(ReportStatus.newReport.label, 'Новое');
      expect(ReportStatus.inProgress.label, 'В работе');
      expect(ReportStatus.resolved.label, 'Решено');
      expect(ReportStatus.rejected.label, 'Отклонено');
    });
  });

  group('ReportStatus.apiValue (admin)', () {
    test('roundtrip: fromApi(apiValue) === исходный статус', () {
      for (final status in ReportStatus.values) {
        expect(ReportStatus.fromApi(status.apiValue), status);
      }
    });
  });

  group('ReportListItem.fromJson', () {
    final json = {
      'id': 'r-1',
      'title': 'Поломан стул',
      'location': 'Корпус В',
      'category': 'furniture',
      'priority': 'low',
      'status': 'new',
      'created_at': '2024-03-01T09:00:00.000Z',
    };

    test('парсит все поля корректно', () {
      final item = ReportListItem.fromJson(json);
      expect(item.id, 'r-1');
      expect(item.title, 'Поломан стул');
      expect(item.location, 'Корпус В');
      expect(item.category, 'furniture');
      expect(item.priority, 'low');
      expect(item.status, ReportStatus.newReport);
    });

    test('createdAt корректно парсится', () {
      final item = ReportListItem.fromJson(json);
      expect(item.createdAt, DateTime.parse('2024-03-01T09:00:00.000Z'));
    });
  });

  group('ReportDetail.fromJson', () {
    final json = {
      'id': 'r-10',
      'title': 'Не работает принтер',
      'description': 'Принтер HP в 204 аудитории выдаёт ошибку',
      'location': 'Корпус А',
      'room': '204',
      'category': 'it_equipment',
      'priority': 'high',
      'type': 'report',
      'status': 'in_progress',
      'reporter_id': 'u-5',
      'photo_url': null,
      'created_at': '2024-03-10T11:00:00.000Z',
      'updated_at': null,
    };

    test('парсит все обязательные поля', () {
      final detail = ReportDetail.fromJson(json);
      expect(detail.id, 'r-10');
      expect(detail.title, 'Не работает принтер');
      expect(detail.status, ReportStatus.inProgress);
      expect(detail.reporterId, 'u-5');
      expect(detail.room, '204');
    });

    test('null поля корректно обрабатываются', () {
      final detail = ReportDetail.fromJson(json);
      expect(detail.photoUrl, isNull);
      expect(detail.updatedAt, isNull);
    });

    test('type по умолчанию "report" если поле отсутствует', () {
      final jsonWithoutType = Map<String, dynamic>.from(json)..remove('type');
      final detail = ReportDetail.fromJson(jsonWithoutType);
      expect(detail.type, 'report');
    });
  });

  group('ReportComment.fromJson (admin)', () {
    final json = {
      'id': 'c-5',
      'report_id': 'r-10',
      'author_id': 'admin-1',
      'text': 'Передано в IT-отдел',
      'created_at': '2024-03-11T10:00:00.000Z',
    };

    test('парсит все поля корректно', () {
      final comment = ReportComment.fromJson(json);
      expect(comment.id, 'c-5');
      expect(comment.reportId, 'r-10');
      expect(comment.authorId, 'admin-1');
      expect(comment.text, 'Передано в IT-отдел');
    });
  });

  group('StatusHistoryEntry.fromJson (admin)', () {
    final json = {
      'id': 'h-3',
      'report_id': 'r-10',
      'old_status': 'new',
      'new_status': 'in_progress',
      'changed_by': 'manager-2',
      'changed_at': '2024-03-12T08:00:00.000Z',
    };

    test('парсит все поля корректно', () {
      final entry = StatusHistoryEntry.fromJson(json);
      expect(entry.id, 'h-3');
      expect(entry.oldStatus, 'new');
      expect(entry.newStatus, 'in_progress');
      expect(entry.changedBy, 'manager-2');
    });
  });
}
