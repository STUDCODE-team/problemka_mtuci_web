import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_app/features/auth/src/auth_repository.dart';

// --- Events ---

abstract class AuthEvent {}

class AuthRequestOtp extends AuthEvent {
  final String email;
  AuthRequestOtp(this.email);
}

class AuthVerifyOtp extends AuthEvent {
  final String email;
  final String code;
  AuthVerifyOtp({required this.email, required this.code});
}

class AuthTryAutoLogin extends AuthEvent {}

class AuthLogout extends AuthEvent {}

// --- States ---

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthCodeSent extends AuthState {
  final String email;
  AuthCodeSent(this.email);
}

class AuthSuccess extends AuthState {
  final UserInfo user;
  AuthSuccess(this.user);
}

class AuthError extends AuthState {
  final String message;
  final String? previousEmail;
  AuthError(this.message, {this.previousEmail});
}

// --- BLoC ---

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<AuthRequestOtp>(_onRequestOtp);
    on<AuthVerifyOtp>(_onVerifyOtp);
    on<AuthTryAutoLogin>(_onTryAutoLogin);
    on<AuthLogout>(_onLogout);
  }

  Future<void> _onRequestOtp(AuthRequestOtp event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.requestOtp(event.email);
      emit(AuthCodeSent(event.email));
    } on DioException catch (e) {
      final message = _extractError(e);
      emit(AuthError(message));
    }
  }

  Future<void> _onVerifyOtp(AuthVerifyOtp event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.verifyOtp(event.email, event.code);
      final user = await _authRepository.getMe();
      emit(AuthSuccess(user));
    } on DioException catch (e) {
      final message = _extractError(e);
      emit(AuthError(message, previousEmail: event.email));
    }
  }

  Future<void> _onTryAutoLogin(AuthTryAutoLogin event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final success = await _authRepository.tryAutoLogin();
      if (success) {
        final user = await _authRepository.getMe();
        emit(AuthSuccess(user));
      } else {
        emit(AuthInitial());
      }
    } on DioException {
      emit(AuthInitial());
    }
  }

  Future<void> _onLogout(AuthLogout event, Emitter<AuthState> emit) async {
    await _authRepository.logout();
    emit(AuthInitial());
  }

  String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic> && data.containsKey('detail')) {
      return data['detail'] as String;
    }
    return 'Connection error';
  }
}
