import 'package:dio/dio.dart';
import 'package:admin_panel/core/api/api_client.dart';
import 'package:admin_panel/core/auth/token_repository.dart';

class AuthResult {
  final String role;
  const AuthResult({required this.role});
}

class UserInfo {
  final String id;
  final String email;
  final String role;
  final bool isActive;
  final DateTime createdAt;

  const UserInfo({
    required this.id,
    required this.email,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class AuthRepository {
  final ApiClient _apiClient;
  final TokenRepository _tokenRepository;

  AuthRepository({
    required ApiClient apiClient,
    required TokenRepository tokenRepository,
  })  : _apiClient = apiClient,
        _tokenRepository = tokenRepository;

  Future<void> requestOtp(String email) async {
    await _apiClient.dio.post('/api/auth/request_otp', data: {
      'email': email,
      'role': 'admin',
    });
  }

  Future<AuthResult> verifyOtp(String email, String code) async {
    final response = await _apiClient.dio.post('/api/auth/verify_otp', data: {
      'email': email,
      'code': code,
    });

    final data = response.data as Map<String, dynamic>;
    final role = data['role'] as String;

    if (role != 'admin' && role != 'manager') {
      throw DioException(
        requestOptions: RequestOptions(),
        message: 'Access denied: admin or manager role required',
      );
    }

    // Tokens are now in HttpOnly cookies set by the server
    _tokenRepository.setLoggedIn();
    await _tokenRepository.persistSession();
    return AuthResult(role: role);
  }

  Future<UserInfo> getMe() async {
    final response = await _apiClient.dio.get('/api/auth/me');
    return UserInfo.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> logout() async {
    try {
      await _apiClient.dio.post('/api/auth/logout');
    } on DioException {
      // ignore
    } finally {
      await _tokenRepository.clearAll();
    }
  }

  Future<bool> tryAutoLogin() async {
    try {
      final refreshDio = Dio(BaseOptions(
        baseUrl: _apiClient.dio.options.baseUrl,
        headers: {'Content-Type': 'application/json'},
        extra: {'withCredentials': true},
      ));
      await refreshDio.post('/api/auth/refresh');
      _tokenRepository.setLoggedIn();
      return true;
    } on DioException {
      await _tokenRepository.clearAll();
      return false;
    }
  }
}
