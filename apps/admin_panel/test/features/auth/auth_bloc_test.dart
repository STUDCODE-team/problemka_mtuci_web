import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:admin_panel/features/auth/src/auth_repository.dart';
import 'package:admin_panel/features/auth/src/bloc/auth_bloc.dart';

class _FakeAuthRepository implements AuthRepository {
  final Future<void> Function(String email)? _requestOtp;
  final Future<AuthResult> Function(String email, String code)? _verifyOtp;
  final Future<UserInfo> Function()? _getMe;
  final Future<void> Function()? _logout;
  final Future<bool> Function()? _tryAutoLogin;

  _FakeAuthRepository({
    Future<void> Function(String)? requestOtp,
    Future<AuthResult> Function(String, String)? verifyOtp,
    Future<UserInfo> Function()? getMe,
    Future<void> Function()? logout,
    Future<bool> Function()? tryAutoLogin,
  })  : _requestOtp = requestOtp,
        _verifyOtp = verifyOtp,
        _getMe = getMe,
        _logout = logout,
        _tryAutoLogin = tryAutoLogin;

  @override
  Future<void> requestOtp(String email) =>
      _requestOtp?.call(email) ?? Future.error(_notSet('requestOtp'));

  @override
  Future<AuthResult> verifyOtp(String email, String code) =>
      _verifyOtp?.call(email, code) ?? Future.error(_notSet('verifyOtp'));

  @override
  Future<UserInfo> getMe() =>
      _getMe?.call() ?? Future.error(_notSet('getMe'));

  @override
  Future<void> logout() => _logout?.call() ?? Future.value();

  @override
  Future<bool> tryAutoLogin() =>
      _tryAutoLogin?.call() ?? Future.value(false);

  static StateError _notSet(String method) =>
      StateError('$method not configured in _FakeAuthRepository');
}

DioException _dioError({Map<String, dynamic>? data, String? message}) {
  return DioException(
    requestOptions: RequestOptions(path: ''),
    response: data != null
        ? Response(
            requestOptions: RequestOptions(path: ''),
            data: data,
            statusCode: 400,
          )
        : null,
    message: message,
  );
}

final _adminUser = UserInfo(
  id: 'admin-1',
  email: 'admin@mtuci.ru',
  role: 'admin',
  isActive: true,
  createdAt: DateTime(2024, 1, 1),
);

