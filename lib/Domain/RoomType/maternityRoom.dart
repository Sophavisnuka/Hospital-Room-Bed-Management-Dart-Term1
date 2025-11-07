import 'package:my_first_project/Domain/room.dart';
import 'package:my_first_project/Domain/bed.dart';

class MaternityRoom extends Room {
  final bool hasDeliveryEquipment;
  final bool hasNewbornCare;
  final bool hasCompanionBed;

  MaternityRoom({
    required int roomNumber,
    required List<Bed> beds,
    double basePrice = 300.0,
    this.hasDeliveryEquipment = true,
    this.hasNewbornCare = true,
    this.hasCompanionBed = true,
  }) : super(
    roomNumber: roomNumber,
    roomType: RoomType.maternity,
    basePrice: basePrice,
    beds: beds,
  ) {
    // Validate bed count for maternity rooms (typically 1-2 beds)
    if (beds.length < 1 || beds.length > 2) {
      throw ArgumentError("Maternity rooms must have 1-2 beds.");
    }
  }

  @override
  double calculateTotalCost(int nights) {
    double baseCost = basePrice * nights;
    double serviceCharge = getServiceCharge() * nights;
    return baseCost + serviceCharge;
  }

  @override
  List<String> getRoomFeatures() {
    List<String> features = [
      'Comfortable environment',
      'Private bathroom',
      'Adjustable bed',
      'Baby monitoring',
      'Lactation support',
    ];
    
    if (hasDeliveryEquipment) {
      features.add('Delivery equipment');
    }
    if (hasNewbornCare) {
      features.add('Newborn care station');
    }
    if (hasCompanionBed) {
      features.add('Companion bed');
    }
    
    return features;
  }

  @override
  double getServiceCharge() {
    double charge = 75.0; // Base maternity service charge
    if (hasDeliveryEquipment) charge += 50.0;
    if (hasNewbornCare) charge += 40.0;
    if (hasCompanionBed) charge += 15.0;
    return charge;
  }

  @override
  bool canAccommodateSpecialNeeds() {
    return true; // Maternity rooms have specialized care facilities
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['hasDeliveryEquipment'] = hasDeliveryEquipment;
    map['hasNewbornCare'] = hasNewbornCare;
    map['hasCompanionBed'] = hasCompanionBed;
    return map;
  }

  factory MaternityRoom.fromMap(Map<String, dynamic> map) {
    final room = MaternityRoom(
      roomNumber: map['roomNumber'],
      basePrice: (map['basePrice'] as num?)?.toDouble() ?? 300.0,
      beds: (map['beds'] as List)
          .map((bedMap) => Bed.fromMap(bedMap))
          .toList(),
      hasDeliveryEquipment: map['hasDeliveryEquipment'] ?? true,
      hasNewbornCare: map['hasNewbornCare'] ?? true,
      hasCompanionBed: map['hasCompanionBed'] ?? true,
    );
    room.isAvailable = map['isAvailable'] ?? true;
    return room;
  }
}
