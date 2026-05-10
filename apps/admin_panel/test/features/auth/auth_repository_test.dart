import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:admin_panel/core/api/api_client.dart';
import 'package:admin_panel/core/auth/token_repository.dart';
import 'package:admin_panel/features/auth/src/auth_repository.dart';

// Intercepts requests before they reach the network. Inserted at position 0
// in ApiClient.dio so it takes precedence over AuthInterceptor.
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
    test('sends email and role=admin in POST body', () async {
      late Map<String, dynamic> sentBody;
      mock.when((opts) {
        sentBody = opts.data as Map<String, dynamic>;
        return Response(requestOptions: opts, data: {}, statusCode: 200);
      });

      await repo.requestOtp('user@test.com');

      expect(sentBody['email'], 'user@test.com');
      expect(sentBody['role'], 'admin');
    });

    test('throws DioException on network error', () async {
      mock.whenError((opts) => DioException(
            requestOptions: opts,
            type: DioExceptionType.connectionError,
          ));

      expect(() => repo.requestOtp('user@test.com'), throwsA(isA<DioException>()));
    });
  });

  group('verifyOtp', () {
    test('returns AuthResult(role=admin) and marks session logged in', () async {
      mock.when((opts) => Response(
            requestOptions: opts,
            data: {'role': 'admin'},
            statusCode: 200,
          ));

      final result = await repo.verifyOtp('user@test.com', '123456');

      expect(result.role, 'admin');
      expect(tokenRepo.isLoggedIn, isTrue);
    });

    test('returns AuthResult(role=manager) for manager role', () async {
      mock.when((opts) => Response(
            requestOptions: opts,
            data: {'role': 'manager'},
            statusCode: 200,
          ));

      final result = await repo.verifyOtp('user@test.com', '000000');

      expect(result.role, 'manager');
      expect(tokenRepo.isLoggedIn, isTrue);
    });

    test('throws DioException when server returns role=user (access denied)', () async {
      mock.when((opts) => Response(
            requestOptions: opts,
            data: {'role': 'user'},
            statusCode: 200,
          ));

      expect(
        () => repo.verifyOtp('user@test.com', '123456'),
        throwsA(isA<DioException>()),
      );
    });

    test('persists session to SharedPreferences on success', () async {
      mock.when((opts) => Response(
            requestOptions: opts,
            data: {'role': 'admin'},
            statusCode: 200,
          ));

      await repo.verifyOtp('user@test.com', '123456');

      expect(await tokenRepo.hasPersistedSession(), isTrue);
    });

    test('sends email and code in POST body', () async {
      late Map<String, dynamic> sentBody;
      mock.when((opts) {
        sentBody = opts.data as Map<String, dynamic>;
        return Response(requestOptions: opts, data: {'role': 'admin'}, statusCode: 200);
      });

      await repo.verifyOtp('admin@test.com', '999888');

      expect(sentBody['email'], 'admin@test.com');
      expect(sentBody['code'], '999888');
    });
  });

  group('getMe', () {
    test('returns UserInfo parsed from response', () async {
      mock.when((opts) => Response(
            requestOptions: opts,
            data: {
              'id': 'u1',
              'email': 'admin@test.com',
              'role': 'admin',
              'is_active': true,
              'created_at': '2024-01-15T10:00:00.000Z',
            },
            statusCode: 200,
          ));

      final user = await repo.getMe();

      expect(user.id, 'u1');
      expect(user.email, 'admin@test.com');
      expect(user.role, 'admin');
      expect(user.isActive, isTrue);
      expect(user.createdAt, DateTime.parse('2024-01-15T10:00:00.000Z'));
    });

    test('throws DioException on server error', () async {
      mock.whenError((opts) => DioException(
            requestOptions: opts,
            response: Response(
              requestOptions: opts,
              statusCode: 500,
              data: {'detail': 'Internal server error'},
            ),
            type: DioExceptionType.badResponse,
          ));

      expect(() => repo.getMe(), throwsA(isA<DioException>()));
    });
  });

  group('logout', () {
    test('clears token repository after successful logout', () async {
      tokenRepo.setLoggedIn();
      mock.when((opts) => Response(requestOptions: opts, data: {}, statusCode: 200));

      await repo.logout();

      expect(tokenRepo.isLoggedIn, isFalse);
    });

    test('clears token repository even when POST throws', () async {
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
