import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/vitals_model.dart';

class DataStorageService {
  DataStorageService._internal();
  static final DataStorageService _instance = DataStorageService._internal();

  factory DataStorageService() {
    return _instance;
  }

  late Box<VitalRecord> _vitalsBox;

  String _getDailyKey(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return dateOnly.toIso8601String().split('T').first;
  }

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(VitalRecordAdapter().typeId)) {
      Hive.registerAdapter(VitalRecordAdapter());
    }

    if (!Hive.isBoxOpen('vitalRecords')) {
      _vitalsBox = await Hive.openBox<VitalRecord>('vitalRecords');
    } else {
      _vitalsBox = Hive.box<VitalRecord>('vitalRecords');
    }
    debugPrint('DataStorageService (Vitals) initialized.');
  }

  VitalRecord getTodayRecord() {
    final now = DateTime.now();
    final key = _getDailyKey(now);

    VitalRecord? record = _vitalsBox.get(key);

    if (record == null) {
      record = VitalRecord(date: now);
      _vitalsBox.put(key, record);
    }
    return record;
  }

  Future<void> updateSteps(int stepsToAdd) async {
    final record = getTodayRecord();
    record.steps += stepsToAdd;
    await record.save();
  }

  Future<void> updateHydration(int mlToAdd) async {
    final record = getTodayRecord();
    record.hydration += mlToAdd;
    await record.save();
  }

  Future<void> logBloodPressure(int systolic, int diastolic) async {
    final record = getTodayRecord();
    record.bpSystolic = systolic;
    record.bpDiastolic = diastolic;
    await record.save();
  }

  Future<void> logSpo2(double spo2Value) async {
    final record = getTodayRecord();
    record.spo2 = spo2Value;
    await record.save();
  }

  ValueListenable<Box<VitalRecord>> get vitalRecordsListenable =>
      _vitalsBox.listenable();
}
