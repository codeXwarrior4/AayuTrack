import 'health_interface.dart';
import 'package:flutter/foundation.dart';

/// Placeholder implementation for Web/Chrome.
/// Provides dummy data and skips all native health calls.
class HealthPlatformService implements BaseHealthService {
  @override
  Future<bool> requestPermissions() async {
    debugPrint("HealthService: Dummy permissions granted for Web.");
    return true;
  }

  @override
  Future<void> syncAllVitals() async {
    debugPrint("HealthService: Skipping vital sync on Web.");
  }
}
