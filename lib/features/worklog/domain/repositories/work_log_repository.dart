import 'package:expense_tracker/features/worklog/domain/entities/project_entity.dart';
import 'package:expense_tracker/features/worklog/domain/entities/work_log_dashboard_entity.dart';
import 'package:expense_tracker/features/worklog/domain/entities/work_log_entity.dart';

abstract class WorkLogRepository {
  // ── WorkLog CRUD ─────────────────────────────────────────────────────────
  Future<List<WorkLogEntity>> getAllWorkLogs();
  Future<WorkLogEntity> getWorkLogById(String id);
  Future<WorkLogEntity> createWorkLog(Map<String, dynamic> data);
  Future<WorkLogEntity> updateWorkLog(String id, Map<String, dynamic> data);
  Future<void> deleteWorkLog(String id);

  // ── WorkLog Filters ───────────────────────────────────────────────────────
  Future<List<WorkLogEntity>> getByStatus(int status);
  Future<List<WorkLogEntity>> getByWorkType(int workType);
  Future<List<WorkLogEntity>> getByProject(String projectId);
  Future<List<WorkLogEntity>> getByMonth(int year, int month);
  Future<List<WorkLogEntity>> getPending();
  Future<List<WorkLogEntity>> getAppliedNotPaid();

  // ── WorkLog Analytics ─────────────────────────────────────────────────────
  Future<WorkLogDashboardEntity> getDashboard();

  // ── WorkLog Status Transitions ────────────────────────────────────────────
  Future<WorkLogEntity> apply(String id);
  Future<WorkLogEntity> approve(String id);
  Future<WorkLogEntity> reject(String id);
  Future<WorkLogEntity> markPaid(String id, Map<String, dynamic> data);

  // ── Projects ──────────────────────────────────────────────────────────────
  Future<List<ProjectEntity>> getProjects();
  Future<ProjectEntity> getProjectById(String id);
  Future<ProjectEntity> createProject(Map<String, dynamic> data);
  Future<ProjectEntity> updateProject(String id, Map<String, dynamic> data);
  Future<void> deleteProject(String id);
}
