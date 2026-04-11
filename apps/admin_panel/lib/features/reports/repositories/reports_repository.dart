import 'package:admin_panel/core/api/api_client.dart';
import 'package:admin_panel/features/reports/models/report.dart';

class ReportsRepository {
  final ApiClient _apiClient;

  ReportsRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<ReportListItem>> getReports({
    ReportStatus? status,
    int limit = 50,
    int offset = 0,
  }) async {
    final params = <String, dynamic>{'limit': limit, 'offset': offset};
    if (status != null) params['status'] = status.apiValue;

    final response = await _apiClient.dio.get(
      '/api/reports/reports/',
      queryParameters: params,
    );
    final list = response.data as List<dynamic>;
    return list
        .map((json) => ReportListItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<ReportDetail> getReportById(String id) async {
    final response = await _apiClient.dio.get('/api/reports/reports/$id');
    return ReportDetail.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ReportDetail> changeStatus(String id, ReportStatus status) async {
    final response = await _apiClient.dio.patch(
      '/api/reports/reports/$id/status',
      data: {'status': status.apiValue},
    );
    return ReportDetail.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ReportDetail> forceChangeStatus(String id, ReportStatus status) async {
    final response = await _apiClient.dio.patch(
      '/api/reports/reports/$id/status/force',
      data: {'status': status.apiValue},
    );
    return ReportDetail.fromJson(response.data as Map<String, dynamic>);
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
