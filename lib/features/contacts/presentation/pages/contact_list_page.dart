import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../routes/app_router.dart';
import '../../domain/entities/contact_entity.dart';
import '../providers/contacts_provider.dart';

class ContactListPage extends ConsumerStatefulWidget {
  const ContactListPage({super.key});

  @override
  ConsumerState<ContactListPage> createState() => _ContactListPageState();
}

class _ContactListPageState extends ConsumerState<ContactListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    _searchController.clear();
    await ref.read(contactsProvider).loadContacts();
  }

  Future<void> _confirmDelete(BuildContext context, ContactEntity contact) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: const Text('Delete Contact'),
        content: Text('Delete "${contact.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final success =
          await ref.read(contactsProvider).deleteContact(contact.id);
      if (context.mounted && !success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete contact')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = ref.watch(contactsProvider);

    final query = _searchController.text.toLowerCase();
    final filtered = provider.contacts.where((c) {
      return query.isEmpty || c.name.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20.r),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Contacts',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded, size: 26.r),
            onPressed: () => context.push(AppRouter.addContact),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search contacts...',
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  size: 20.r,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () => _searchController.clear(),
                        child: Icon(Icons.close_rounded,
                            size: 18.r,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.4)),
                      )
                    : null,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
                  borderSide:
                      BorderSide(color: theme.colorScheme.primary, width: 1.5),
                ),
                filled: true,
                fillColor: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFF1F5F9),
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  fontSize: 14.sp,
                ),
              ),
            ),
          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _onRefresh,
                    color: theme.colorScheme.primary,
                    child: filtered.isEmpty
                        ? _EmptyState(
                            hasSearch: _searchController.text.isNotEmpty,
                            theme: theme,
                          )
                        : ListView.builder(
                            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 100.h),
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              return _ContactCard(
                                contact: filtered[index],
                                index: index,
                                isDark: isDark,
                                theme: theme,
                                onEdit: () => context.push(
                                  AppRouter.editContact,
                                  extra: filtered[index],
                                ),
                                onDelete: () =>
                                    _confirmDelete(context, filtered[index]),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final ContactEntity contact;
  final int index;
  final bool isDark;
  final ThemeData theme;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ContactCard({
    required this.contact,
    required this.index,
    required this.isDark,
    required this.theme,
    required this.onEdit,
    required this.onDelete,
  });

  Color _typeColor() {
    switch (contact.contactType) {
      case 1:
        return const Color(0xFF3B82F6);
      case 2:
        return const Color(0xFF10B981);
      case 3:
        return const Color(0xFF8B5CF6);
      case 4:
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _typeColor();
    final initials = contact.name
        .trim()
        .split(' ')
        .where((e) => e.isNotEmpty)
        .map((e) => e[0])
        .take(2)
        .join()
        .toUpperCase();

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.r),
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
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(
                  color: color,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        contact.name,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!contact.isActive)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          'Inactive',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        contact.contactTypeName,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (contact.mobileNumber != null &&
                        contact.mobileNumber!.isNotEmpty) ...[
                      SizedBox(width: 6.w),
                      Icon(
                        Icons.phone_outlined,
                        size: 12.r,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.4),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        contact.mobileNumber!,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              size: 20.r,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r)),
            onSelected: (value) {
              if (value == 'edit') onEdit();
              if (value == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
            delay: Duration(milliseconds: index * 50 + 200), duration: 400.ms)
        .slideY(
            begin: 0.08,
            end: 0,
            delay: Duration(milliseconds: index * 50 + 200),
            duration: 400.ms);
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasSearch;
  final ThemeData theme;

  const _EmptyState({required this.hasSearch, required this.theme});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: 120.h),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                hasSearch
                    ? Icons.search_off_rounded
                    : Icons.people_outline_rounded,
                size: 64.r,
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
              SizedBox(height: 16.h),
              Text(
                hasSearch ? 'No contacts found' : 'No contacts yet',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 8.h),
              Text(
                hasSearch
                    ? 'Try a different search'
                    : 'Tap + to add your first contact',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
