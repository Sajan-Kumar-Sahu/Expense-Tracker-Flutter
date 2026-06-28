import 'package:expense_tracker/dependency_injection/injection.dart';
import 'package:expense_tracker/features/worklog/domain/entities/project_entity.dart';
import 'package:expense_tracker/features/worklog/domain/entities/work_log_dashboard_entity.dart';
import 'package:expense_tracker/features/worklog/domain/entities/work_log_entity.dart';
import 'package:expense_tracker/features/worklog/domain/repositories/work_log_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── WorkLog Filter State ──────────────────────────────────────────────────────

class WorkLogFilter {
  final int? status;
  final int? workType;
  final String? projectId;
  final int? month;
  final int? year;
  final String searchQuery;

  const WorkLogFilter({
    this.status,
    this.workType,
    this.projectId,
    this.month,
    this.year,
    this.searchQuery = '',
  });

  WorkLogFilter copyWith({
    int? status,
    int? workType,
    String? projectId,
    int? month,
    int? year,
    String? searchQuery,
    bool clearStatus = false,
    bool clearWorkType = false,
    bool clearProject = false,
    bool clearMonth = false,
    bool clearYear = false,
  }) {
    return WorkLogFilter(
      status: clearStatus ? null : (status ?? this.status),
      workType: clearWorkType ? null : (workType ?? this.workType),
      projectId: clearProject ? null : (projectId ?? this.projectId),
      month: clearMonth ? null : (month ?? this.month),
      year: clearYear ? null : (year ?? this.year),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  bool get hasActiveFilters =>
      status != null ||
      workType != null ||
      projectId != null ||
      month != null ||
      year != null ||
      searchQuery.isNotEmpty;
}

// ── WorkLog List Provider ─────────────────────────────────────────────────────

class WorkLogNotifier extends ChangeNotifier {
  final WorkLogRepository repository;

  WorkLogNotifier(this.repository) {
    loadWorkLogs();
    loadDashboard();
    loadProjects();
  }

  bool isLoading = false;
  bool isDashboardLoading = false;
  bool isProjectsLoading = false;
  String? error;

  List<WorkLogEntity> workLogs = [];
  List<ProjectEntity> projects = [];
  WorkLogEntity? selectedWorkLog;
  WorkLogDashboardEntity? dashboard;
  WorkLogFilter filter = const WorkLogFilter();

  List<WorkLogEntity> get filteredWorkLogs {
    var result = workLogs;

    if (filter.status != null) {
      result = result.where((w) => w.status == filter.status).toList();
    }

    if (filter.workType != null) {
      result = result.where((w) => w.workType == filter.workType).toList();
    }

    if (filter.projectId != null && filter.projectId!.isNotEmpty) {
      result =
          result.where((w) => w.projectId == filter.projectId).toList();
    }

    if (filter.month != null || filter.year != null) {
      result = result.where((w) {
        final date = DateTime.tryParse(w.workDate);
        if (date == null) return false;
        if (filter.month != null && date.month != filter.month) return false;
        if (filter.year != null && date.year != filter.year) return false;
        return true;
      }).toList();
    }

    if (filter.searchQuery.isNotEmpty) {
      final q = filter.searchQuery.toLowerCase();
      result = result.where((w) {
        return w.taskTitle.toLowerCase().contains(q) ||
            w.projectName.toLowerCase().contains(q) ||
            (w.notes?.toLowerCase().contains(q) ?? false) ||
            (w.description?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    return result;
  }

  // ── Loads ────────────────────────────────────────────────────────────────

  Future<void> loadWorkLogs() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();
      workLogs = await repository.getAllWorkLogs();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDashboard() async {
    try {
      isDashboardLoading = true;
      notifyListeners();
      dashboard = await repository.getDashboard();
    } catch (_) {
      // Silently fail — dashboard is supplemental
    } finally {
      isDashboardLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProjects() async {
    try {
      isProjectsLoading = true;
      notifyListeners();
      projects = await repository.getProjects();
    } catch (_) {
      // Silently fail
    } finally {
      isProjectsLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadWorkLogById(String id) async {
    try {
      isLoading = true;
      notifyListeners();
      selectedWorkLog = await repository.getWorkLogById(id);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── CRUD ─────────────────────────────────────────────────────────────────

  Future<bool> createWorkLog(Map<String, dynamic> data) async {
    try {
      isLoading = true;
      notifyListeners();
      final created = await repository.createWorkLog(data);
      workLogs.insert(0, created);
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateWorkLog(String id, Map<String, dynamic> data) async {
    try {
      isLoading = true;
      notifyListeners();
      final updated = await repository.updateWorkLog(id, data);
      final index = workLogs.indexWhere((w) => w.id == id);
      if (index != -1) workLogs[index] = updated;
      if (selectedWorkLog?.id == id) selectedWorkLog = updated;
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteWorkLog(String id) async {
    try {
      isLoading = true;
      notifyListeners();
      await repository.deleteWorkLog(id);
      workLogs.removeWhere((w) => w.id == id);
      if (selectedWorkLog?.id == id) selectedWorkLog = null;
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Status Transitions ────────────────────────────────────────────────────

  Future<bool> apply(String id) async => _statusAction(id, repository.apply);
  Future<bool> approve(String id) async =>
      _statusAction(id, repository.approve);
  Future<bool> reject(String id) async => _statusAction(id, repository.reject);

  Future<bool> markPaid(String id, double actualAmount, String paymentMonth) async {
    try {
      isLoading = true;
      notifyListeners();
      final updated = await repository.markPaid(id, {
        'actualAmount': actualAmount,
        'paymentMonth': paymentMonth,
      });
      _replaceInList(updated);
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _statusAction(
      String id, Future<WorkLogEntity> Function(String) action) async {
    try {
      isLoading = true;
      notifyListeners();
      final updated = await action(id);
      _replaceInList(updated);
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _replaceInList(WorkLogEntity updated) {
    final index = workLogs.indexWhere((w) => w.id == updated.id);
    if (index != -1) workLogs[index] = updated;
    if (selectedWorkLog?.id == updated.id) selectedWorkLog = updated;
  }

  // ── Projects ──────────────────────────────────────────────────────────────

  Future<bool> createProject(String name, String? description) async {
    try {
      isLoading = true;
      notifyListeners();
      final created = await repository.createProject({
        'name': name,
        'description': description,
      });
      projects.insert(0, created);
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProject(
      String id, String name, String? description) async {
    try {
      isLoading = true;
      notifyListeners();
      final updated = await repository.updateProject(id, {
        'name': name,
        'description': description,
      });
      final index = projects.indexWhere((p) => p.id == id);
      if (index != -1) projects[index] = updated;
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProject(String id) async {
    try {
      isLoading = true;
      notifyListeners();
      await repository.deleteProject(id);
      projects.removeWhere((p) => p.id == id);
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Filter ────────────────────────────────────────────────────────────────

  void applyFilter(WorkLogFilter newFilter) {
    filter = newFilter;
    notifyListeners();
  }

  void clearFilter() {
    filter = const WorkLogFilter();
    notifyListeners();
  }

  // ── Refresh / Reset ───────────────────────────────────────────────────────

  Future<void> refresh() async {
    await Future.wait([loadWorkLogs(), loadDashboard(), loadProjects()]);
  }

  void reset() {
    workLogs = [];
    projects = [];
    selectedWorkLog = null;
    dashboard = null;
    filter = const WorkLogFilter();
    isLoading = false;
    isDashboardLoading = false;
    isProjectsLoading = false;
    error = null;
    notifyListeners();
  }
}

final workLogProvider = ChangeNotifierProvider<WorkLogNotifier>((ref) {
  return WorkLogNotifier(locator<WorkLogRepository>());
});
