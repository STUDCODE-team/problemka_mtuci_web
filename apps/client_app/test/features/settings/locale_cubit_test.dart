import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:client_app/features/settings/src/locale_cubit.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  group('LocaleCubit — начальное состояние', () {
    test('начальное состояние null (системная локаль)', () async {
      final cubit = LocaleCubit();
      await Future.delayed(Duration.zero);
      expect(cubit.state, isNull);
      cubit.close();
    });

    test('загружает сохранённую русскую локаль', () async {
      SharedPreferences.setMockInitialValues({'locale': 'ru'});

      final cubit = LocaleCubit();
      await Future.delayed(Duration.zero);

      expect(cubit.state, const Locale('ru'));
      cubit.close();
    });

    test('загружает сохранённую английскую локаль', () async {
      SharedPreferences.setMockInitialValues({'locale': 'en'});

      final cubit = LocaleCubit();
      await Future.delayed(Duration.zero);

      expect(cubit.state, const Locale('en'));
      cubit.close();
    });
  });

  group('LocaleCubit — setLocale', () {
    test('setLocale(ru) устанавливает русскую локаль', () async {
      final cubit = LocaleCubit();
      await Future.delayed(Duration.zero);

      await cubit.setLocale(const Locale('ru'));
      expect(cubit.state, const Locale('ru'));
      cubit.close();
    });

    test('setLocale(en) устанавливает английскую локаль', () async {
      final cubit = LocaleCubit();
      await Future.delayed(Duration.zero);

      await cubit.setLocale(const Locale('en'));
      expect(cubit.state, const Locale('en'));
      cubit.close();
    });

    test('setLocale сохраняет languageCode в SharedPreferences', () async {
      final cubit = LocaleCubit();
      await Future.delayed(Duration.zero);

      await cubit.setLocale(const Locale('ru'));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('locale'), 'ru');
      cubit.close();
    });

    test('смена локали с ru на en обновляет состояние', () async {
      final cubit = LocaleCubit();
      await Future.delayed(Duration.zero);

      await cubit.setLocale(const Locale('ru'));
      expect(cubit.state, const Locale('ru'));

      await cubit.setLocale(const Locale('en'));
      expect(cubit.state, const Locale('en'));
      cubit.close();
    });
  });
}
