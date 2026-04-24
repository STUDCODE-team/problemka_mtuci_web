import 'package:admin_panel/features/users/bloc/users_bloc.dart';
import 'package:admin_panel/features/users/models/user_info.dart';
import 'package:admin_panel/features/users/repositories/users_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeUsersRepository implements UsersRepository {
  Future<List<UserInfo>> Function()? onGetUsers;
  Future<UserInfo> Function(String id)? onGetUserById;
  Future<UserInfo> Function(String id, String role)? onSetRole;

  // ignore: unused_element_parameter
  _FakeUsersRepository({this.onGetUsers, this.onGetUserById, this.onSetRole});

  @override
  Future<List<UserInfo>> getUsers() => onGetUsers?.call() ?? Future.value([]);

  @override
  Future<UserInfo> getUserById(String userId) =>
      onGetUserById?.call(userId) ?? Future.error(StateError('not configured'));

  @override
  Future<UserInfo> setRole(String userId, String role) =>
      onSetRole?.call(userId, role) ?? Future.error(StateError('not configured'));
}

UserInfo _makeUser({String id = 'u-1', String role = 'user'}) => UserInfo(
  id: id,
  email: '$id@mtuci.ru',
  role: role,
  isActive: true,
  createdAt: DateTime(2024, 1, 1),
);

DioException _dioError({Map<String, dynamic>? data}) => DioException(
  requestOptions: RequestOptions(path: ''),
  response: data != null
      ? Response(
          requestOptions: RequestOptions(path: ''),
          data: data,
          statusCode: 400,
        )
      : null,
);

void main() {
  group('UsersBloc — начальное состояние', () {
    test('UsersInitial при создании', () {
      final bloc = UsersBloc(repository: _FakeUsersRepository());
      expect(bloc.state, isA<UsersInitial>());
      bloc.close();
    });
  });

  group('UsersBloc — LoadUsers', () {
    test('успешная загрузка: [UsersLoading, UsersLoaded]', () async {
      final users = [_makeUser(id: 'u-1'), _makeUser(id: 'u-2', role: 'admin')];

      final bloc = UsersBloc(repository: _FakeUsersRepository(onGetUsers: () async => users));

      final future = expectLater(
        bloc.stream,
        emitsInOrder([isA<UsersLoading>(), isA<UsersLoaded>()]),
      );

      bloc.add(LoadUsers());
      await future;

      expect((bloc.state as UsersLoaded).users.length, 2);
      await bloc.close();
    });

    test('список пользователей содержит корректные данные', () async {
      final users = [_makeUser(id: 'u-1', role: 'manager')];

      final bloc = UsersBloc(repository: _FakeUsersRepository(onGetUsers: () async => users));

      final future = expectLater(
        bloc.stream,
        emitsInOrder([isA<UsersLoading>(), isA<UsersLoaded>()]),
      );

      bloc.add(LoadUsers());
      await future;

      final loaded = bloc.state as UsersLoaded;
      expect(loaded.users.first.role, 'manager');
      await bloc.close();
    });

    test('ошибка с detail: [UsersLoading, UsersError(message)]', () async {
      final bloc = UsersBloc(
        repository: _FakeUsersRepository(
          onGetUsers: () => Future.error(_dioError(data: {'detail': 'Access denied'})),
        ),
      );

      final future = expectLater(
        bloc.stream,
        emitsInOrder([isA<UsersLoading>(), isA<UsersError>()]),
      );

      bloc.add(LoadUsers());
      await future;

      expect((bloc.state as UsersError).message, 'Access denied');
      await bloc.close();
    });

    test('сетевая ошибка: UsersError("Ошибка соединения")', () async {
      final bloc = UsersBloc(
        repository: _FakeUsersRepository(onGetUsers: () => Future.error(_dioError())),
      );

      final future = expectLater(
        bloc.stream,
        emitsInOrder([isA<UsersLoading>(), isA<UsersError>()]),
      );

      bloc.add(LoadUsers());
      await future;

      expect((bloc.state as UsersError).message, 'Ошибка соединения');
      await bloc.close();
    });
  });

  group('UsersBloc — SetUserRole', () {
    test('успешное назначение роли перезагружает список', () async {
      var setRoleCalled = false;

      final bloc = UsersBloc(
        repository: _FakeUsersRepository(
          onSetRole: (id, role) async {
            setRoleCalled = true;
            return _makeUser(id: id, role: role);
          },
          onGetUsers: () async => [_makeUser(id: 'u-1', role: 'manager')],
        ),
      );

      final future = expectLater(
        bloc.stream,
        emitsInOrder([isA<UsersLoading>(), isA<UsersLoaded>()]),
      );

      bloc.add(SetUserRole(userId: 'u-1', role: 'manager'));
      await future;

      expect(setRoleCalled, isTrue);
      await bloc.close();
    });

    test('ошибка назначения роли: [UsersError, затем перезагрузка]', () async {
      final bloc = UsersBloc(
        repository: _FakeUsersRepository(
          onSetRole: (_, __) => Future.error(_dioError(data: {'detail': 'Cannot change role'})),
          onGetUsers: () async => [],
        ),
      );

      final future = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<UsersError>(),
          isA<UsersLoading>(), // перезагрузка после ошибки
          isA<UsersLoaded>(),
        ]),
      );

      bloc.add(SetUserRole(userId: 'u-1', role: 'admin'));
      await future;

      expect((bloc.state as UsersLoaded).users, isEmpty);
      await bloc.close();
    });
  });
}
