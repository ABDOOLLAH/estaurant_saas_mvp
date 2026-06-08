import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';

class AppConfig {
  final AppEnvironment environment;
  final String apiBaseUrl;

  AppConfig({
    required this.environment,
    required this.apiBaseUrl,
  });

  factory AppConfig.fromEnvironment() {
    const envString = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
    final env = AppEnvironment.values.firstWhere(
      (e) => e.name == envString,
      orElse: () => AppEnvironment.development,
    );

    return AppConfig(
      environment: env,
      apiBaseUrl: const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://10.0.2.2:5001/restaurant-saas-mvp/us-central1',
      ),
    );
  }
}

final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig.fromEnvironment();
});

/// Overriding the core provider with app-specific environment
final appEnvironmentProviderOverride = Provider<AppEnvironment>((ref) {
  return ref.watch(appConfigProvider).environment;
});

final appLoggerProvider = Provider<AppLogger>((ref) {
  final config = ref.watch(appConfigProvider);
  return AppLogger(
    environment: config.environment,
    namespace: 'STAFF_APP',
  );
});
