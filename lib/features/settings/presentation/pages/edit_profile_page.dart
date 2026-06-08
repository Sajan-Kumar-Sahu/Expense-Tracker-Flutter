import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/user_provider.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() =>
      _EditProfilePageState();
}

class _EditProfilePageState
    extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController =
  TextEditingController();

  final _emailController =
  TextEditingController();

  bool _initialized = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final service =
      ref.read(userServiceProvider);

      final result =
      await service.updateUser(
        id:
        '94623bcb-fed5-47a0-a684-720dd84fcbe9',
        fullName:
        _nameController.text.trim(),
        email:
        _emailController.text.trim(),
      );

      result.fold(
            (_) {
          ref.invalidate(userProvider);

          ScaffoldMessenger.of(context)
              .showSnackBar(
            const SnackBar(
              content: Text(
                'Profile updated successfully',
              ),
            ),
          );

          Navigator.pop(context);
        },
            (failure) {
          throw Exception(
            failure.message,
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(
      BuildContext context) {
    final theme = Theme.of(context);

    final userAsync =
    ref.watch(userProvider);

    if (!_initialized &&
        userAsync.hasValue) {
      _nameController.text =
          userAsync.value!.fullName;

      _emailController.text =
          userAsync.value!.email;

      _initialized = true;
    }

    return Scaffold(
      backgroundColor:
      theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
        ),
        centerTitle: true,
      ),
      body: userAsync.when(
        loading: () => const Center(
          child:
          CircularProgressIndicator(),
        ),
        error: (error, stack) =>
            Center(
              child: Text(
                error.toString(),
              ),
            ),
        data: (_) {
          final isDark =
              theme.brightness ==
                  Brightness.dark;

          return SingleChildScrollView(
            padding: EdgeInsets.all(20.r),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    padding:
                    EdgeInsets.all(20.r),
                    decoration:
                    BoxDecoration(
                      color: isDark
                          ? const Color(
                          0xFF1E293B)
                          : Colors.white,
                      borderRadius:
                      BorderRadius
                          .circular(
                          18.r),
                      border: Border.all(
                        color: isDark
                            ? const Color(
                            0xFF334155)
                            : const Color(
                            0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          controller:
                          _nameController,
                          decoration:
                          const InputDecoration(
                            labelText:
                            'Full Name',
                            prefixIcon:
                            Icon(Icons
                                .person_outline),
                          ),
                          validator:
                              (value) {
                            if (value ==
                                null ||
                                value
                                    .trim()
                                    .isEmpty) {
                              return 'Name is required';
                            }

                            return null;
                          },
                        ),
                        SizedBox(
                            height: 20.h),
                        TextFormField(
                          controller:
                          _emailController,
                          keyboardType:
                          TextInputType
                              .emailAddress,
                          decoration:
                          const InputDecoration(
                            labelText:
                            'Email',
                            prefixIcon:
                            Icon(Icons
                                .email_outlined),
                          ),
                          validator:
                              (value) {
                            if (value ==
                                null ||
                                value
                                    .trim()
                                    .isEmpty) {
                              return 'Email is required';
                            }

                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width:
                    double.infinity,
                    height: 52.h,
                    child:
                    ElevatedButton(
                      onPressed:
                      _isSaving
                          ? null
                          : _saveProfile,
                      child: _isSaving
                          ? SizedBox(
                        height: 20.h,
                        width: 20.h,
                        child:
                        const CircularProgressIndicator(
                          strokeWidth:
                          2,
                        ),
                      )
                          : const Text(
                        'Save Changes',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}