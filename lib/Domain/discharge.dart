import 'package:uuid/uuid.dart';
import 'package:my_first_project/Domain/admission.dart';

const uuid = Uuid();

class Discharge {
  final String id;
  final Admission admission;  // Store the actual admission object
  final DateTime dischargeDate;
  final String? dischargeReason;
  final int nightsStayed;

  Discharge({
    String? id,
    required this.admission,
    required this.dischargeDate,
    this.dischargeReason,
    required this.nightsStayed,
  }) : id = id ?? uuid.v4();

  String get patient => admission.patient;
  int get roomNumber => admission.roomNumber;
  String get bedNumber => admission.bedNumber;
  DateTime get admissionDate => admission.admissionDate;
  double get totalPrice => admission.totalPrice;
  String get admissionId => admission.id;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'admission': admission.toMap(),  // Store entire admission
      'dischargeDate': dischargeDate.toIso8601String(),
      'dischargeReason': dischargeReason,
      'nightsStayed': nightsStayed,
    };
  }

  factory Discharge.fromMap(Map<String, dynamic> map) {
    try {
      //  Handle both old and new formats
      if (map.containsKey('admission')) {
        // New format: admission object is embedded
        return Discharge(
          id: map['id'] as String?,
          admission: Admission.fromMap(map['admission'] as Map<String, dynamic>),
          dischargeDate: map['dischargeDate'] != null
              ? DateTime.parse(map['dischargeDate'] as String)
              : DateTime.now(),
          dischargeReason: map['dischargeReason'] as String?,
          nightsStayed: map['nightsStayed'] as int? ?? 0,
        );
      } else {
        // Old format: individual fields (migration support)
        final admission = Admission(
          id: map['admissionId'] as String? ?? '',
          patient: map['patient'] as String? ?? '',
          roomNumber: map['roomNumber'] as int? ?? 0,
          bedNumber: map['bedNumber'] as String? ?? '',
          admissionDate: map['admissionDate'] != null
              ? DateTime.parse(map['admissionDate'] as String)
              : DateTime.now(),
          totalPrice: (map['totalPrice'] as num?)?.toDouble() ?? 0.0,
        );
        
        return Discharge(
          id: map['id'] as String?,
          admission: admission,
          dischargeDate: map['dischargeDate'] != null
              ? DateTime.parse(map['dischargeDate'] as String)
              : DateTime.now(),
          dischargeReason: map['dischargeReason'] as String?,
          nightsStayed: map['nightsStayed'] as int? ?? 0,
        );
      }
    } catch (e) {
      print('Error loading discharge from map: $e');
      print('Map data: $map');
      rethrow;
    }
  }

  @override
  String toString() {
    return '''
=========================================
Discharge Record
=========================================
Discharge ID: $id
Patient: $patient
Room: $roomNumber, Bed: $bedNumber
Admission Date: ${admissionDate.toLocal()}
Discharge Date: ${dischargeDate.toLocal()}
Nights Stayed: $nightsStayed
Total Price: \$${totalPrice.toStringAsFixed(2)}
Discharge Reason: ${dischargeReason ?? 'Not specified'}
=========================================
    ''';
  }
}