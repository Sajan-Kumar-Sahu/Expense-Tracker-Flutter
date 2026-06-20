import 'package:expense_tracker/core/utils/app_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../routes/app_router.dart';
import '../../domain/entities/category_entity.dart';
import '../providers/categories_provider.dart';

class CategoryListPage extends ConsumerWidget {
  const CategoryListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(categoriesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Categories',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 26.sp,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: -0.2, end: 0, duration: 400.ms),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => ref.read(categoriesProvider).loadCategories(),
                        icon: Icon(Icons.refresh_rounded,
                            color: theme.colorScheme.primary, size: 22.r),
                        tooltip: 'Refresh',
                      ),
                      GestureDetector(
                        onTap: () => context.push(AppRouter.addCategory),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 14.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.add_rounded,
                                  color: Colors.white, size: 16.r),
                              SizedBox(width: 4.w),
                              Text(
                                'Add',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Content
            Expanded(
              child: provider.isLoading
                  ? const AppLoader(message: 'Loading categories...')
                  : RefreshIndicator(
                      onRefresh: () async =>
                          ref.read(categoriesProvider).loadCategories(),
                      color: theme.colorScheme.primary,
                      child: provider.categories.isEmpty
                          ? _EmptyState(theme: theme)
                          : CustomScrollView(
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              slivers: [
                                SliverPadding(
                                  padding: EdgeInsets.fromLTRB(
                                      20.w, 0, 20.w, 110.h),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) => _CategoryCard(
                                        category: provider.categories[index],
                                        index: index,
                                        ref: ref,
                                        context: context,
                                      ),
                                      childCount: provider.categories.length,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ThemeData theme;
  const _EmptyState({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.category_outlined,
            size: 64.r,
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
          SizedBox(height: 16.h),
          Text(
            'No categories yet',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Tap Add to create your first category',
            style: TextStyle(
              fontSize: 13.sp,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryEntity category;
  final int index;
  final WidgetRef ref;
  final BuildContext context;

  const _CategoryCard({
    required this.category,
    required this.index,
    required this.ref,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final typeColor = _colorForType(category.categoryType);
    final typeLabel = _labelForType(category.categoryType);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 50.r,
            height: 50.r,
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              _iconForType(category.categoryType),
              color: typeColor,
              size: 26.r,
            ),
          ),
          SizedBox(width: 14.w),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        typeLabel,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: typeColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (category.description != null &&
                        category.description!.isNotEmpty) ...[
                      SizedBox(width: 8.w),
                      Flexible(
                        child: Text(
                          category.description!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Menu
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded,
                size: 20.r,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r)),
            onSelected: (value) async {
              if (value == 'edit') {
                await context.push(
                  AppRouter.editCategory,
                  extra: category,
                );
                await refreshAll(ref);
                return;
              }

              if (value == 'delete') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Category'),
                    content: Text(
                      'Are you sure you want to delete "${category.name}"?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirm == true && context.mounted) {
                  final success = await ref
                      .read(categoriesProvider)
                      .deleteCategory(category.id);

                  if (success) {
                    await refreshAll(ref);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Category deleted successfully')),
                      );
                    }
                  }
                }
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: Colors.red,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
            delay: Duration(milliseconds: index * 80 + 200), duration: 500.ms)
        .slideX(
            begin: 0.08,
            end: 0,
            delay: Duration(milliseconds: index * 80 + 200),
            duration: 500.ms);
  }

  IconData _iconForType(int type) {
    switch (type) {
      case 1:
        return Icons.trending_up_rounded;
      case 2:
        return Icons.trending_down_rounded;
      default:
        return Icons.label_rounded;
    }
  }

  Color _colorForType(int type) {
    switch (type) {
      case 1:
        return const Color(0xFF10B981); // Income — green
      case 2:
        return const Color(0xFFEF4444); // Expense — red
      default:
        return const Color(0xFF6366F1);
    }
  }

  String _labelForType(int type) {
    switch (type) {
      case 1:
        return 'Income';
      case 2:
        return 'Expense';
      default:
        return 'Other';
    }
  }
}
