import 'package:client_app/core/api/api_client.dart';
import 'package:client_app/features/notifications/src/models/notification.dart';

class NotificationsRepository {
  final ApiClient _apiClient;

  NotificationsRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<AppNotification>> fetchMyNotifications() async {
    final response = await _apiClient.dio.get('/api/reports/notifications/my');
    final list = response.data as List<dynamic>;
    return list
        .map((json) => AppNotification.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> markRead(String notificationId) async {
    await _apiClient.dio.patch('/api/reports/notifications/$notificationId/read');
  }

  Future<void> markAllRead() async {
    await _apiClient.dio.post('/api/reports/notifications/read-all');
  }
}
