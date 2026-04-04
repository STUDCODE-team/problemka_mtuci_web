import 'package:dio/dio.dart';
import 'package:client_app/core/api/auth_interceptor.dart';
import 'package:client_app/core/auth/token_repository.dart';

class ApiClient {
  late final Dio dio;
  final TokenRepository tokenRepository;
  final void Function() onSessionExpired;

  ApiClient({
    required String baseUrl,
    required this.tokenRepository,
    required this.onSessionExpired,
  }) {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(AuthInterceptor(
      dio: dio,
      tokenRepository: tokenRepository,
      onSessionExpired: onSessionExpired,
    ));
  }
}
