import 'package:flutter_test/flutter_test.dart';
import 'package:admin_panel/features/users/models/user_info.dart';

void main() {
  group('UserInfo.fromJson', () {
    final fullJson = {
      'id': 'u-1',
      'email': 'admin@mtuci.ru',
      'role': 'admin',
      'is_active': true,
      'created_at': '2024-01-01T00:00:00.000Z',
    };

    test('парсит все поля корректно', () {
      final user = UserInfo.fromJson(fullJson);
      expect(user.id, 'u-1');
      expect(user.email, 'admin@mtuci.ru');
      expect(user.role, 'admin');
      expect(user.isActive, true);
    });

    test('createdAt корректно парсится из ISO8601', () {
      final user = UserInfo.fromJson(fullJson);
      expect(user.createdAt, DateTime.parse('2024-01-01T00:00:00.000Z'));
    });

    test('роль manager парсится корректно', () {
      final json = Map<String, dynamic>.from(fullJson)..['role'] = 'manager';
      final user = UserInfo.fromJson(json);
      expect(user.role, 'manager');
    });

    test('роль user парсится корректно', () {
      final json = Map<String, dynamic>.from(fullJson)..['role'] = 'user';
      final user = UserInfo.fromJson(json);
      expect(user.role, 'user');
    });

    test('isActive = false парсится корректно', () {
      final json = Map<String, dynamic>.from(fullJson)..['is_active'] = false;
      final user = UserInfo.fromJson(json);
      expect(user.isActive, false);
    });
  });
}
