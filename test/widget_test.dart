import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/main.dart';
import 'package:expense_tracker/core/config/app_config.dart';
import 'package:expense_tracker/core/config/environment.dart';
import 'package:expense_tracker/dependency_injection/injection.dart';

void main() {
  testWidgets('App boot and render dashboard smoke test', (WidgetTester tester) async {
    // Initialize configurations for testing environment
    AppConfig.initialize(
      environment: Environment.dev,
      baseUrl: 'https://localhost:5001',
    );
    
    // Register DI dependencies
    setupLocator();

    await tester.pumpWidget(
      const ProviderScope(
        child: ExpenseTrackerApp(),
      ),
    );

    // Let any page routing settle
    await tester.pumpAndSettle();

    // Assert that the dashboard greets the user
    expect(find.text('Welcome back,'), findsOneWidget);
    expect(find.text('Enterprise User'), findsOneWidget);
    expect(find.text('Quick Actions'), findsOneWidget);
  });
}
