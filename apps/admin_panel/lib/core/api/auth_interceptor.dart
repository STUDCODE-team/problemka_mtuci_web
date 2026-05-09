import 'package:dio/dio.dart';
import 'package:admin_panel/core/auth/token_repository.dart';

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
    // Cookies are sent automatically by the browser via withCredentials
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401 || _isRefreshing) {
      return handler.next(err);
    }

    _isRefreshing = true;
    try {
      final refreshDio = Dio(BaseOptions(
        baseUrl: dio.options.baseUrl,
        headers: {'Content-Type': 'application/json'},
        extra: {'withCredentials': true},
      ));

      await refreshDio.post('/api/auth/refresh');

      final retryResponse = await dio.fetch(err.requestOptions);
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
