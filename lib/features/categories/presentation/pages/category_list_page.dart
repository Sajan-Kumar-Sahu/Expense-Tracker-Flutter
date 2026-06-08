import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../routes/app_router.dart';

/// Skeleton UI screen for Categories.
class CategoryListPage extends StatelessWidget {
  const CategoryListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go(AppRouter.dashboard),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.category_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Categories Feature',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This screen is currently a placeholder skeleton. It represents where Category CRUD actions will be implemented in future iterations.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
