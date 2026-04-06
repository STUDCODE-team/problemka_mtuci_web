import 'package:dio/dio.dart';
import 'package:client_app/core/api/auth_interceptor.dart';
import 'package:client_app/core/auth/token_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:talker/talker.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

class ApiClient {
  late final Dio dio;
  final TokenRepository tokenRepository;
  final void Function() onSessionExpired;
  final Talker? talker;

  ApiClient({
    required String baseUrl,
    required this.tokenRepository,
    required this.onSessionExpired,
    this.talker,
    bool enableTalkerLogs = kDebugMode,
    TalkerDioLoggerSettings? talkerDioLoggerSettings,
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

    if (enableTalkerLogs) {
      dio.interceptors.add(TalkerDioLogger(
        talker: talker,
        settings: talkerDioLoggerSettings ??
            const TalkerDioLoggerSettings(
              printResponseTime: true,
              hiddenHeaders: <String>{
                'authorization',
                'cookie',
                'set-cookie',
              },
            ),
      ));
    }
  }
}
