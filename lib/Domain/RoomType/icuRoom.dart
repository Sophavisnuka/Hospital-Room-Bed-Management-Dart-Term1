import 'package:my_first_project/Domain/room.dart';
import 'package:my_first_project/Domain/bed.dart';

class ICURoom extends Room {
  final bool hasVentilator;
  final bool hasCardiacMonitor;
  final int nurseToPatientRatio; // e.g., 1 nurse per 2 patients

  ICURoom({
    required int roomNumber,
    required List<Bed> beds,
    double basePrice = 500.0,
    this.hasVentilator = true,
    this.hasCardiacMonitor = true,
    this.nurseToPatientRatio = 2, // 1:2 ratio by default
  }) : super(
    roomNumber: roomNumber,
    roomType: RoomType.icu,
    basePrice: basePrice,
    beds: beds,
  ) {
    // Validate bed count for ICU (typically 1-4 beds per unit)
    if (beds.length < 1 || beds.length > 4) {
      throw ArgumentError("ICU rooms must have 1-4 beds.");
    }
    if (nurseToPatientRatio < 1 || nurseToPatientRatio > 4) {
      throw ArgumentError("Nurse-to-patient ratio must be between 1:1 and 1:4.");
    }
  }

  @override
  double calculateTotalCost(int nights) {
    double baseCost = basePrice * nights;
    double serviceCharge = getServiceCharge() * nights;
    // ICU has additional equipment costs
    double equipmentCost = 100.0 * nights;
    return baseCost + serviceCharge + equipmentCost;
  }

  @override
  List<String> getRoomFeatures() {
    List<String> features = [
      '24/7 monitoring',
      'Specialized medical equipment',
      'Emergency call system',
      'Isolation capability',
      'Advanced life support',
    ];
    
    if (hasVentilator) {
      features.add('Ventilator support');
    }
    if (hasCardiacMonitor) {
      features.add('Cardiac monitoring');
    }
    features.add('Nurse ratio: 1:$nurseToPatientRatio');
    
    return features;
  }

  @override
  double getServiceCharge() {
    double charge = 150.0; // Base ICU service charge
    if (hasVentilator) charge += 50.0;
    if (hasCardiacMonitor) charge += 30.0;
    // Better nurse ratio means higher cost
    charge += (5 - nurseToPatientRatio) * 20.0;
    return charge;
  }

  @override
  bool canAccommodateSpecialNeeds() {
    return true; // ICU rooms are equipped for critical care
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['hasVentilator'] = hasVentilator;
    map['hasCardiacMonitor'] = hasCardiacMonitor;
    map['nurseToPatientRatio'] = nurseToPatientRatio;
    return map;
  }

  factory ICURoom.fromMap(Map<String, dynamic> map) {
    final room = ICURoom(
      roomNumber: map['roomNumber'],
      basePrice: (map['basePrice'] as num?)?.toDouble() ?? 500.0,
      beds: (map['beds'] as List)
          .map((bedMap) => Bed.fromMap(bedMap))
          .toList(),
      hasVentilator: map['hasVentilator'] ?? true,
      hasCardiacMonitor: map['hasCardiacMonitor'] ?? true,
      nurseToPatientRatio: map['nurseToPatientRatio'] ?? 2,
    );
    room.isAvailable = map['isAvailable'] ?? true;
    return room;
  }
}
