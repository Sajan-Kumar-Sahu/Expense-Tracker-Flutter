import 'package:expense_tracker/features/accounts/presentation/pages/account_details_page.dart';
import 'package:expense_tracker/features/auth/presentation/pages/get_started_page.dart';
import 'package:expense_tracker/features/auth/presentation/pages/login_page.dart';
import 'package:expense_tracker/features/categories/domain/entities/category_entity.dart';
import 'package:expense_tracker/features/categories/presentation/pages/category_details_page.dart';
import 'package:expense_tracker/features/contacts/domain/entities/contact_entity.dart';
import 'package:expense_tracker/features/contacts/presentation/pages/add_edit_contact_page.dart';
import 'package:expense_tracker/features/contacts/presentation/pages/contact_list_page.dart';
import 'package:expense_tracker/features/settlements/domain/entities/settlement_entity.dart';
import 'package:expense_tracker/features/settlements/presentation/pages/add_settlement_page.dart';
import 'package:expense_tracker/features/settlements/presentation/pages/settlement_details_page.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction_entity.dart';
import 'package:expense_tracker/features/transactions/presentation/pages/add_edit_transaction_page.dart';
import 'package:expense_tracker/features/transactions/presentation/pages/transaction_details_page.dart';
import 'package:expense_tracker/features/worklog/domain/entities/work_log_entity.dart';
import 'package:expense_tracker/features/worklog/presentation/pages/add_edit_work_log_page.dart';
import 'package:expense_tracker/features/worklog/presentation/pages/project_list_page.dart';
import 'package:expense_tracker/features/worklog/presentation/pages/work_log_dashboard_page.dart';
import 'package:expense_tracker/features/worklog/presentation/pages/work_log_details_page.dart';
import 'package:expense_tracker/features/reminders/domain/entities/reminder_entity.dart';
import 'package:expense_tracker/features/reminders/presentation/pages/add_edit_reminder_page.dart';
import 'package:expense_tracker/features/reminders/presentation/pages/reminder_dashboard_page.dart';
import 'package:expense_tracker/features/reminders/presentation/pages/reminder_details_page.dart';
import 'package:expense_tracker/features/reminders/presentation/pages/notification_list_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Pages
import '../features/splash/presentation/pages/splash_page.dart';
import '../core/navigation/main_scaffold.dart';
import '../features/accounts/presentation/pages/add_edit_account_page.dart';
import '../features/categories/presentation/pages/add_edit_category_page.dart';

// Entities
import '../features/accounts/domain/entities/account_entity.dart';

