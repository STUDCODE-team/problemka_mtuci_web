import 'package:flutter_test/flutter_test.dart';
import 'package:client_app/features/notifications/src/models/notification.dart';
import 'package:client_app/features/reports/src/models/report.dart';

void main() {
  final baseJson = {
    'id': 'n-1',
    'reporter_id': 'u-1',
    'report_id': 'r-1',
    'report_title': 'Сломана лампа',
    'old_status': 'new',
    'new_status': 'in_progress',
    'is_read': false,
    'created_at': '2024-01-17T10:00:00.000Z',
  };

  group('AppNotification.fromJson', () {
    test('парсит все поля корректно', () {
      final notification = AppNotification.fromJson(baseJson);
      expect(notification.id, 'n-1');
      expect(notification.reporterId, 'u-1');
      expect(notification.reportId, 'r-1');
      expect(notification.reportTitle, 'Сломана лампа');
      expect(notification.oldStatus, ReportStatus.newReport);
      expect(notification.newStatus, ReportStatus.inProgress);
      expect(notification.isRead, false);
    });

    test('парсит непрочитанное уведомление', () {
      final notification = AppNotification.fromJson(baseJson);
      expect(notification.isRead, isFalse);
    });

    test('парсит прочитанное уведомление', () {
      final json = Map<String, dynamic>.from(baseJson)..['is_read'] = true;
      final notification = AppNotification.fromJson(json);
      expect(notification.isRead, isTrue);
    });

    test('createdAt корректно парсится из ISO8601', () {
      final notification = AppNotification.fromJson(baseJson);
      expect(notification.createdAt, DateTime.parse('2024-01-17T10:00:00.000Z'));
    });

    test('статусы конвертируются через ReportStatus.fromApi', () {
      final notification = AppNotification.fromJson(baseJson);
      expect(notification.oldStatus, ReportStatus.newReport);
      expect(notification.newStatus, ReportStatus.inProgress);
    });
  });

  group('AppNotification.copyWith', () {
    late AppNotification notification;

    setUp(() {
      notification = AppNotification.fromJson(baseJson);
    });

    test('copyWith(isRead: true) меняет isRead', () {
      final updated = notification.copyWith(isRead: true);
      expect(updated.isRead, isTrue);
    });

    test('copyWith(isRead: false) оставляет isRead = false', () {
      final updated = notification.copyWith(isRead: false);
      expect(updated.isRead, isFalse);
    });

    test('copyWith без аргументов сохраняет все поля', () {
      final copy = notification.copyWith();
      expect(copy.id, notification.id);
      expect(copy.reportId, notification.reportId);
      expect(copy.reportTitle, notification.reportTitle);
      expect(copy.oldStatus, notification.oldStatus);
      expect(copy.newStatus, notification.newStatus);
      expect(copy.isRead, notification.isRead);
      expect(copy.createdAt, notification.createdAt);
    });

    test('copyWith не меняет другие поля кроме isRead', () {
      final updated = notification.copyWith(isRead: true);
      expect(updated.id, notification.id);
      expect(updated.reporterId, notification.reporterId);
      expect(updated.reportId, notification.reportId);
      expect(updated.reportTitle, notification.reportTitle);
      expect(updated.oldStatus, notification.oldStatus);
      expect(updated.newStatus, notification.newStatus);
      expect(updated.createdAt, notification.createdAt);
    });
  });
}
