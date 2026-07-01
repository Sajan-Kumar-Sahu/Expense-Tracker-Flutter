import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/config/app_config.dart';
import 'core/config/environment.dart';
import 'core/services/firebase_messaging_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/providers/theme_provider.dart';
import 'dependency_injection/injection.dart';
import 'core/utils/app_refresh.dart';
import 'routes/app_router.dart';
import 'features/biometric/services/app_lifecycle_service.dart';
import 'features/biometric/presentation/pages/authentication_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  // Initialize Firebase (reads google-services.json automatically on Android)
  await Firebase.initializeApp();
  await FirebaseMessagingService.initialize();

  // Initialize Environment Config (Defaults to Development)
  AppConfig.initialize(
    environment: Environment.dev,
    baseUrl: 'https://expensetracker-production-c085.up.railway.app',
    //baseUrl: 'http://192.168.1.9:21882'
  );

  // Set up service locator
  setupLocator();

  runApp(
    const ProviderScope(
      child: ExpenseTrackerApp(),
    ),
  );
}

class ExpenseTrackerApp extends ConsumerStatefulWidget {
  const ExpenseTrackerApp({super.key});

  @override
  ConsumerState<ExpenseTrackerApp> createState() => _ExpenseTrackerAppState();
}

class _ExpenseTrackerAppState extends ConsumerState<ExpenseTrackerApp>
    with WidgetsBindingObserver {
  late final AppLifecycleService _lifecycleService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lifecycleService = AppLifecycleService(ref)..init();
  }

  @override
  void dispose() {
    _lifecycleService.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshAll(ref);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'ArthiqHQ',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          routerConfig: AppRouter.router,
          builder: (context, child) {
            return AuthenticationGate(child: child!);
          },
        );
      },
    );
  }
}
