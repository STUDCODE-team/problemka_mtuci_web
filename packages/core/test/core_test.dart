import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:core/core.dart';
import 'package:responsive_framework/responsive_framework.dart';

void main() {
  group('ResponsiveApp', () {
    testWidgets('renders its child widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ResponsiveApp(child: Text('Hello')),
        ),
      );
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('wraps child with ResponsiveBreakpoints', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ResponsiveApp(child: SizedBox()),
        ),
      );
      expect(find.byType(ResponsiveBreakpoints), findsOneWidget);
    });
  });

  group('Responsive extension', () {
    testWidgets('isMobileDevice, isTabletDevice, isDesktopDevice return bool values',
        (tester) async {
      bool? isMobile;
      bool? isTablet;
      bool? isDesktop;

      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveApp(
            child: Builder(
              builder: (context) {
                isMobile = context.isMobileDevice;
                isTablet = context.isTabletDevice;
                isDesktop = context.isDesktopDevice;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(isMobile, isNotNull);
      expect(isTablet, isNotNull);
      expect(isDesktop, isNotNull);
      // All values are booleans
      expect(isMobile, isA<bool>());
      expect(isTablet, isA<bool>());
      expect(isDesktop, isA<bool>());
    });

    testWidgets('isMobile/isTablet/isDesktop are mutually exclusive', (tester) async {
      bool? isMobile;
      bool? isTablet;
      bool? isDesktop;

      await tester.pumpWidget(
        MaterialApp(
          home: ResponsiveApp(
            child: Builder(
              builder: (context) {
                isMobile = context.isMobileDevice;
                isTablet = context.isTabletDevice;
                isDesktop = context.isDesktopDevice;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      // At most one can be true at any given screen width
      final trueCount = [isMobile!, isTablet!, isDesktop!].where((v) => v).length;
      expect(trueCount, lessThanOrEqualTo(1));
    });
  });
}
