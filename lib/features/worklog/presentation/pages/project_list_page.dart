import 'package:expense_tracker/features/worklog/domain/entities/project_entity.dart';
import 'package:expense_tracker/features/worklog/presentation/providers/work_log_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Project management page — similar to AccountListPage / CategoryListPage.
class ProjectListPage extends ConsumerStatefulWidget {
  const ProjectListPage({super.key});

  @override
  ConsumerState<ProjectListPage> createState() => _ProjectListPageState();
}

class _ProjectListPageState extends ConsumerState<ProjectListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) ref.read(workLogProvider).loadProjects();
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(workLogProvider).loadProjects();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(workLogProvider);
    final theme = Theme.of(context);
    final projects = provider.projects;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: FilledButton.icon(
              onPressed: () => _showAddEditDialog(context, ref, null),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add'),
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
      ),
      body: provider.isProjectsLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _onRefresh,
              color: theme.colorScheme.primary,
              child: projects.isEmpty
                  ? _EmptyState(
                      onAdd: () => _showAddEditDialog(context, ref, null))
                  : ListView.builder(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                      itemCount: projects.length,
                      itemBuilder: (context, index) {
                        return _ProjectCard(
                          project: projects[index],
                          index: index,
                          onEdit: () => _showAddEditDialog(
                              context, ref, projects[index]),
                          onDelete: () =>
                              _confirmDelete(context, ref, projects[index]),
                        );
                      },
                    ),
            ),
    );
  }

  void _showAddEditDialog(
      BuildContext context, WidgetRef ref, ProjectEntity? project) {
    final nameController =
        TextEditingController(text: project?.name ?? '');
    final descController =
        TextEditingController(text: project?.description ?? '');
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r)),
          title: Text(project == null ? 'Add Project' : 'Edit Project'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Project Name',
                    prefixIcon: Icon(Icons.folder_rounded),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Enter project name'
                      : null,
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: descController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialog(() => isLoading = true);

                      bool success;
                      if (project == null) {
                        success = await ref.read(workLogProvider).createProject(
                              nameController.text.trim(),
                              descController.text.trim().isEmpty
                                  ? null
                                  : descController.text.trim(),
                            );
                      } else {
                        success = await ref.read(workLogProvider).updateProject(
                              project.id,
                              nameController.text.trim(),
                              descController.text.trim().isEmpty
                                  ? null
                                  : descController.text.trim(),
                            );
                      }
                      setDialog(() => isLoading = false);

                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success
                              ? project == null
                                  ? 'Project created'
                                  : 'Project updated'
                              : 'Failed'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r)),
                        ),
                      );
                    },
              child: isLoading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.onPrimary),
                    )
                  : Text(project == null ? 'Create' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, ProjectEntity project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: const Text('Delete Project'),
        content: Text(
            'Delete "${project.name}"? This won\'t delete associated work logs.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    final success =
        await ref.read(workLogProvider).deleteProject(project.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Project deleted' : 'Failed to delete project'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r)),
        backgroundColor: success ? null : Theme.of(context).colorScheme.error,
      ),
    );
  }
}

// ── Project Card ─────────────────────────────────────────────────────────────

class _ProjectCard extends StatelessWidget {
  final ProjectEntity project;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProjectCard({
    required this.project,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(13.r),
            ),
            child: Icon(
              Icons.folder_rounded,
              color: theme.colorScheme.primary,
              size: 22.r,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.name,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (project.description != null &&
                    project.description!.isNotEmpty) ...[
                  SizedBox(height: 3.h),
                  Text(
                    project.description!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.5),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: 4.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: project.isActive
                        ? const Color(0xFF10B981).withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    project.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: project.isActive
                          ? const Color(0xFF10B981)
                          : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit_outlined,
                    size: 18.r,
                    color: theme.colorScheme.primary.withValues(alpha: 0.7)),
                onPressed: onEdit,
                visualDensity: VisualDensity.compact,
              ),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded,
                    size: 18.r,
                    color: theme.colorScheme.error.withValues(alpha: 0.7)),
                onPressed: onDelete,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
            delay: Duration(milliseconds: index * 60 + 200), duration: 400.ms)
        .slideY(
          begin: 0.06,
          end: 0,
          delay: Duration(milliseconds: index * 60 + 200),
          duration: 400.ms,
        );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      children: [
        SizedBox(height: 80.h),
        Center(
          child: Column(
            children: [
              Container(
                width: 72.r,
                height: 72.r,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.folder_open_rounded,
                  size: 32.r,
                  color: theme.colorScheme.primary.withValues(alpha: 0.4),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'No projects yet',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 8.h),
              Text(
                'Create a project to group your work logs',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                ),
              ),
              SizedBox(height: 24.h),
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Project'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
