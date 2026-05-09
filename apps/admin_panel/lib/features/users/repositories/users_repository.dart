import 'package:admin_panel/core/api/api_client.dart';
import 'package:admin_panel/features/users/models/user_info.dart';

class UsersRepository {
  final ApiClient _apiClient;

  UsersRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<UserInfo>> getUsers() async {
    final response = await _apiClient.dio.get('/api/auth/users');
    final list = response.data as List<dynamic>;
    return list
        .map((json) => UserInfo.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<UserInfo> getUserById(String userId) async {
    final response = await _apiClient.dio.get('/api/auth/users/$userId');
    return UserInfo.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserInfo> setRole(String userId, String role) async {
    final response = await _apiClient.dio.patch(
      '/api/auth/users/$userId/role',
      data: {'role': role},
    );
    return UserInfo.fromJson(response.data as Map<String, dynamic>);
  }
}
