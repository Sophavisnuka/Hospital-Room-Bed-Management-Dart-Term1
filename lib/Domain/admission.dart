import 'package:uuid/uuid.dart';

const uuid = Uuid();

class Admission {
  final String id;
  final String patient;
  final int roomNumber;
  final String bedNumber;
  final DateTime admissionDate;
  DateTime? dischargeDate;
  String? dischargeReason;
  String? transferReason;
  int? previousRoomNumber;
  String? previousBedNumber;

  Admission({
    String? id,
    required this.patient,
    required this.roomNumber,
    required this.bedNumber,
    required this.admissionDate,
    this.dischargeDate,
    this.dischargeReason,
    this.transferReason,
    this.previousRoomNumber,
    this.previousBedNumber,
  }) : id = id ?? uuid.v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient': patient,
      'roomNumber': roomNumber,
      'bedNumber': bedNumber,
      'admissionDate': admissionDate.toIso8601String(),
      'dischargeDate': dischargeDate?.toIso8601String(),
      'dischargeReason': dischargeReason,
      'transferReason': transferReason,
      'previousRoomNumber': previousRoomNumber,
      'previousBedNumber': previousBedNumber,
    };
  }

  factory Admission.fromMap(Map<String, dynamic> map) {
    try {
      return Admission(
        id: map['id'] as String?,
        patient: map['patient'] as String? ?? '',
        roomNumber: map['roomNumber'] as int? ?? 0,
        bedNumber: map['bedNumber'] as String? ?? '',
        admissionDate: map['admissionDate'] != null
            ? DateTime.parse(map['admissionDate'] as String)
            : DateTime.now(),  // Fixed: check if null BEFORE parsing
        dischargeDate: map['dischargeDate'] != null 
            ? DateTime.parse(map['dischargeDate'] as String) 
            : null,
        dischargeReason: map['dischargeReason'] as String?,
        transferReason: map['transferReason'] as String?,
        previousRoomNumber: map['previousRoomNumber'] as int?,
        previousBedNumber: map['previousBedNumber'] as String?,
      );
    } catch (e) {
      print('Error loading admission from map: $e');
      print('Map data: $map');
      rethrow;  // Re-throw to see the error
    }
  }
}