class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String getStarted = '/get-started';
  static const String login = '/login';
  static const String home = '/home';

  static const String addAccount = '/home/accounts/add';
  static const String editAccount = '/home/accounts/edit';
  static const String accountDetails = '/home/accounts/details';

  static const String addCategory = '/home/categories/add';
  static const String editCategory = '/home/categories/edit';
  static const String categoryDetails = '/home/categories/details';

  static const String addTransaction = '/home/transactions/add';
  static const String editTransaction = '/home/transactions/edit';
  static const transactionDetails = '/home/transactions/details';

  static const String contacts = '/home/contacts';
  static const String addContact = '/home/contacts/add';
  static const String editContact = '/home/contacts/edit';

  static const String addSettlement = '/home/settlements/add';
  static const String editSettlement = '/home/settlements/edit';
  static const String settlementDetails = '/home/settlements/details';

  static const String workLogProjects = '/home/worklog/projects';
  static const String workLogDashboard = '/home/worklog/dashboard';
  static const String addWorkLog = '/home/worklog/add';
  static const String editWorkLog = '/home/worklog/edit';
  static const String workLogDetails = '/home/worklog/details';

  static const String reminderDashboard = '/home/reminders/dashboard';
  static const String addReminder = '/home/reminders/add';
  static const String editReminder = '/home/reminders/edit';
  static const String reminderDetails = '/home/reminders/details';
  static const String notificationList = '/home/reminders/notifications';

  static final GoRouter router = GoRouter(
    initialLocation: splash,

    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Text('Route not found: ${state.uri.path}'),
      ),
    ),

    routes: [
      // Splash
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashPage(),
      ),

      // Auth
      GoRoute(
        path: getStarted,
        builder: (context, state) => const GetStartedPage(),
      ),
      GoRoute(
        path: login,
        builder: (context, state) => const LoginPage(),
      ),

      // Main App
      GoRoute(
        path: home,
        builder: (context, state) => const MainScaffold(),
      ),

      // Accounts
      GoRoute(
        path: addAccount,
        builder: (context, state) => const AddEditAccountPage(),
      ),
      GoRoute(
        path: editAccount,
        builder: (context, state) {
          final account = state.extra as AccountEntity?;
          return AddEditAccountPage(account: account);
        },
      ),
      GoRoute(
        path: accountDetails,
        builder: (context, state) {
          final account = state.extra as AccountEntity;
          return AccountDetailsPage(account: account);
        },
      ),

      // Categories
      GoRoute(
        path: addCategory,
        builder: (context, state) => const AddEditCategoryPage(),
      ),
      GoRoute(
        path: editCategory,
        builder: (context, state) {
          final category = state.extra as CategoryEntity?;
          return AddEditCategoryPage(category: category);
        },
      ),
      GoRoute(
        path: categoryDetails,
        builder: (context, state) {
          final category = state.extra as CategoryEntity;
          return CategoryDetailsPage(category: category);
        },
      ),

      // Transactions
      GoRoute(
        path: addTransaction,
        builder: (context, state) => AddEditTransactionPage(
          initialTransactionType: state.extra as int?,
        ),
      ),
      GoRoute(
        path: editTransaction,
        builder: (context, state) {
          final transaction = state.extra as TransactionEntity?;
          return AddEditTransactionPage(transaction: transaction);
        },
      ),
      GoRoute(
        path: transactionDetails,
        builder: (context, state) {
          final id = state.extra as String;
          return TransactionDetailsPage(transactionId: id);
        },
      ),

      // Contacts
      GoRoute(
        path: contacts,
        builder: (context, state) => const ContactListPage(),
      ),
      GoRoute(
        path: addContact,
        builder: (context, state) => const AddEditContactPage(),
      ),
      GoRoute(
        path: editContact,
        builder: (context, state) {
          final contact = state.extra as ContactEntity?;
          return AddEditContactPage(contact: contact);
        },
      ),

      // Settlements
      GoRoute(
        path: addSettlement,
        builder: (context, state) => const AddSettlementPage(),
      ),
      GoRoute(
        path: editSettlement,
        builder: (context, state) {
          final settlement = state.extra as SettlementEntity?;
          return AddSettlementPage(settlement: settlement);
        },
      ),
      GoRoute(
        path: settlementDetails,
        builder: (context, state) {
          final id = state.extra as String;
          return SettlementDetailsPage(settlementId: id);
        },
      ),

      // WorkLog
      GoRoute(
        path: workLogProjects,
        builder: (context, state) => const ProjectListPage(),
      ),
      GoRoute(
        path: workLogDashboard,
        builder: (context, state) => const WorkLogDashboardPage(),
      ),
      GoRoute(
        path: addWorkLog,
        builder: (context, state) => const AddEditWorkLogPage(),
      ),
      GoRoute(
        path: editWorkLog,
        builder: (context, state) {
          final workLog = state.extra as WorkLogEntity?;
          return AddEditWorkLogPage(workLog: workLog);
        },
      ),
      GoRoute(
        path: workLogDetails,
        builder: (context, state) {
          final id = state.extra as String;
          return WorkLogDetailsPage(workLogId: id);
        },
      ),

      // Reminders
      GoRoute(
        path: reminderDashboard,
        builder: (context, state) => const ReminderDashboardPage(),
      ),
      GoRoute(
        path: addReminder,
        builder: (context, state) => const AddEditReminderPage(),
      ),
      GoRoute(
        path: editReminder,
        builder: (context, state) {
          final reminder = state.extra as ReminderEntity?;
          return AddEditReminderPage(reminder: reminder);
        },
      ),
      GoRoute(
        path: reminderDetails,
        builder: (context, state) {
          final id = state.extra as String;
          return ReminderDetailsPage(reminderId: id);
        },
      ),
      GoRoute(
        path: notificationList,
        builder: (context, state) => const NotificationListPage(),
      ),
    ],
  );
}
