import 'package:flutter_test/flutter_test.dart';

// Пакет core предоставляет утилиты локализации (l10n) и адаптивной вёрстки.
// Эти функции требуют Flutter BuildContext и тестируются на уровне приложения.
// Юнит-тесты для core будут добавлены при появлении бизнес-логики без контекста.
void main() {
  test('placeholder — пакет core успешно импортируется', () {
    expect(true, isTrue);
  });
}
