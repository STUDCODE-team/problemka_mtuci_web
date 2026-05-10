import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:client_app/features/auth/src/auth_repository.dart';
import 'package:client_app/features/auth/src/bloc/auth_bloc.dart';

// Fake реализация репозитория — имитирует поведение без реального HTTP
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

final _testUser = UserInfo(
  id: 'u-1',
  email: 'student@mtuci.ru',
  role: 'user',
  isActive: true,
  createdAt: DateTime(2024, 1, 1),
);

void main() {
  group('AuthBloc — начальное состояние', () {
    test('AuthInitial при создании', () {
      final bloc = AuthBloc(
        authRepository: _FakeAuthRepository(logout: () async {}),
      );
      expect(bloc.state, isA<AuthInitial>());
      bloc.close();
    });
  });

  group('AuthBloc — RequestOtp', () {
    test('успешный запрос: [AuthLoading, AuthCodeSent(email)]', () async {
      final bloc = AuthBloc(
        authRepository: _FakeAuthRepository(requestOtp: (_) async {}),
      );

      final future = expectLater(
        bloc.stream,
        emitsInOrder([isA<AuthLoading>(), isA<AuthCodeSent>()]),
      );

      bloc.add(AuthRequestOtp('student@mtuci.ru'));
      await future;
      await bloc.close();
    });

    test('AuthCodeSent содержит переданный email', () async {
      final bloc = AuthBloc(
        authRepository: _FakeAuthRepository(requestOtp: (_) async {}),
      );

      AuthCodeSent? codeSentState;
      bloc.stream.listen((s) {
        if (s is AuthCodeSent) codeSentState = s;
      });

      bloc.add(AuthRequestOtp('student@mtuci.ru'));
      await Future.delayed(const Duration(milliseconds: 50));
      await bloc.close();

      expect(codeSentState?.email, 'student@mtuci.ru');
    });

    test('ошибка с detail: AuthError содержит сообщение из detail', () async {
      final bloc = AuthBloc(
        authRepository: _FakeAuthRepository(
          requestOtp: (_) => Future.error(
            _dioError(data: {'detail': 'Email not found'}),
          ),
        ),
      );

      final future = expectLater(
        bloc.stream,
        emitsInOrder([isA<AuthLoading>(), isA<AuthError>()]),
      );

      bloc.add(AuthRequestOtp('unknown@mtuci.ru'));
      await future;

      expect((bloc.state as AuthError).message, 'Email not found');
      await bloc.close();
    });

    test('сетевая ошибка без detail: AuthError("Connection error")', () async {
      final bloc = AuthBloc(
        authRepository: _FakeAuthRepository(
          requestOtp: (_) => Future.error(_dioError()),
        ),
      );

      final future = expectLater(
        bloc.stream,
        emitsInOrder([isA<AuthLoading>(), isA<AuthError>()]),
      );

      bloc.add(AuthRequestOtp('student@mtuci.ru'));
      await future;

      expect((bloc.state as AuthError).message, 'Connection error');
      await bloc.close();
    });
  });

  group('AuthBloc — VerifyOtp', () {
    test('успешная верификация: [AuthLoading, AuthSuccess]', () async {
      final bloc = AuthBloc(
        authRepository: _FakeAuthRepository(
          verifyOtp: (_, __) async => AuthResult(role: 'user'),
          getMe: () async => _testUser,
        ),
      );

      final future = expectLater(
        bloc.stream,
        emitsInOrder([isA<AuthLoading>(), isA<AuthSuccess>()]),
      );

      bloc.add(AuthVerifyOtp(email: 'student@mtuci.ru', code: '123456'));
      await future;

      expect((bloc.state as AuthSuccess).user.email, 'student@mtuci.ru');
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

      bloc.add(AuthVerifyOtp(email: 'student@mtuci.ru', code: '000000'));
      await future;

      final error = bloc.state as AuthError;
      expect(error.message, 'Invalid OTP code');
      expect(error.previousEmail, 'student@mtuci.ru');
      await bloc.close();
    });
  });

  group('AuthBloc — TryAutoLogin', () {
    test('автологин успешен: [AuthLoading, AuthSuccess]', () async {
      final bloc = AuthBloc(
        authRepository: _FakeAuthRepository(
          tryAutoLogin: () async => true,
          getMe: () async => _testUser,
        ),
      );

      final future = expectLater(
        bloc.stream,
        emitsInOrder([isA<AuthLoading>(), isA<AuthSuccess>()]),
      );

      bloc.add(AuthTryAutoLogin());
      await future;

      expect((bloc.state as AuthSuccess).user.id, 'u-1');
      await bloc.close();
    });

    test('сессия не найдена: [AuthLoading, AuthInitial]', () async {
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

    test('DioException при автологине: [AuthLoading, AuthInitial]', () async {
      final bloc = AuthBloc(
        authRepository: _FakeAuthRepository(
          tryAutoLogin: () => Future.error(_dioError()),
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

  group('AuthBloc — Logout', () {
    test('выход: [AuthInitial]', () async {
      final bloc = AuthBloc(
        authRepository: _FakeAuthRepository(logout: () async {}),
      );

      final future = expectLater(
        bloc.stream,
        emits(isA<AuthInitial>()),
      );

      bloc.add(AuthLogout());
      await future;
      await bloc.close();
    });

    test('logout вызывается при выходе', () async {
      var logoutCalled = false;

      final bloc = AuthBloc(
        authRepository: _FakeAuthRepository(
          logout: () async {
            logoutCalled = true;
          },
        ),
      );

      bloc.add(AuthLogout());
      await Future.delayed(const Duration(milliseconds: 50));
      await bloc.close();

      expect(logoutCalled, isTrue);
    });
  });
}
