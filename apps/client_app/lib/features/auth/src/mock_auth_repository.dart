class MockUser {
  final String email;
  final String name;
  final String role;

  const MockUser({required this.email, required this.name, required this.role});
}

class AuthException implements Exception {
  final String code;

  const AuthException(this.code);
}

class MockAuthRepository {
  MockAuthRepository._();

  static final MockAuthRepository instance = MockAuthRepository._();

  static const String demoCode = '123456';

  final Map<String, MockUser> _users = const {
    'student@mtuci.edu': MockUser(
      email: 'student@mtuci.edu',
      name: 'Ivan Petrov',
      role: 'student',
    ),
    'teacher@mtuci.edu': MockUser(
      email: 'teacher@mtuci.edu',
      name: 'Maria Ivanova',
      role: 'teacher',
    ),
  };

  Future<void> sendCode(String email) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!_users.containsKey(email)) {
      throw const AuthException('unknown_email');
    }
  }

  Future<MockUser> verifyCode({required String email, required String code}) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!_users.containsKey(email)) {
      throw const AuthException('unknown_email');
    }
    if (code != demoCode) {
      throw const AuthException('invalid_code');
    }
    return _users[email]!;
  }
}
