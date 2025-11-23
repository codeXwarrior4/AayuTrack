abstract class BaseHealthService {
  Future<bool> requestPermissions();
  Future<void> syncAllVitals();
}
