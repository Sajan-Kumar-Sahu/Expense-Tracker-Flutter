import 'package:expense_tracker/features/worklog/presentation/providers/work_log_provider.dart';
import 'package:expense_tracker/features/worklog/presentation/widgets/work_log_card.dart';
import 'package:expense_tracker/features/worklog/presentation/widgets/work_log_filter_sheet.dart';
import 'package:expense_tracker/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class WorkLogListPage extends ConsumerStatefulWidget {
  const WorkLogListPage({super.key});

  @override
  ConsumerState<WorkLogListPage> createState() => _WorkLogListPageState();
}

class _WorkLogListPageState extends ConsumerState<WorkLogListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    Future.microtask(() {
      if (!mounted) return;
      final p = ref.read(workLogProvider);
      p.loadWorkLogs();
      p.loadProjects();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final provider = ref.read(workLogProvider);
    provider.applyFilter(
        provider.filter.copyWith(searchQuery: _searchController.text));
  }

  Future<void> _onRefresh() async {
    _searchController.clear();
    ref.read(workLogProvider).clearFilter();
    await ref.read(workLogProvider).refresh();
  }

  void _openFilterSheet() {
    final provider = ref.read(workLogProvider);
    final projects = provider.projects
        .where((p) => p.isActive)
        .map((p) => (id: p.id, name: p.name))
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WorkLogFilterSheet(
        currentFilter: provider.filter,
        projects: projects,
        onApply: (filter) {
          // Preserve search query
          provider.applyFilter(
            filter.copyWith(searchQuery: _searchController.text),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(workLogProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final filtered = provider.filteredWorkLogs;
    final hasFilters = provider.filter.hasActiveFilters;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Work Log',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 26.sp,
                        ),
                      ),
                      Text(
                        'Overtime & Extra Hours',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: -0.2, end: 0, duration: 400.ms),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          '${filtered.length} entries',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                      SizedBox(width: 8.w),
                      // Projects button
                      GestureDetector(
                        onTap: () => context.push(AppRouter.workLogProjects),
                        child: Container(
                          width: 36.r,
                          height: 36.r,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Icon(Icons.folder_rounded,
                              size: 18.r,
                              color: theme.colorScheme.primary),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      // Dashboard button
                      GestureDetector(
                        onTap: () =>
                            context.push(AppRouter.workLogDashboard),
                        child: Container(
                          width: 36.r,
                          height: 36.r,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Icon(Icons.dashboard_rounded,
                              size: 18.r,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // ── Search + Filter ─────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search work logs...',
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.4),
                          size: 20.r,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  _searchController.clear();
                                },
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 18.r,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.4),
                                ),
                              )
                            : null,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 12.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.r),
                          borderSide: BorderSide(
                              color: theme.colorScheme.primary, width: 1.5),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFF1F5F9),
                        hintStyle: TextStyle(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.4),
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  GestureDetector(
                    onTap: _openFilterSheet,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 46.r,
                      height: 46.r,
                      decoration: BoxDecoration(
                        color: hasFilters
                            ? theme.colorScheme.primary
                            : (isDark
                                ? const Color(0xFF1E293B)
                                : Colors.white),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: hasFilters
                              ? theme.colorScheme.primary
                              : (isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE2E8F0)),
                        ),
                      ),
                      child: Icon(
                        Icons.filter_list_rounded,
                        size: 20.r,
                        color: hasFilters
                            ? Colors.white
                            : theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 150.ms, duration: 400.ms)
                .slideY(begin: 0.1, end: 0, delay: 150.ms, duration: 400.ms),

            // Active filter chips row
            if (hasFilters) ...[
              SizedBox(height: 10.h),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: [
                    _buildActiveFilterChip(
                      context,
                      'Clear Filters',
                      Icons.clear_rounded,
                      onTap: () {
                        _searchController.clear();
                        ref.read(workLogProvider).clearFilter();
                      },
                      isDestructive: true,
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 12.h),

            // ── List ────────────────────────────────────────────────────────
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.error != null
                      ? _ErrorState(
                          message: provider.error!,
                          onRetry: () => ref.read(workLogProvider).refresh(),
                        )
                      : RefreshIndicator(
                          onRefresh: _onRefresh,
                          color: theme.colorScheme.primary,
                          child: filtered.isEmpty
                              ? _EmptyState(
                                  hasFilter: hasFilters || _searchController.text.isNotEmpty,
                                  onAdd: () async {
                                    await context.push(AppRouter.addWorkLog);
                                    if (mounted) ref.read(workLogProvider).loadWorkLogs();
                                  },
                                )
                              : ListView.builder(
                                  padding: EdgeInsets.fromLTRB(
                                      20.w, 0, 20.w, 110.h),
                                  physics:
                                      const AlwaysScrollableScrollPhysics(
                                    parent: BouncingScrollPhysics(),
                                  ),
                                  itemCount: filtered.length,
                                  itemBuilder: (context, index) {
                                    return WorkLogCard(
                                      workLog: filtered[index],
                                      index: index,
                                      onTap: () async {
                                        await context.push(
                                          AppRouter.workLogDetails,
                                          extra: filtered[index].id,
                                        );
                                        if (mounted) ref.read(workLogProvider).loadWorkLogs();
                                      },
                                    );
                                  },
                                ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 80.h),
        child: FloatingActionButton.extended(
          onPressed: () async {
            await context.push(AppRouter.addWorkLog);
            if (mounted) ref.read(workLogProvider).loadWorkLogs();
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Entry'),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
        ),
      ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.5, end: 0),
    );
  }

  Widget _buildActiveFilterChip(
    BuildContext context,
    String label,
    IconData icon, {
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isDestructive
              ? theme.colorScheme.error.withValues(alpha: 0.1)
              : theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14.r,
              color: isDestructive
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
            ),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: isDestructive
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool hasFilter;
  final VoidCallback onAdd;

  const _EmptyState({required this.hasFilter, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      children: [
        SizedBox(height: 80.h),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80.r,
                height: 80.r,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  hasFilter
                      ? Icons.search_off_rounded
                      : Icons.work_outline_rounded,
                  size: 36.r,
                  color: theme.colorScheme.primary.withValues(alpha: 0.4),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                hasFilter ? 'No results found' : 'No work logs yet',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                hasFilter
                    ? 'Try adjusting your filters'
                    : 'Start tracking your overtime hours',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                ),
                textAlign: TextAlign.center,
              ),
              if (!hasFilter) ...[
                SizedBox(height: 24.h),
                FilledButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Work Log'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── Error State ───────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 48.r,
              color: theme.colorScheme.error.withValues(alpha: 0.4),
            ),
            SizedBox(height: 16.h),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
