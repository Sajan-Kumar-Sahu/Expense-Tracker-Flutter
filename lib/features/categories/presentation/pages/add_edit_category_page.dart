import 'package:expense_tracker/core/utils/app_refresh.dart';
import 'package:expense_tracker/features/categories/data/models/update_category_request.dart';
import 'package:expense_tracker/features/categories/domain/entities/category_entity.dart';
import 'package:expense_tracker/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../data/models/category_request.dart';
import '../providers/categories_provider.dart';

class AddEditCategoryPage extends ConsumerStatefulWidget {
  final CategoryEntity? category;
  const AddEditCategoryPage({super.key, this.category});

  @override
  ConsumerState<AddEditCategoryPage> createState() =>
      _AddEditCategoryPageState();
}

class _AddEditCategoryPageState extends ConsumerState<AddEditCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  bool _isLoading = false;
  late int _selectedType;
  late bool _isActive;

  final Map<int, String> _categoryTypes = {
    1: 'Income',
    2: 'Expense',
  };

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.category?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.category?.description ?? '');
    _selectedType = widget.category?.categoryType ?? 1;
    _isActive = widget.category?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Category' : 'Add Category'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.r),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _nameController,
                labelText: 'Category Name',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter category name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              DropdownButtonFormField<int>(
                initialValue: _selectedType,
                decoration:
                    const InputDecoration(labelText: 'Category Type'),
                items: _categoryTypes.entries
                    .map((entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedType = value);
                },
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                controller: _descriptionController,
                labelText: 'Description',
              ),
              if (isEditing) ...[
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Active',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Switch.adaptive(
                      value: _isActive,
                      onChanged: (value) => setState(() => _isActive = value),
                    ),
                  ],
                ),
              ],
              SizedBox(height: 40.h),
              CustomButton(
                text: isEditing ? 'Save Changes' : 'Create Category',
                isLoading: _isLoading,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final isEditing = widget.category != null;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    if (isEditing) {
      final success = await ref.read(categoriesProvider).updateCategory(
            UpdateCategoryRequest(
              id: widget.category!.id,
              name: name,
              description: description,
              categoryType: _selectedType,
              isActive: _isActive,
            ),
          );
      setState(() => _isLoading = false);
      if (success) {
        await refreshAll(ref);
        scaffoldMessenger
            .showSnackBar(const SnackBar(content: Text('Category updated')));
        router.go(AppRouter.home);
      } else {
        scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Failed to update category')));
      }
      return;
    }

    final success = await ref.read(categoriesProvider).createCategory(
          CategoryRequest(
            name: name,
            description: description,
            categoryType: _selectedType,
          ),
        );
    setState(() => _isLoading = false);
    if (success) {
      scaffoldMessenger
          .showSnackBar(const SnackBar(content: Text('Category created')));
      await refreshAll(ref);
      router.go(AppRouter.home);
    } else {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Failed to create category')));
    }
  }
}
