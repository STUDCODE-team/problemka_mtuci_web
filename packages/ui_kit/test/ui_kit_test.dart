import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit/ui_kit.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('AppColors', () {
    test('primaryLight is deep indigo-purple', () {
      expect(AppColors.primaryLight, const Color(0xFF372678));
    });

    test('primaryDark is indigo-purple', () {
      expect(AppColors.primaryDark, const Color(0xFF5B4FCF));
    });

    test('backgroundLight is light blue-grey', () {
      expect(AppColors.backgroundLight, const Color(0xFFEEEFF6));
    });

    test('backgroundDark is deep navy', () {
      expect(AppColors.backgroundDark, const Color(0xFF161929));
    });

    test('destructiveLight is red', () {
      expect(AppColors.destructiveLight, const Color(0xFFD4183D));
    });

    test('destructiveDark is bright red', () {
      expect(AppColors.destructiveDark, const Color(0xFFF04060));
    });

    test('legacy alias secondaryLight equals cardLight', () {
      expect(AppColors.secondaryLight, AppColors.cardLight);
    });

    test('legacy alias secondaryDark equals cardDark', () {
      expect(AppColors.secondaryDark, AppColors.cardDark);
    });

    test('light and dark primary colors differ', () {
      expect(AppColors.primaryLight, isNot(AppColors.primaryDark));
    });

    test('accentGreenLight equals accentGreenDark', () {
      expect(AppColors.accentGreenLight, AppColors.accentGreenDark);
    });
  });

  group('AppRadius', () {
    test('radiusBase is 16', () {
      expect(AppRadius.radiusBase, 16.0);
    });

    test('radiusSm is 8', () {
      expect(AppRadius.radiusSm, 8.0);
    });

    test('radiusXl is 20', () {
      expect(AppRadius.radiusXl, 20.0);
    });

    test('radiusFull is 9999', () {
      expect(AppRadius.radiusFull, 9999.0);
    });
  });

  group('PMButton', () {
    testWidgets('renders text label', (tester) async {
      await tester.pumpWidget(_wrap(PMButton(text: 'Submit', onPressed: () {})));
      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('shows CircularProgressIndicator when isLoading', (tester) async {
      await tester.pumpWidget(
        _wrap(PMButton(text: 'Submit', onPressed: () {}, isLoading: true)),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Submit'), findsNothing);
    });

    testWidgets('ElevatedButton.onPressed is null when isLoading', (tester) async {
      await tester.pumpWidget(
        _wrap(PMButton(text: 'Submit', onPressed: () {}, isLoading: true)),
      );
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('ElevatedButton.onPressed is non-null when not loading', (tester) async {
      await tester.pumpWidget(_wrap(PMButton(text: 'Go', onPressed: () {})));
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(PMButton(text: 'Go', onPressed: () => tapped = true)),
      );
      await tester.tap(find.byType(ElevatedButton));
      expect(tapped, isTrue);
    });

    testWidgets('does not call onPressed when tapped while loading', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(PMButton(text: 'Go', onPressed: () => tapped = true, isLoading: true)),
      );
      await tester.tap(find.byType(ElevatedButton), warnIfMissed: false);
      expect(tapped, isFalse);
    });
  });

  group('PMInput', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(
        _wrap(const PMInput(label: 'Email', hint: 'Enter email')),
      );
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('renders hint text', (tester) async {
      await tester.pumpWidget(
        _wrap(const PMInput(label: 'Email', hint: 'Enter your email')),
      );
      expect(find.text('Enter your email'), findsOneWidget);
    });

    testWidgets('contains a TextField', (tester) async {
      await tester.pumpWidget(
        _wrap(const PMInput(label: 'Password', hint: 'Enter password')),
      );
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('uses provided TextEditingController', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _wrap(PMInput(label: 'Email', hint: 'Enter', controller: controller)),
      );
      await tester.enterText(find.byType(TextField), 'test@example.com');
      expect(controller.text, 'test@example.com');
    });

    testWidgets('text is obscured when obscureText is true', (tester) async {
      await tester.pumpWidget(
        _wrap(const PMInput(label: 'Pass', hint: 'Password', obscureText: true)),
      );
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.obscureText, isTrue);
    });

    testWidgets('text is visible when obscureText is false (default)', (tester) async {
      await tester.pumpWidget(
        _wrap(const PMInput(label: 'Email', hint: 'Email')),
      );
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.obscureText, isFalse);
    });
  });
}
