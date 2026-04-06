import 'package:dio/dio.dart';
import 'package:client_app/core/api/api_client.dart';
import 'package:client_app/core/auth/token_repository.dart';

class AuthResult {
  final String accessToken;
  final String refreshToken;
  final String role;

  const AuthResult({
    required this.accessToken,
    required this.refreshToken,
    required this.role,
  });
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
    await _apiClient.dio.post('/api/auth/auth/request_otp', data: {
      'email': email,
      'role': 'user',
    });
  }

  Future<AuthResult> verifyOtp(String email, String code) async {
    final response = await _apiClient.dio.post('/api/auth/auth/verify_otp', data: {
      'email': email,
      'code': code,
    });

    final data = response.data as Map<String, dynamic>;
    final result = AuthResult(
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String,
      role: data['role'] as String,
    );

    await _tokenRepository.setAccessToken(result.accessToken);
    await _tokenRepository.saveRefreshToken(result.refreshToken);

    return result;
  }

  Future<UserInfo> getMe() async {
    final response = await _apiClient.dio.get('/api/auth/auth/me');
    return UserInfo.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _tokenRepository.getRefreshToken();
      if (refreshToken != null) {
        await _apiClient.dio.post('/api/auth/auth/logout', data: {
          'refresh_token': refreshToken,
        });
      }
    } on DioException {
      // Ignore errors during logout
    } finally {
      await _tokenRepository.clearAll();
    }
  }

  Future<bool> tryAutoLogin() async {
    final refreshToken = await _tokenRepository.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final refreshDio = Dio(BaseOptions(
        baseUrl: _apiClient.dio.options.baseUrl,
        headers: {'Content-Type': 'application/json'},
      ));

      final response = await refreshDio.post('/api/auth/auth/refresh', data: {
        'refresh_token': refreshToken,
      });

      final data = response.data as Map<String, dynamic>;
      await _tokenRepository.setAccessToken(data['access_token'] as String);
      await _tokenRepository.saveRefreshToken(data['refresh_token'] as String);
      return true;
    } on DioException {
      await _tokenRepository.clearAll();
      return false;
    }
  }
}
