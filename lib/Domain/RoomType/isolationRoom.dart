import 'package:my_first_project/Domain/room.dart';
import 'package:my_first_project/Domain/bed.dart';

class IsolationRoom extends Room {
  final bool hasNegativePressure;
  final bool hasAntechamber;
  final String isolationType; // e.g., 'airborne', 'droplet', 'contact'

  IsolationRoom({
    required int roomNumber,
    required List<Bed> beds,
    double basePrice = 400.0,
    this.hasNegativePressure = true,
    this.hasAntechamber = true,
    this.isolationType = 'airborne',
  }) : super(
    roomNumber: roomNumber,
    roomType: RoomType.isolation,
    basePrice: basePrice,
    beds: beds,
  ) {
    // Validate bed count for isolation rooms (typically 1 bed for safety)
    if (beds.length != 1) {
      throw ArgumentError("Isolation rooms must have exactly 1 bed.");
    }
    // Validate isolation type
    final validTypes = ['airborne', 'droplet', 'contact', 'protective'];
    if (!validTypes.contains(isolationType.toLowerCase())) {
      throw ArgumentError(
        "Isolation type must be one of: ${validTypes.join(', ')}"
      );
    }
  }

  @override
  double calculateTotalCost(int nights) {
    double baseCost = basePrice * nights;
    double serviceCharge = getServiceCharge() * nights;
    // Isolation has additional safety and cleaning costs
    double safetyProtocolCost = 75.0 * nights;
    return baseCost + serviceCharge + safetyProtocolCost;
  }

  @override
  List<String> getRoomFeatures() {
    List<String> features = [
      'Infection control protocols',
      'HEPA filtration',
      'Restricted access',
      'Specialized ventilation',
      'Private bathroom',
    ];
    
    if (hasNegativePressure) {
      features.add('Negative pressure ventilation');
    }
    if (hasAntechamber) {
      features.add('Anteroom/Antechamber');
    }
    features.add('Isolation type: ${isolationType.toUpperCase()}');
    
    return features;
  }

  @override
  double getServiceCharge() {
    double charge = 100.0; // Base isolation service charge
    if (hasNegativePressure) charge += 50.0;
    if (hasAntechamber) charge += 30.0;
    // Different isolation types may have different costs
    switch (isolationType.toLowerCase()) {
      case 'airborne':
        charge += 40.0;
        break;
      case 'droplet':
        charge += 30.0;
        break;
      case 'contact':
        charge += 20.0;
        break;
      case 'protective':
        charge += 35.0;
        break;
    }
    return charge;
  }

  @override
  bool canAccommodateSpecialNeeds() {
    return true; // Isolation rooms have specialized equipment
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['hasNegativePressure'] = hasNegativePressure;
    map['hasAntechamber'] = hasAntechamber;
    map['isolationType'] = isolationType;
    return map;
  }

  factory IsolationRoom.fromMap(Map<String, dynamic> map) {
    final room = IsolationRoom(
      roomNumber: map['roomNumber'],
      basePrice: (map['basePrice'] as num?)?.toDouble() ?? 400.0,
      beds: (map['beds'] as List)
          .map((bedMap) => Bed.fromMap(bedMap))
          .toList(),
      hasNegativePressure: map['hasNegativePressure'] ?? true,
      hasAntechamber: map['hasAntechamber'] ?? true,
      isolationType: map['isolationType'] ?? 'airborne',
    );
    room.isAvailable = map['isAvailable'] ?? true;
    return room;
  }
}
