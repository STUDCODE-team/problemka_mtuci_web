import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:client_app/core/auth/token_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('TokenRepository — in-memory state', () {
    test('isLoggedIn is false initially', () {
      final repo = TokenRepository();
      expect(repo.isLoggedIn, isFalse);
    });

    test('setLoggedIn sets isLoggedIn to true', () {
      final repo = TokenRepository();
      repo.setLoggedIn();
      expect(repo.isLoggedIn, isTrue);
    });

    test('clearAll resets isLoggedIn to false', () async {
      final repo = TokenRepository();
      repo.setLoggedIn();
      await repo.clearAll();
      expect(repo.isLoggedIn, isFalse);
    });
  });

  group('TokenRepository — SharedPreferences', () {
    test('hasPersistedSession returns false when nothing saved', () async {
      final repo = TokenRepository();
      expect(await repo.hasPersistedSession(), isFalse);
    });

    test('persistSession saves session flag', () async {
      final repo = TokenRepository();
      await repo.persistSession();
      expect(await repo.hasPersistedSession(), isTrue);
    });

    test('persistSession stores key has_session', () async {
      final repo = TokenRepository();
      await repo.persistSession();
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('has_session'), isTrue);
    });

    test('clearAll removes persisted session', () async {
      final repo = TokenRepository();
      await repo.persistSession();
      await repo.clearAll();
      expect(await repo.hasPersistedSession(), isFalse);
    });

    test('clearAll resets both in-memory flag and persistence', () async {
      final repo = TokenRepository();
      repo.setLoggedIn();
      await repo.persistSession();

      await repo.clearAll();

      expect(repo.isLoggedIn, isFalse);
      expect(await repo.hasPersistedSession(), isFalse);
    });

    test('multiple instances share the same SharedPreferences storage', () async {
      final repo1 = TokenRepository();
      await repo1.persistSession();

      final repo2 = TokenRepository();
      expect(await repo2.hasPersistedSession(), isTrue);
    });
  });
}
