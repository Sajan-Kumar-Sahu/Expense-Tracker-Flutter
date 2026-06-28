import 'package:expense_tracker/core/constants/api_endpoints.dart';
import 'package:expense_tracker/core/network/api_client.dart';
import '../models/project_model.dart';
import '../models/work_log_dashboard_model.dart';
import '../models/work_log_model.dart';

abstract class WorkLogRemoteDataSource {
  // WorkLog CRUD
  Future<List<WorkLogModel>> getAllWorkLogs();
  Future<WorkLogModel> getWorkLogById(String id);
  Future<WorkLogModel> createWorkLog(Map<String, dynamic> data);
  Future<WorkLogModel> updateWorkLog(String id, Map<String, dynamic> data);
  Future<void> deleteWorkLog(String id);

  // WorkLog Filters
  Future<List<WorkLogModel>> getByStatus(int status);
  Future<List<WorkLogModel>> getByWorkType(int workType);
  Future<List<WorkLogModel>> getByProject(String projectId);
  Future<List<WorkLogModel>> getByMonth(int year, int month);
  Future<List<WorkLogModel>> getPending();
  Future<List<WorkLogModel>> getAppliedNotPaid();

  // WorkLog Analytics
  Future<WorkLogDashboardModel> getDashboard();

  // WorkLog Status
  Future<WorkLogModel> apply(String id);
  Future<WorkLogModel> approve(String id);
  Future<WorkLogModel> reject(String id);
  Future<WorkLogModel> markPaid(String id, Map<String, dynamic> data);

  // Projects
  Future<List<ProjectModel>> getProjects();
  Future<ProjectModel> getProjectById(String id);
  Future<ProjectModel> createProject(Map<String, dynamic> data);
  Future<ProjectModel> updateProject(String id, Map<String, dynamic> data);
  Future<void> deleteProject(String id);
}

class WorkLogRemoteDataSourceImpl implements WorkLogRemoteDataSource {
  final ApiClient apiClient;

  WorkLogRemoteDataSourceImpl(this.apiClient);

  // ── WorkLog CRUD ─────────────────────────────────────────────────────────

  @override
  Future<List<WorkLogModel>> getAllWorkLogs() async {
    final response = await apiClient.get(ApiEndpoints.workLogs);
    final List<dynamic> list = response.data['data'] as List<dynamic>;
    return list
        .map((e) => WorkLogModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<WorkLogModel> getWorkLogById(String id) async {
    final response =
        await apiClient.get('${ApiEndpoints.workLogs}/$id');
    return WorkLogModel.fromJson(
        response.data!['data'] as Map<String, dynamic>);
  }

  @override
  Future<WorkLogModel> createWorkLog(Map<String, dynamic> data) async {
    final response =
        await apiClient.post(ApiEndpoints.workLogs, data: data);
    return WorkLogModel.fromJson(
        response.data!['data'] as Map<String, dynamic>);
  }

  @override
  Future<WorkLogModel> updateWorkLog(
      String id, Map<String, dynamic> data) async {
    final response =
        await apiClient.put('${ApiEndpoints.workLogs}/$id', data: data);
    return WorkLogModel.fromJson(
        response.data!['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteWorkLog(String id) async {
    await apiClient.delete('${ApiEndpoints.workLogs}/$id');
  }

  // ── WorkLog Filters ───────────────────────────────────────────────────────

  @override
  Future<List<WorkLogModel>> getByStatus(int status) async {
    final response =
        await apiClient.get('${ApiEndpoints.workLogs}/status/$status');
    final List<dynamic> list = response.data['data'] as List<dynamic>;
    return list
        .map((e) => WorkLogModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<WorkLogModel>> getByWorkType(int workType) async {
    final response =
        await apiClient.get('${ApiEndpoints.workLogs}/worktype/$workType');
    final List<dynamic> list = response.data['data'] as List<dynamic>;
    return list
        .map((e) => WorkLogModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<WorkLogModel>> getByProject(String projectId) async {
    final response =
        await apiClient.get('${ApiEndpoints.workLogs}/project/$projectId');
    final List<dynamic> list = response.data['data'] as List<dynamic>;
    return list
        .map((e) => WorkLogModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<WorkLogModel>> getByMonth(int year, int month) async {
    final response =
        await apiClient.get('${ApiEndpoints.workLogs}/month/$year/$month');
    final List<dynamic> list = response.data['data'] as List<dynamic>;
    return list
        .map((e) => WorkLogModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<WorkLogModel>> getPending() async {
    final response =
        await apiClient.get('${ApiEndpoints.workLogs}/pending');
    final List<dynamic> list = response.data['data'] as List<dynamic>;
    return list
        .map((e) => WorkLogModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<WorkLogModel>> getAppliedNotPaid() async {
    final response =
        await apiClient.get('${ApiEndpoints.workLogs}/applied-not-paid');
    final List<dynamic> list = response.data['data'] as List<dynamic>;
    return list
        .map((e) => WorkLogModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── WorkLog Analytics ─────────────────────────────────────────────────────

  @override
  Future<WorkLogDashboardModel> getDashboard() async {
    final response =
        await apiClient.get('${ApiEndpoints.workLogs}/dashboard');
    return WorkLogDashboardModel.fromJson(
        response.data!['data'] as Map<String, dynamic>);
  }

  // ── WorkLog Status Transitions ────────────────────────────────────────────

  @override
  Future<WorkLogModel> apply(String id) async {
    final response =
        await apiClient.post('${ApiEndpoints.workLogs}/$id/apply');
    return WorkLogModel.fromJson(
        response.data!['data'] as Map<String, dynamic>);
  }

  @override
  Future<WorkLogModel> approve(String id) async {
    final response =
        await apiClient.post('${ApiEndpoints.workLogs}/$id/approve');
    return WorkLogModel.fromJson(
        response.data!['data'] as Map<String, dynamic>);
  }

  @override
  Future<WorkLogModel> reject(String id) async {
    final response =
        await apiClient.post('${ApiEndpoints.workLogs}/$id/reject');
    return WorkLogModel.fromJson(
        response.data!['data'] as Map<String, dynamic>);
  }

  @override
  Future<WorkLogModel> markPaid(String id, Map<String, dynamic> data) async {
    final response =
        await apiClient.post('${ApiEndpoints.workLogs}/$id/mark-paid', data: data);
    return WorkLogModel.fromJson(
        response.data!['data'] as Map<String, dynamic>);
  }

  // ── Projects ──────────────────────────────────────────────────────────────

  @override
  Future<List<ProjectModel>> getProjects() async {
    final response = await apiClient.get(ApiEndpoints.projects);
    final List<dynamic> list = response.data['data'] as List<dynamic>;
    return list
        .map((e) => ProjectModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ProjectModel> getProjectById(String id) async {
    final response =
        await apiClient.get('${ApiEndpoints.projects}/$id');
    return ProjectModel.fromJson(
        response.data!['data'] as Map<String, dynamic>);
  }

  @override
  Future<ProjectModel> createProject(Map<String, dynamic> data) async {
    final response =
        await apiClient.post(ApiEndpoints.projects, data: data);
    return ProjectModel.fromJson(
        response.data!['data'] as Map<String, dynamic>);
  }

  @override
  Future<ProjectModel> updateProject(
      String id, Map<String, dynamic> data) async {
    final response =
        await apiClient.put('${ApiEndpoints.projects}/$id', data: data);
    return ProjectModel.fromJson(
        response.data!['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteProject(String id) async {
    await apiClient.delete('${ApiEndpoints.projects}/$id');
  }
}
