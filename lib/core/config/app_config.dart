import 'environment.dart';

/// Central configuration class for the application.
/// Must be initialized during app startup before making any network requests.
class AppConfig {
  static late Environment _environment;
  static late String _baseUrl;
  static late Duration _connectTimeout;
  static late Duration _receiveTimeout;

  static void initialize({
    required Environment environment,
    required String baseUrl,
    Duration connectTimeout = const Duration(seconds: 15),
    Duration receiveTimeout = const Duration(seconds: 15),
  }) {
    _environment = environment;
    _baseUrl = baseUrl;
    _connectTimeout = connectTimeout;
    _receiveTimeout = receiveTimeout;
  }

  static Environment get environment => _environment;
  static String get baseUrl => _baseUrl;
  static Duration get connectTimeout => _connectTimeout;
  static Duration get receiveTimeout => _receiveTimeout;

  static bool get isDev => _environment == Environment.dev;
  static bool get isUat => _environment == Environment.uat;
  static bool get isProd => _environment == Environment.prod;
}