void main() {
  group('AuthBloc (admin) — начальное состояние', () {
    test('AuthInitial при создании', () {
      final bloc = AuthBloc(
        authRepository: _FakeAuthRepository(logout: () async {}),
      );
      expect(bloc.state, isA<AuthInitial>());
      bloc.close();
    });
  });

  group('AuthBloc (admin) — RequestOtp', () {
    test('успешный запрос: [AuthLoading, AuthCodeSent(email)]', () async {
      final bloc = AuthBloc(
        authRepository: _FakeAuthRepository(requestOtp: (_) async {}),
      );

      final future = expectLater(
        bloc.stream,
        emitsInOrder([isA<AuthLoading>(), isA<AuthCodeSent>()]),
      );

      bloc.add(AuthRequestOtp('admin@mtuci.ru'));
      await future;

      expect((bloc.state as AuthCodeSent).email, 'admin@mtuci.ru');
      await bloc.close();
    });

    test('ошибка с detail: AuthError(detail)', () async {
      final bloc = AuthBloc(
        authRepository: _FakeAuthRepository(
          requestOtp: (_) => Future.error(
            _dioError(data: {'detail': 'User not found'}),
          ),
        ),
      );

      final future = expectLater(
        bloc.stream,
        emitsInOrder([isA<AuthLoading>(), isA<AuthError>()]),
      );

      bloc.add(AuthRequestOtp('unknown@mtuci.ru'));
      await future;

      expect((bloc.state as AuthError).message, 'User not found');
      await bloc.close();
    });

    test('сетевая ошибка без detail и без message: AuthError("Ошибка соединения")', () async {
      final bloc = AuthBloc(
        authRepository: _FakeAuthRepository(
          requestOtp: (_) => Future.error(_dioError()),
        ),
      );

      final future = expectLater(
        bloc.stream,
        emitsInOrder([isA<AuthLoading>(), isA<AuthError>()]),
      );

      bloc.add(AuthRequestOtp('admin@mtuci.ru'));
      await future;

      expect((bloc.state as AuthError).message, 'Ошибка соединения');
      await bloc.close();
    });

    test('ошибка с message: AuthError возвращает message', () async {
      final bloc = AuthBloc(
        authRepository: _FakeAuthRepository(
          requestOtp: (_) => Future.error(
            _dioError(message: 'Connection timeout'),
          ),
        ),
      );

      final future = expectLater(
        bloc.stream,
        emitsInOrder([isA<AuthLoading>(), isA<AuthError>()]),
      );

      bloc.add(AuthRequestOtp('admin@mtuci.ru'));
      await future;

      expect((bloc.state as AuthError).message, 'Connection timeout');
      await bloc.close();
    });
  });

  group('AuthBloc (admin) — VerifyOtp', () {
    test('успешная верификация admin: [AuthLoading, AuthSuccess]', () async {
      final bloc = AuthBloc(
        authRepository: _FakeAuthRepository(
          verifyOtp: (_, __) async => AuthResult(role: 'admin'),
          getMe: () async => _adminUser,
        ),
      );

      final future = expectLater(
        bloc.stream,
        emitsInOrder([isA<AuthLoading>(), isA<AuthSuccess>()]),
      );

      bloc.add(AuthVerifyOtp(email: 'admin@mtuci.ru', code: '123456'));
      await future;

      expect((bloc.state as AuthSuccess).user.role, 'admin');
      await bloc.close();
    });

    test('неверный код: AuthError с previousEmail', () async {
      final bloc = AuthBloc(
        authRepository: _FakeAuthRepository(
          verifyOtp: (_, __) => Future.error(
            _dioError(data: {'detail': 'Invalid OTP code'}),
          ),
        ),
      );

      final future = expectLater(
        bloc.stream,
        emitsInOrder([isA<AuthLoading>(), isA<AuthError>()]),
      );

      bloc.add(AuthVerifyOtp(email: 'admin@mtuci.ru', code: '999999'));
      await future;

      final error = bloc.state as AuthError;
      expect(error.message, 'Invalid OTP code');
      expect(error.previousEmail, 'admin@mtuci.ru');
      await bloc.close();
    });
  });

  group('AuthBloc (admin) — TryAutoLogin', () {
    test('автологин успешен: [AuthLoading, AuthSuccess]', () async {
      final bloc = AuthBloc(
        authRepository: _FakeAuthRepository(
          tryAutoLogin: () async => true,
          getMe: () async => _adminUser,
        ),
      );

      final future = expectLater(
        bloc.stream,
        emitsInOrder([isA<AuthLoading>(), isA<AuthSuccess>()]),
      );

      bloc.add(AuthTryAutoLogin());
      await future;
      await bloc.close();
    });

    test('сессия истекла: [AuthLoading, AuthInitial]', () async {
      final bloc = AuthBloc(
        authRepository: _FakeAuthRepository(
          tryAutoLogin: () async => false,
        ),
      );

      final future = expectLater(
        bloc.stream,
        emitsInOrder([isA<AuthLoading>(), isA<AuthInitial>()]),
      );

      bloc.add(AuthTryAutoLogin());
      await future;
      await bloc.close();
    });
  });

  group('AuthBloc (admin) — Logout', () {
    test('выход: [AuthInitial]', () async {
      var logoutCalled = false;

      final bloc = AuthBloc(
        authRepository: _FakeAuthRepository(
          logout: () async {
            logoutCalled = true;
          },
        ),
      );

      final future = expectLater(
        bloc.stream,
        emits(isA<AuthInitial>()),
      );

      bloc.add(AuthLogout());
      await future;

      expect(logoutCalled, isTrue);
      await bloc.close();
    });
  });
}
