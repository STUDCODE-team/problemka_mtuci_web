import 'package:flutter_test/flutter_test.dart';
import 'package:client_app/features/reports/src/models/report.dart';

// Smoke-тест: проверяет, что ключевые классы доступны для импорта
void main() {
  test('ReportStatus доступен и имеет корректные значения', () {
    expect(ReportStatus.values.length, 4);
    expect(ReportStatus.values, contains(ReportStatus.newReport));
    expect(ReportStatus.values, contains(ReportStatus.inProgress));
    expect(ReportStatus.values, contains(ReportStatus.resolved));
    expect(ReportStatus.values, contains(ReportStatus.rejected));
  });

  test('ReportCategory имеет все ожидаемые категории', () {
    expect(ReportCategory.values.length, 7);
    expect(
      ReportCategory.values.map((c) => c.apiValue),
      containsAll([
        'electrical', 'plumbing', 'furniture',
        'it_equipment', 'cleaning', 'heating', 'other',
      ]),
    );
  });
}
