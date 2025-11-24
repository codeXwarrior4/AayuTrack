import 'health_interface.dart';
import 'health_mobile.dart' if (dart.library.html) 'health_web.dart';

/// This class acts as the main gateway to the Health functionality.
/// It uses conditional imports to select the correct implementation.
class HealthService implements BaseHealthService {
  // Use a nullable static variable to hold the initialized platform service.
  static BaseHealthService? _platformServiceInstance;

  // Private constructor to prevent direct instantiation
  HealthService._internal();

  // Singleton instance
  static final HealthService _instance = HealthService._internal();

  // Factory constructor: The only way to get the instance
  factory HealthService() {
    // If the platform service hasn't been instantiated yet, do it now.
    _platformServiceInstance ??= HealthPlatformService();
    return _instance;
  }

  // Getter to retrieve the initialized platform service instance
  BaseHealthService get _platformService {
    // This will never be null after the factory constructor runs
    return _platformServiceInstance!;
  }

  // Delegate calls to the correct platform service
  @override
  Future<bool> requestPermissions() => _platformService.requestPermissions();

  @override
  Future<void> syncAllVitals() => _platformService.syncAllVitals();
}
