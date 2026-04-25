import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:admin_panel/core/api/api_client.dart';
import 'package:admin_panel/core/auth/token_repository.dart';
import 'package:admin_panel/features/users/repositories/users_repository.dart';

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

final _userJson = {
  'id': 'u1',
  'email': 'user@test.com',
  'role': 'user',
  'is_active': true,
  'created_at': '2024-01-01T00:00:00.000Z',
};

final _managerJson = {
  'id': 'u1',
  'email': 'user@test.com',
  'role': 'manager',
  'is_active': true,
  'created_at': '2024-01-01T00:00:00.000Z',
};

void main() {
  late _MockInterceptor mock;
  late UsersRepository repo;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    final tokenRepo = TokenRepository();
    final apiClient = ApiClient(
      baseUrl: 'http://test',
      tokenRepository: tokenRepo,
      onSessionExpired: () {},
      enableTalkerLogs: false,
    );
    mock = _MockInterceptor();
    apiClient.dio.interceptors.insert(0, mock);
    repo = UsersRepository(apiClient: apiClient);
  });

  group('getUsers', () {
    test('returns list of UserInfo parsed from JSON', () async {
      mock.when((opts) => Response(
            requestOptions: opts,
            data: [_userJson],
            statusCode: 200,
          ));

      final users = await repo.getUsers();

      expect(users, hasLength(1));
      expect(users.first.id, 'u1');
      expect(users.first.email, 'user@test.com');
      expect(users.first.role, 'user');
      expect(users.first.isActive, isTrue);
    });

    test('returns empty list when API returns []', () async {
      mock.when((opts) => Response(requestOptions: opts, data: [], statusCode: 200));

      final users = await repo.getUsers();

      expect(users, isEmpty);
    });

    test('returns multiple users', () async {
      mock.when((opts) => Response(
            requestOptions: opts,
            data: [_userJson, {..._userJson, 'id': 'u2', 'email': 'u2@test.com'}],
            statusCode: 200,
          ));

      final users = await repo.getUsers();

      expect(users, hasLength(2));
    });

    test('makes GET to /api/auth/auth/users', () async {
      late String requestPath;
      mock.when((opts) {
        requestPath = opts.path;
        return Response(requestOptions: opts, data: [], statusCode: 200);
      });

      await repo.getUsers();

      expect(requestPath, '/api/auth/auth/users');
    });

    test('throws DioException on server error', () async {
      mock.whenError((opts) => DioException(
            requestOptions: opts,
            type: DioExceptionType.badResponse,
            response: Response(requestOptions: opts, statusCode: 403),
          ));

      expect(() => repo.getUsers(), throwsA(isA<DioException>()));
    });
  });

  group('getUserById', () {
    test('returns UserInfo for given id', () async {
      mock.when((opts) => Response(
            requestOptions: opts,
            data: _userJson,
            statusCode: 200,
          ));

      final user = await repo.getUserById('u1');

      expect(user.id, 'u1');
      expect(user.email, 'user@test.com');
    });

    test('makes GET to correct path', () async {
      late String requestPath;
      mock.when((opts) {
        requestPath = opts.path;
        return Response(requestOptions: opts, data: _userJson, statusCode: 200);
      });

      await repo.getUserById('abc-999');

      expect(requestPath, '/api/auth/auth/users/abc-999');
    });
  });

  group('setRole', () {
    test('sends role in PATCH body', () async {
      late Map<String, dynamic> sentBody;
      mock.when((opts) {
        sentBody = opts.data as Map<String, dynamic>;
        return Response(requestOptions: opts, data: _managerJson, statusCode: 200);
      });

      await repo.setRole('u1', 'manager');

      expect(sentBody['role'], 'manager');
    });

    test('returns updated UserInfo with new role', () async {
      mock.when((opts) => Response(
            requestOptions: opts,
            data: _managerJson,
            statusCode: 200,
          ));

      final user = await repo.setRole('u1', 'manager');

      expect(user.role, 'manager');
    });

    test('makes PATCH to correct path', () async {
      late String requestPath;
      late String requestMethod;
      mock.when((opts) {
        requestPath = opts.path;
        requestMethod = opts.method;
        return Response(requestOptions: opts, data: _managerJson, statusCode: 200);
      });

      await repo.setRole('u1', 'manager');

      expect(requestPath, '/api/auth/auth/users/u1/role');
      expect(requestMethod, 'PATCH');
    });

    test('throws DioException when user not found', () async {
      mock.whenError((opts) => DioException(
            requestOptions: opts,
            type: DioExceptionType.badResponse,
            response: Response(requestOptions: opts, statusCode: 404),
          ));

      expect(() => repo.setRole('non-existent', 'manager'), throwsA(isA<DioException>()));
    });
  });
}
