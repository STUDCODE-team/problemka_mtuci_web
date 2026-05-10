import 'package:admin_panel/features/users/models/user_info.dart';
import 'package:admin_panel/features/users/repositories/users_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// --- Events ---

abstract class UsersEvent {}

class LoadUsers extends UsersEvent {}

class SetUserRole extends UsersEvent {
  final String userId;
  final String role;
  SetUserRole({required this.userId, required this.role});
}

// --- States ---

abstract class UsersState {}

class UsersInitial extends UsersState {}

class UsersLoading extends UsersState {}

class UsersLoaded extends UsersState {
  final List<UserInfo> users;
  UsersLoaded(this.users);
}

class UsersError extends UsersState {
  final String message;
  UsersError(this.message);
}

// --- BLoC ---

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final UsersRepository _repository;

  UsersBloc({required UsersRepository repository})
    : _repository = repository,
      super(UsersInitial()) {
    on<LoadUsers>(_onLoad);
    on<SetUserRole>(_onSetRole);
  }

  Future<void> _onLoad(LoadUsers event, Emitter<UsersState> emit) async {
    emit(UsersLoading());
    try {
      final users = await _repository.getUsers();
      emit(UsersLoaded(users));
    } on DioException catch (e) {
      emit(UsersError(_extractError(e)));
    }
  }

  Future<void> _onSetRole(SetUserRole event, Emitter<UsersState> emit) async {
    try {
      await _repository.setRole(event.userId, event.role);
      add(LoadUsers());
    } on DioException catch (e) {
      emit(UsersError(_extractError(e)));
      add(LoadUsers());
    }
  }

  String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final detail = data['detail'];
      if (detail is String) return detail;
    }
    return 'Ошибка соединения';
  }
}
