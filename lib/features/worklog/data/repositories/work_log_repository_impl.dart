import 'package:expense_tracker/features/worklog/data/datasources/work_log_remote_data_source.dart';
import 'package:expense_tracker/features/worklog/domain/entities/project_entity.dart';
import 'package:expense_tracker/features/worklog/domain/entities/work_log_dashboard_entity.dart';
import 'package:expense_tracker/features/worklog/domain/entities/work_log_entity.dart';
import 'package:expense_tracker/features/worklog/domain/repositories/work_log_repository.dart';

class WorkLogRepositoryImpl implements WorkLogRepository {
  final WorkLogRemoteDataSource remoteDataSource;

  WorkLogRepositoryImpl(this.remoteDataSource);

  // ── WorkLog CRUD ─────────────────────────────────────────────────────────

  @override
  Future<List<WorkLogEntity>> getAllWorkLogs() async {
    return await remoteDataSource.getAllWorkLogs();
  }

  @override
  Future<WorkLogEntity> getWorkLogById(String id) async {
    return await remoteDataSource.getWorkLogById(id);
  }

  @override
  Future<WorkLogEntity> createWorkLog(Map<String, dynamic> data) async {
    return await remoteDataSource.createWorkLog(data);
  }

  @override
  Future<WorkLogEntity> updateWorkLog(String id, Map<String, dynamic> data) async {
    return await remoteDataSource.updateWorkLog(id, data);
  }

  @override
  Future<void> deleteWorkLog(String id) async {
    await remoteDataSource.deleteWorkLog(id);
  }

  // ── WorkLog Filters ───────────────────────────────────────────────────────

  @override
  Future<List<WorkLogEntity>> getByStatus(int status) async {
    return await remoteDataSource.getByStatus(status);
  }

  @override
  Future<List<WorkLogEntity>> getByWorkType(int workType) async {
    return await remoteDataSource.getByWorkType(workType);
  }

  @override
  Future<List<WorkLogEntity>> getByProject(String projectId) async {
    return await remoteDataSource.getByProject(projectId);
  }

  @override
  Future<List<WorkLogEntity>> getByMonth(int year, int month) async {
    return await remoteDataSource.getByMonth(year, month);
  }

  @override
  Future<List<WorkLogEntity>> getPending() async {
    return await remoteDataSource.getPending();
  }

  @override
  Future<List<WorkLogEntity>> getAppliedNotPaid() async {
    return await remoteDataSource.getAppliedNotPaid();
  }

  // ── WorkLog Analytics ─────────────────────────────────────────────────────

  @override
  Future<WorkLogDashboardEntity> getDashboard() async {
    return await remoteDataSource.getDashboard();
  }

  // ── WorkLog Status Transitions ────────────────────────────────────────────

  @override
  Future<WorkLogEntity> apply(String id) async {
    return await remoteDataSource.apply(id);
  }

  @override
  Future<WorkLogEntity> approve(String id) async {
    return await remoteDataSource.approve(id);
  }

  @override
  Future<WorkLogEntity> reject(String id) async {
    return await remoteDataSource.reject(id);
  }

  @override
  Future<WorkLogEntity> markPaid(String id, Map<String, dynamic> data) async {
    return await remoteDataSource.markPaid(id, data);
  }

  // ── Projects ──────────────────────────────────────────────────────────────

  @override
  Future<List<ProjectEntity>> getProjects() async {
    return await remoteDataSource.getProjects();
  }

  @override
  Future<ProjectEntity> getProjectById(String id) async {
    return await remoteDataSource.getProjectById(id);
  }

  @override
  Future<ProjectEntity> createProject(Map<String, dynamic> data) async {
    return await remoteDataSource.createProject(data);
  }

  @override
  Future<ProjectEntity> updateProject(String id, Map<String, dynamic> data) async {
    return await remoteDataSource.updateProject(id, data);
  }

  @override
  Future<void> deleteProject(String id) async {
    await remoteDataSource.deleteProject(id);
  }
}
