import 'package:my_first_project/Domain/room.dart';
import 'package:my_first_project/Domain/bed.dart';

class PrivateRoom extends Room {
  final bool hasPrivateBathroom;
  final bool hasTV;
  final bool hasGuestChair;

  PrivateRoom({
    required int roomNumber,
    required List<Bed> beds,
    double basePrice = 200.0,
    this.hasPrivateBathroom = true,
    this.hasTV = true,
    this.hasGuestChair = true,
  }) : super(
    roomNumber: roomNumber,
    roomType: RoomType.private,
    basePrice: basePrice,
    beds: beds,
  ) {
    // Validate bed count for private rooms (1 bed only)
    if (beds.length != 1) {
      throw ArgumentError("Private rooms must have exactly 1 bed.");
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
      'Full privacy',
      'Wi-Fi access',
      'Air conditioning',
      'Reading lights',
      'Work desk',
    ];
    
    if (hasPrivateBathroom) {
      features.add('Private bathroom');
    }
    if (hasTV) {
      features.add('Flat-screen TV');
    }
    if (hasGuestChair) {
      features.add('Guest chair');
    }
    
    return features;
  }

  @override
  double getServiceCharge() {
    double charge = 25.0; // Base private room service charge
    if (hasPrivateBathroom) charge += 15.0;
    if (hasTV) charge += 5.0;
    return charge;
  }

  @override
  bool canAccommodateSpecialNeeds() {
    return true; // Private rooms can accommodate special needs
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['hasPrivateBathroom'] = hasPrivateBathroom;
    map['hasTV'] = hasTV;
    map['hasGuestChair'] = hasGuestChair;
    return map;
  }

  factory PrivateRoom.fromMap(Map<String, dynamic> map) {
    final room = PrivateRoom(
      roomNumber: map['roomNumber'],
      basePrice: (map['basePrice'] as num?)?.toDouble() ?? 200.0,
      beds: (map['beds'] as List)
          .map((bedMap) => Bed.fromMap(bedMap))
          .toList(),
      hasPrivateBathroom: map['hasPrivateBathroom'] ?? true,
      hasTV: map['hasTV'] ?? true,
      hasGuestChair: map['hasGuestChair'] ?? true,
    );
    room.isAvailable = map['isAvailable'] ?? true;
    return room;
  }
}
