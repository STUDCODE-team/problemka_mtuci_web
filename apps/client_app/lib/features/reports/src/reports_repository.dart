import 'package:client_app/core/api/api_client.dart';
import 'package:client_app/features/reports/src/models/report.dart';

class ReportsRepository {
  final ApiClient _apiClient;

  ReportsRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<Report>> fetchMyReports({
    ReportStatus? status,
    int limit = 50,
    int offset = 0,
  }) async {
    final params = <String, dynamic>{
      'limit': limit,
      'offset': offset,
    };
    if (status != null) {
      params['status'] = status.apiValue;
    }

    final response = await _apiClient.dio.get(
      '/api/reports/reports/my',
      queryParameters: params,
    );
    final list = response.data as List<dynamic>;
    return list.map((json) => Report.fromListJson(json as Map<String, dynamic>)).toList();
  }

  Future<Report> getById(String id) async {
    final response = await _apiClient.dio.get('/api/reports/reports/$id');
    return Report.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Report> createReport({
    required String title,
    required String description,
    required String location,
    String? room,
    required String category,
    String priority = 'medium',
    String type = 'report',
  }) async {
    final response = await _apiClient.dio.post('/api/reports/reports/', data: {
      'title': title,
      'description': description,
      'location': location,
      'room': room,
      'category': category,
      'priority': priority,
      'type': type,
    });
    return Report.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Report> updateReport({
    required String reportId,
    String? title,
    String? description,
    String? location,
    String? room,
    String? category,
  }) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (location != null) data['location'] = location;
    if (room != null) data['room'] = room;
    if (category != null) data['category'] = category;

    final response = await _apiClient.dio.patch(
      '/api/reports/reports/$reportId',
      data: data,
    );
    return Report.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<ReportComment>> getComments(String reportId) async {
    final response = await _apiClient.dio.get('/api/reports/reports/$reportId/comments');
    final list = response.data as List<dynamic>;
    return list.map((json) => ReportComment.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<ReportComment> addComment(String reportId, String text) async {
    final response = await _apiClient.dio.post(
      '/api/reports/reports/$reportId/comments',
      data: {'text': text},
    );
    return ReportComment.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<StatusHistoryEntry>> getStatusHistory(String reportId) async {
    final response = await _apiClient.dio.get('/api/reports/reports/$reportId/history');
    final list = response.data as List<dynamic>;
    return list.map((json) => StatusHistoryEntry.fromJson(json as Map<String, dynamic>)).toList();
  }
}
