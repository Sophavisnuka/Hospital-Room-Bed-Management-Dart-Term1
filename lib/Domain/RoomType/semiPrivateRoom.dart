import 'package:my_first_project/Domain/room.dart';
import 'package:my_first_project/Domain/bed.dart';

class SemiPrivateRoom extends Room {
  final bool hasCurtainDividers;
  final bool hasPersonalLocker;

  SemiPrivateRoom({
    required int roomNumber,
    required List<Bed> beds,
    double basePrice = 150.0,
    this.hasCurtainDividers = true,
    this.hasPersonalLocker = true,
  }) : super(
    roomNumber: roomNumber,
    roomType: RoomType.semiPrivate,
    basePrice: basePrice,
    beds: beds,
  ) {
    // Validate bed count for semi-private rooms (2-3 beds)
    if (beds.length < 2 || beds.length > 3) {
      throw ArgumentError("Semi-private rooms must have 2-3 beds.");
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
      'Shared bathroom',
      'TV',
      'Wi-Fi access',
      'Air conditioning',
      'Reading lights',
    ];
    
    if (hasCurtainDividers) {
      features.add('Privacy curtains');
    }
    if (hasPersonalLocker) {
      features.add('Personal lockers');
    }
    
    return features;
  }

  @override
  double getServiceCharge() {
    double charge = 15.0; // Base semi-private service charge
    if (hasPersonalLocker) charge += 5.0;
    return charge;
  }

  @override
  bool canAccommodateSpecialNeeds() {
    return false; // Basic semi-private rooms don't have special accessibility features
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['hasCurtainDividers'] = hasCurtainDividers;
    map['hasPersonalLocker'] = hasPersonalLocker;
    return map;
  }

  factory SemiPrivateRoom.fromMap(Map<String, dynamic> map) {
    final room = SemiPrivateRoom(
      roomNumber: map['roomNumber'],
      basePrice: (map['basePrice'] as num?)?.toDouble() ?? 150.0,
      beds: (map['beds'] as List)
          .map((bedMap) => Bed.fromMap(bedMap))
          .toList(),
      hasCurtainDividers: map['hasCurtainDividers'] ?? true,
      hasPersonalLocker: map['hasPersonalLocker'] ?? true,
    );
    room.isAvailable = map['isAvailable'] ?? true;
    return room;
  }
}
