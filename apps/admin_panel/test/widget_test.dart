import 'package:flutter_test/flutter_test.dart';
import 'package:admin_panel/features/reports/models/report.dart';

// Smoke-тест: проверяет, что ключевые классы доступны и работают
void main() {
  test('ReportStatus (admin) имеет корректные значения', () {
    expect(ReportStatus.values.length, 4);
  });

  test('Конечные статусы не имеют допустимых переходов', () {
    expect(ReportStatus.resolved.allowedTransitions, isEmpty);
    expect(ReportStatus.rejected.allowedTransitions, isEmpty);
  });

  test('Начальные статусы имеют допустимые переходы', () {
    expect(ReportStatus.newReport.allowedTransitions, isNotEmpty);
    expect(ReportStatus.inProgress.allowedTransitions, isNotEmpty);
  });
}
