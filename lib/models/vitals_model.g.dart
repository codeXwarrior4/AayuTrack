// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vitals_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VitalRecordAdapter extends TypeAdapter<VitalRecord> {
  @override
  final int typeId = 0;

  @override
  VitalRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VitalRecord(
      date: fields[0] as DateTime,
      steps: fields[1] as int,
      heartRate: fields[2] as double,
      hydration: fields[3] as double,
      bpSystolic: fields[4] as int,
      bpDiastolic: fields[5] as int,
      spo2: fields[6] as double,
      medicationAdherence: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, VitalRecord obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.steps)
      ..writeByte(2)
      ..write(obj.heartRate)
      ..writeByte(3)
      ..write(obj.hydration)
      ..writeByte(4)
      ..write(obj.bpSystolic)
      ..writeByte(5)
      ..write(obj.bpDiastolic)
      ..writeByte(6)
      ..write(obj.spo2)
      ..writeByte(7)
      ..write(obj.medicationAdherence);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VitalRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
