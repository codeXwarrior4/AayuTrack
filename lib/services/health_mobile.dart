import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart' as health_pkg;
import 'package:permission_handler/permission_handler.dart';
import 'data_storage_service.dart';
import 'health_interface.dart';
// vitals_model import not required here; DataStorageService returns records

/// Concrete implementation for iOS and Android using the 'health' package.
class HealthPlatformService implements BaseHealthService {
  final health_pkg.Health _health = health_pkg.Health();
  final DataStorageService _storageService = DataStorageService();

  static const List<health_pkg.HealthDataType> _types = [
    health_pkg.HealthDataType.STEPS,
    health_pkg.HealthDataType.HEART_RATE,
    health_pkg.HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    health_pkg.HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    health_pkg.HealthDataType.BLOOD_OXYGEN,
    health_pkg.HealthDataType.WATER,
  ];

  static final List<health_pkg.HealthDataAccess> _permissions =
      _types.map((e) => health_pkg.HealthDataAccess.READ).toList();

  @override
  Future<bool> requestPermissions() async {
    // Ensure the health plugin is configured before requesting permissions
    try {
      await _health.configure();
    } catch (e) {
      debugPrint('Health configure failed: $e');
    }
    if (Platform.isAndroid) {
      if (await Permission.activityRecognition.isDenied) {
        await Permission.activityRecognition.request();
      }
    }

    bool success =
        await _health.requestAuthorization(_types, permissions: _permissions);

    if (!success && Platform.isAndroid) {
      // Prompt user to install or open Health Connect if needed
      try {
        await _health.installHealthConnect();
      } catch (e) {
        debugPrint('Failed to prompt Health Connect install: $e');
      }
    }

    return success;
  }

  Future<int> _getTodaySteps() async {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    try {
      return await _health.getTotalStepsInInterval(midnight, now) ?? 0;
    } catch (e) {
      debugPrint("Error fetching total steps: $e");
      return 0;
    }
  }

  double? _getNumericValue(health_pkg.HealthDataPoint? data) {
    if (data == null || data.value is! health_pkg.NumericHealthValue) {
      return null;
    }
    return (data.value as health_pkg.NumericHealthValue)
        .numericValue
        .toDouble();
  }

  @override
  Future<void> syncAllVitals() async {
    bool? authorized = await _health.hasPermissions(_types);
    if (authorized != true) {
      debugPrint("Health data access not authorized. Skipping sync.");
      return;
    }

    final record = _storageService.getTodayRecord();

    record.steps = await _getTodaySteps();

    double? hrValue = _getNumericValue(
        await _getLatestData(health_pkg.HealthDataType.HEART_RATE));
    if (hrValue != null) record.heartRate = hrValue;

    double? bpSysValue = _getNumericValue(await _getLatestData(
        health_pkg.HealthDataType.BLOOD_PRESSURE_SYSTOLIC));
    if (bpSysValue != null) record.bpSystolic = bpSysValue.toInt();

    double? bpDiasValue = _getNumericValue(await _getLatestData(
        health_pkg.HealthDataType.BLOOD_PRESSURE_DIASTOLIC));
    if (bpDiasValue != null) record.bpDiastolic = bpDiasValue.toInt();

    double? spo2Value = _getNumericValue(
        await _getLatestData(health_pkg.HealthDataType.BLOOD_OXYGEN));
    if (spo2Value != null) {
      record.spo2 = (spo2Value > 1.0) ? spo2Value : (spo2Value * 100);
    }

    double? waterValue =
        _getNumericValue(await _getLatestData(health_pkg.HealthDataType.WATER));
    if (waterValue != null) {
      record.hydration = waterValue * 1000;
    }

    await record.save();
    debugPrint(
        "Mobile Vitals synchronization complete. Steps: ${record.steps}");
  }

  Future<health_pkg.HealthDataPoint?> _getLatestData(
      health_pkg.HealthDataType type) async {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(hours: 24));
    try {
      List<health_pkg.HealthDataPoint> data =
          await _health.getHealthDataFromTypes(
        types: [type],
        startTime: yesterday,
        endTime: now,
      );
      data.sort((a, b) => b.dateTo.compareTo(a.dateTo));
      return data.isNotEmpty ? data.first : null;
    } catch (e) {
      debugPrint("Error fetching $type data: $e");
      return null;
    }
  }
}
