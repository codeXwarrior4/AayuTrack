import 'package:hive/hive.dart';

part 'vitals_model.g.dart';

@HiveType(typeId: 0)
class VitalRecord extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  int steps;

  @HiveField(2)
  double heartRate;

  @HiveField(3)
  double hydration;

  @HiveField(4)
  int bpSystolic;

  @HiveField(5)
  int bpDiastolic;

  @HiveField(6)
  double spo2;

  @HiveField(7)
  int medicationAdherence;

  VitalRecord({
    required this.date,
    this.steps = 0,
    this.heartRate = 0.0,
    this.hydration = 0.0,
    this.bpSystolic = 0,
    this.bpDiastolic = 0,
    this.spo2 = 0.0,
    this.medicationAdherence = 0,
  });
}
