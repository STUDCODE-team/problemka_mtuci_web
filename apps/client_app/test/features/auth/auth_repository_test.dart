import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:client_app/core/api/api_client.dart';
import 'package:client_app/core/auth/token_repository.dart';
import 'package:client_app/features/auth/src/auth_repository.dart';

class _MockInterceptor extends Interceptor {
  Response<dynamic> Function(RequestOptions)? _resolver;
  DioException Function(RequestOptions)? _errorResolver;

  void when(Response<dynamic> Function(RequestOptions) fn) => _resolver = fn;
  void whenError(DioException Function(RequestOptions) fn) => _errorResolver = fn;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_errorResolver != null) {
      handler.reject(_errorResolver!(options));
    } else if (_resolver != null) {
      handler.resolve(_resolver!(options));
    } else {
      handler.next(options);
    }
  }
}

void main() {
  late TokenRepository tokenRepo;
  late _MockInterceptor mock;
  late AuthRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    tokenRepo = TokenRepository();
    final apiClient = ApiClient(
      baseUrl: 'http://test',
      tokenRepository: tokenRepo,
      onSessionExpired: () {},
      enableTalkerLogs: false,
    );
    mock = _MockInterceptor();
    apiClient.dio.interceptors.insert(0, mock);
    repo = AuthRepository(apiClient: apiClient, tokenRepository: tokenRepo);
  });

  group('requestOtp', () {
    test('sends email and role=user in POST body', () async {
      late Map<String, dynamic> sentBody;
      mock.when((opts) {
        sentBody = opts.data as Map<String, dynamic>;
        return Response(requestOptions: opts, data: {}, statusCode: 200);
      });

      await repo.requestOtp('student@mtuci.ru');

      expect(sentBody['email'], 'student@mtuci.ru');
      expect(sentBody['role'], 'user');
    });

    test('throws DioException on network error', () async {
      mock.whenError((opts) => DioException(
            requestOptions: opts,
            type: DioExceptionType.connectionError,
          ));

      expect(() => repo.requestOtp('student@mtuci.ru'), throwsA(isA<DioException>()));
    });

    test('throws DioException with detail when email not found', () async {
      mock.whenError((opts) => DioException(
            requestOptions: opts,
            response: Response(
              requestOptions: opts,
              statusCode: 404,
              data: {'detail': 'User not found'},
            ),
            type: DioExceptionType.badResponse,
          ));

      expect(() => repo.requestOtp('unknown@test.com'), throwsA(isA<DioException>()));
    });
  });

  group('verifyOtp', () {
    test('returns AuthResult and marks session logged in', () async {
      mock.when((opts) => Response(
            requestOptions: opts,
            data: {'role': 'user'},
            statusCode: 200,
          ));

      final result = await repo.verifyOtp('student@mtuci.ru', '123456');

      expect(result.role, 'user');
      expect(tokenRepo.isLoggedIn, isTrue);
    });

    test('does not check role restriction — any role is accepted', () async {
      mock.when((opts) => Response(
            requestOptions: opts,
            data: {'role': 'admin'},
            statusCode: 200,
          ));

      final result = await repo.verifyOtp('admin@mtuci.ru', '000000');

      expect(result.role, 'admin');
      expect(tokenRepo.isLoggedIn, isTrue);
    });

    test('persists session to SharedPreferences', () async {
      mock.when((opts) => Response(
            requestOptions: opts,
            data: {'role': 'user'},
            statusCode: 200,
          ));

      await repo.verifyOtp('student@mtuci.ru', '123456');

      expect(await tokenRepo.hasPersistedSession(), isTrue);
    });

    test('sends email and code in POST body', () async {
      late Map<String, dynamic> sentBody;
      mock.when((opts) {
        sentBody = opts.data as Map<String, dynamic>;
        return Response(requestOptions: opts, data: {'role': 'user'}, statusCode: 200);
      });

      await repo.verifyOtp('student@mtuci.ru', '999888');

      expect(sentBody['email'], 'student@mtuci.ru');
      expect(sentBody['code'], '999888');
    });

    test('throws DioException on wrong code', () async {
      mock.whenError((opts) => DioException(
            requestOptions: opts,
            response: Response(
              requestOptions: opts,
              statusCode: 400,
              data: {'detail': 'Invalid code'},
            ),
            type: DioExceptionType.badResponse,
          ));

      expect(
        () => repo.verifyOtp('student@mtuci.ru', 'wrong'),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('getMe', () {
    test('returns UserInfo parsed from response', () async {
      mock.when((opts) => Response(
            requestOptions: opts,
            data: {
              'id': 'u1',
              'email': 'student@mtuci.ru',
              'role': 'user',
              'is_active': true,
              'created_at': '2024-03-01T08:00:00.000Z',
            },
            statusCode: 200,
          ));

      final user = await repo.getMe();

      expect(user.id, 'u1');
      expect(user.email, 'student@mtuci.ru');
      expect(user.role, 'user');
      expect(user.isActive, isTrue);
      expect(user.createdAt.year, 2024);
    });
  });

  group('logout', () {
    test('clears token repository after POST', () async {
      tokenRepo.setLoggedIn();
      mock.when((opts) => Response(requestOptions: opts, data: {}, statusCode: 200));

      await repo.logout();

      expect(tokenRepo.isLoggedIn, isFalse);
    });

    test('clears token even when logout POST fails', () async {
      tokenRepo.setLoggedIn();
      await tokenRepo.persistSession();
      mock.whenError((opts) => DioException(
            requestOptions: opts,
            type: DioExceptionType.connectionError,
          ));

      await repo.logout();

      expect(tokenRepo.isLoggedIn, isFalse);
      expect(await tokenRepo.hasPersistedSession(), isFalse);
    });
  });
}
