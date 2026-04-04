import 'package:dio/dio.dart';
import 'package:client_app/core/auth/token_repository.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final TokenRepository tokenRepository;
  final void Function() onSessionExpired;

  bool _isRefreshing = false;

  AuthInterceptor({
    required this.dio,
    required this.tokenRepository,
    required this.onSessionExpired,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = tokenRepository.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    if (_isRefreshing) {
      return handler.next(err);
    }

    _isRefreshing = true;

    try {
      final refreshToken = await tokenRepository.getRefreshToken();
      if (refreshToken == null) {
        onSessionExpired();
        return handler.next(err);
      }

      final refreshDio = Dio(BaseOptions(
        baseUrl: dio.options.baseUrl,
        headers: {'Content-Type': 'application/json'},
      ));

      final response = await refreshDio.post(
        '/api/auth/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      final newAccessToken = response.data['access_token'] as String;
      final newRefreshToken = response.data['refresh_token'] as String;

      tokenRepository.setAccessToken(newAccessToken);
      await tokenRepository.saveRefreshToken(newRefreshToken);

      // Retry original request
      final options = err.requestOptions;
      options.headers['Authorization'] = 'Bearer $newAccessToken';

      final retryResponse = await refreshDio.fetch(options);
      handler.resolve(retryResponse);
    } on DioException {
      await tokenRepository.clearAll();
      onSessionExpired();
      handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }
}
