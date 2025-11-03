import 'package:uuid/uuid.dart';

const uuid = Uuid();

class Discharge {
  final String id;
  final String admissionId;  // Reference to original admission
  final String patient;
  final int roomNumber;
  final String bedNumber;
  final DateTime admissionDate;
  final DateTime dischargeDate;
  final String? dischargeReason;
  final double totalPrice;
  final int nightsStayed;

  Discharge({
    String? id,
    required this.admissionId,
    required this.patient,
    required this.roomNumber,
    required this.bedNumber,
    required this.admissionDate,
    required this.dischargeDate,
    this.dischargeReason,
    required this.totalPrice,
    required this.nightsStayed,
  }) : id = id ?? uuid.v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'admissionId': admissionId,
      'patient': patient,
      'roomNumber': roomNumber,
      'bedNumber': bedNumber,
      'admissionDate': admissionDate.toIso8601String(),
      'dischargeDate': dischargeDate.toIso8601String(),
      'dischargeReason': dischargeReason,
      'totalPrice': totalPrice,
      'nightsStayed': nightsStayed,
    };
  }

  factory Discharge.fromMap(Map<String, dynamic> map) {
    try {
      return Discharge(
        id: map['id'] as String?,
        admissionId: map['admissionId'] as String? ?? '',
        patient: map['patient'] as String? ?? '',
        roomNumber: map['roomNumber'] as int? ?? 0,
        bedNumber: map['bedNumber'] as String? ?? '',
        admissionDate: map['admissionDate'] != null
            ? DateTime.parse(map['admissionDate'] as String)
            : DateTime.now(),
        dischargeDate: map['dischargeDate'] != null
            ? DateTime.parse(map['dischargeDate'] as String)
            : DateTime.now(),
        dischargeReason: map['dischargeReason'] as String?,
        totalPrice: (map['totalPrice'] as num?)?.toDouble() ?? 0.0,
        nightsStayed: map['nightsStayed'] as int? ?? 0,
      );
    } catch (e) {
      print('Error loading discharge from map: $e');
      print('Map data: $map');
      rethrow;
    }
  }
}