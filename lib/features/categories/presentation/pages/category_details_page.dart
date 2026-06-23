import 'package:expense_tracker/core/utils/app_refresh.dart';
import 'package:expense_tracker/features/categories/presentation/providers/categories_provider.dart';
import 'package:expense_tracker/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/category_entity.dart';

class CategoryDetailsPage extends ConsumerStatefulWidget {
  final CategoryEntity category;
  const CategoryDetailsPage({super.key, required this.category});

  @override
  ConsumerState<CategoryDetailsPage> createState() =>
      _CategoryDetailsPageState();
}

class _CategoryDetailsPageState extends ConsumerState<CategoryDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final category = widget.category;
    final colorScheme = Theme.of(context).colorScheme;
    final typeColor = _typeColor(category.categoryType);
    final typeIcon = _typeIcon(category.categoryType);
    final typeLabel = _typeLabel(category.categoryType);

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: CustomScrollView(
        slivers: [
          // ── Collapsing Hero ─────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200.h,
            pinned: true,
            backgroundColor: colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: _CircleIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () => context.pop(),
            ),
            actions: [
              _CircleIconButton(
                icon: Icons.edit_outlined,
                onTap: () =>
                    context.push(AppRouter.editCategory, extra: category),
              ),
              SizedBox(width: 6.w),
              _CircleIconButton(
                icon: Icons.delete_outline_rounded,
                onTap: () => _confirmDelete(context),
                isDestructive: true,
              ),
              SizedBox(width: 12.w),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                width: double.infinity,
                color: colorScheme.surface,
                padding: EdgeInsets.fromLTRB(20.w, 90.h, 20.w, 20.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type badge pill
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(typeIcon, size: 12.sp, color: typeColor),
                          SizedBox(width: 4.w),
                          Text(
                            typeLabel,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: typeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    // Category name large
                    Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 38.sp,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                        letterSpacing: -1,
                        height: 1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      typeLabel,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: colorScheme.onSurface.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Body ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 48.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stat chips row
                  Row(
                    children: [
                      Expanded(
                        child: _StatChip(
                          label: 'Type',
                          value: typeLabel,
                          iconData: typeIcon,
                          iconBg: typeColor.withValues(alpha: 0.12),
                          iconColor: typeColor,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _StatChip(
                          label: 'Status',
                          value: category.isActive ? 'Active' : 'Inactive',
                          iconData: category.isActive
                              ? Icons.check_circle_outline_rounded
                              : Icons.cancel_outlined,
                          iconBg: category.isActive
                              ? const Color(0xFFE1F5EE)
                              : const Color(0xFFFCEBEB),
                          iconColor: category.isActive
                              ? const Color(0xFF0F6E56)
                              : const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  // Category details section
                  _SectionLabel(label: 'Category details'),
                  SizedBox(height: 10.h),
                  _DetailCard(
                    children: [
                      _DetailRow(
                        iconData: Icons.label_outline_rounded,
                        iconBg: const Color(0xFFEEEDFE),
                        iconColor: const Color(0xFF534AB7),
                        label: 'Name',
                        value: category.name,
                      ),
                      _CardDivider(),
                      _DetailRow(
                        iconData: Icons.swap_horiz_rounded,
                        iconBg: const Color(0xFFE1F5EE),
                        iconColor: const Color(0xFF0F6E56),
                        label: 'Type',
                        value: typeLabel,
                        valueColor: typeColor,
                      ),
                      _CardDivider(),
                      _DetailRow(
                        iconData: Icons.toggle_on_outlined,
                        iconBg: category.isActive
                            ? const Color(0xFFE1F5EE)
                            : const Color(0xFFFCEBEB),
                        iconColor: category.isActive
                            ? const Color(0xFF0F6E56)
                            : const Color(0xFFEF4444),
                        label: 'Status',
                        value: category.isActive ? 'Active' : 'Inactive',
                        valueColor: category.isActive
                            ? const Color(0xFF0F6E56)
                            : const Color(0xFFEF4444),
                      ),
                    ],
                  ),

                  // Description section
                  if (category.description != null &&
                      category.description!.isNotEmpty) ...[
                    SizedBox(height: 24.h),
                    _SectionLabel(label: 'Description'),
                    SizedBox(height: 10.h),
                    _NotesCard(notes: category.description!),
                  ],

                  SizedBox(height: 24.h),

                  // Timeline section
                  _SectionLabel(label: 'Timeline'),
                  SizedBox(height: 10.h),
                  _DetailCard(
                    children: [
                      _DetailRow(
                        iconData: Icons.calendar_today_outlined,
                        iconBg: const Color(0xFFE6F1FB),
                        iconColor: const Color(0xFF185FA5),
                        label: 'Created at',
                        value: DateFormat('dd MMM yyyy · hh:mm a')
                            .format(category.createdAt.toLocal()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _typeLabel(int type) {
    switch (type) {
      case 1:
        return 'Income';
      case 2:
        return 'Expense';
      default:
        return 'Other';
    }
  }

  IconData _typeIcon(int type) {
    switch (type) {
      case 1:
        return Icons.trending_up_rounded;
      case 2:
        return Icons.trending_down_rounded;
      default:
        return Icons.label_rounded;
    }
  }

  Color _typeColor(int type) {
    switch (type) {
      case 1:
        return const Color(0xFF10B981);
      case 2:
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6366F1);
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: const Text('Delete category'),
        content: Text(
          'Are you sure you want to delete "${widget.category.name}"? This action cannot be undone.',
        ),
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

    final success = await ref
        .read(categoriesProvider)
        .deleteCategory(widget.category.id);

    if (!mounted) return;

    if (success) await refreshAll(ref);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Category deleted' : 'Failed to delete category',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );

    if (success) context.go(AppRouter.home);
  }
}

// ---------------------------------------------------------------------------
// Circle icon button (AppBar actions)
// ---------------------------------------------------------------------------

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.r,
        height: 36.r,
        decoration: BoxDecoration(
          color: isDestructive
              ? colorScheme.error.withValues(alpha: 0.08)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18.sp,
          color: isDestructive
              ? colorScheme.error
              : colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stat chip
// ---------------------------------------------------------------------------

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData iconData;
  final Color iconBg;
  final Color iconColor;

  const _StatChip({
    required this.label,
    required this.value,
    required this.iconData,
    required this.iconBg,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(iconData, size: 18.sp, color: iconColor),
          ),
          SizedBox(height: 12.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: colorScheme.onSurface.withValues(alpha: 0.45),
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Detail card + rows
// ---------------------------------------------------------------------------

class _DetailCard extends StatelessWidget {
  final List<Widget> children;
  const _DetailCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Column(children: children),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData iconData;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.iconData,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(iconData, size: 17.sp, color: iconColor),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: colorScheme.onSurface.withValues(alpha: 0.45),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 0,
      thickness: 0.5,
      indent: 64.w,
      color: Theme.of(context)
          .colorScheme
          .outlineVariant
          .withValues(alpha: 0.5),
    );
  }
}

// ---------------------------------------------------------------------------
// Notes card
// ---------------------------------------------------------------------------

class _NotesCard extends StatelessWidget {
  final String notes;
  const _NotesCard({required this.notes});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: const Color(0xFFF1EFE8),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.notes_rounded,
              size: 17.sp,
              color: const Color(0xFF5F5E5A),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              notes,
              style: TextStyle(
                fontSize: 14.sp,
                color: colorScheme.onSurface.withValues(alpha: 0.75),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section label
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
      ),
    );
  }
}
