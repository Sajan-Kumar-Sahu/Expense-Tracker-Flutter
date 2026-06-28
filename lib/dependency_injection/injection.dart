import 'package:expense_tracker/features/categories/data/datasources/category_remote_data_source.dart';
import 'package:expense_tracker/features/transactions/data/datasources/transaction_remote_data_source.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../core/network/dio_provider.dart';
import '../core/network/api_client.dart';
import '../core/storage/auth_storage.dart';

// Feature Biometric
import 'package:expense_tracker/features/biometric/services/secure_storage_service.dart';
import 'package:expense_tracker/features/biometric/services/biometric_service.dart';
import 'package:expense_tracker/features/biometric/domain/repositories/biometric_repository.dart';
import 'package:expense_tracker/features/biometric/data/repositories/biometric_repository_impl.dart';


// Feature Accounts
import '../features/accounts/data/datasources/account_remote_datasource.dart';
import '../features/accounts/data/repositories/account_repository_impl.dart';
import '../features/accounts/domain/repositories/account_repository.dart';

// Feature Categories (Skeleton)
import '../features/categories/data/repositories/category_repository_impl.dart';
import '../features/categories/domain/repositories/category_repository.dart';

// Feature Transactions (Skeleton)
import '../features/transactions/data/repositories/transaction_repository_impl.dart';
import '../features/transactions/domain/repositories/transaction_repository.dart';

// Feature Dashboard
import '../features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import '../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../features/dashboard/domain/repositories/dashboard_repository.dart';

// Feature Contacts
import '../features/contacts/data/datasources/contact_remote_datasource.dart';
import '../features/contacts/data/repositories/contact_repository_impl.dart';
import '../features/contacts/domain/repositories/contact_repository.dart';

// Feature Settlements
import '../features/settlements/data/datasources/settlement_remote_datasource.dart';
import '../features/settlements/data/repositories/settlement_repository_impl.dart';
import '../features/settlements/domain/repositories/settlement_repository.dart';

// Feature WorkLog
import '../features/worklog/data/datasources/work_log_remote_data_source.dart';
import '../features/worklog/data/repositories/work_log_repository_impl.dart';
import '../features/worklog/domain/repositories/work_log_repository.dart';

/// Central Service Locator configuration.
final locator = GetIt.instance;

/// Registers all app-wide dependencies manually.
void setupLocator() {
  // Core
  locator.registerLazySingleton<AuthStorage>(() => AuthStorage());
  locator.registerLazySingleton<Dio>(() => DioProvider.createDio(locator<AuthStorage>()));
  locator.registerLazySingleton<ApiClient>(() => ApiClient(locator<Dio>()));

  // Feature Biometrics
  locator.registerLazySingleton<SecureStorageService>(() => SecureStorageService());
  locator.registerLazySingleton<BiometricService>(() => BiometricService());
  locator.registerLazySingleton<BiometricRepository>(() => BiometricRepositoryImpl(
        biometricService: locator<BiometricService>(),
        secureStorageService: locator<SecureStorageService>(),
      ));

  // Feature Accounts
  locator.registerLazySingleton<AccountRemoteDataSource>(
    () => AccountRemoteDataSourceImpl(locator<ApiClient>()),
  );
  locator.registerLazySingleton<AccountRepository>(
    () => AccountRepositoryImpl(locator<AccountRemoteDataSource>()),
  );

  // Feature Categories (Skeleton)
  locator.registerLazySingleton<CategoryRemoteDataSource>(
        () => CategoryRemoteDataSourceImpl(
      locator<ApiClient>(),
    ),
  );

  locator.registerLazySingleton<CategoryRepository>(
        () => CategoryRepositoryImpl(
      locator<CategoryRemoteDataSource>(),
    ),
  );

  // Feature Transactions (Skeleton)
  locator.registerLazySingleton<TransactionRemoteDataSource>(
        () => TransactionRemoteDataSourceImpl(
      locator<ApiClient>(),
    ),
  );

  locator.registerLazySingleton<TransactionRepository>(
        () => TransactionRepositoryImpl(
      locator<TransactionRemoteDataSource>(),
    ),
  );
  // Feature Dashboard
  locator.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(locator<ApiClient>()),
  );
  locator.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(locator<DashboardRemoteDataSource>()),
  );

  // Feature Contacts
  locator.registerLazySingleton<ContactRemoteDataSource>(
    () => ContactRemoteDataSourceImpl(locator<ApiClient>()),
  );
  locator.registerLazySingleton<ContactRepository>(
    () => ContactRepositoryImpl(locator<ContactRemoteDataSource>()),
  );

  // Feature Settlements
  locator.registerLazySingleton<SettlementRemoteDataSource>(
    () => SettlementRemoteDataSourceImpl(locator<ApiClient>()),
  );
  locator.registerLazySingleton<SettlementRepository>(
    () => SettlementRepositoryImpl(locator<SettlementRemoteDataSource>()),
  );

  // Feature WorkLog
  locator.registerLazySingleton<WorkLogRemoteDataSource>(
    () => WorkLogRemoteDataSourceImpl(locator<ApiClient>()),
  );
  locator.registerLazySingleton<WorkLogRepository>(
    () => WorkLogRepositoryImpl(locator<WorkLogRemoteDataSource>()),
  );
}
