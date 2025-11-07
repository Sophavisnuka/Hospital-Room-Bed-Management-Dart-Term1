import 'package:my_first_project/Domain/room.dart';
import 'package:my_first_project/Domain/bed.dart';

class VIPRoom extends Room {
  final bool hasLounge;
  final bool hasPrivateBathroom;

  VIPRoom({
    required int roomNumber,
    required List<Bed> beds,
    double basePrice = 250.0,
    this.hasLounge = true,
    this.hasPrivateBathroom = true,
  }) : super(
    roomNumber: roomNumber,
    roomType: RoomType.vip,
    basePrice: basePrice,
    beds: beds,
  );

  // Polymorphic implementation for VIP room
  @override
  double calculateTotalCost(int nights) {
    double baseCost = basePrice * nights;
    double serviceCharge = getServiceCharge() * nights;
    return baseCost + serviceCharge;
  }

  @override
  List<String> getRoomFeatures() {
    List<String> features = [
      'Large flat-screen TV',
      'Mini-fridge',
      'Room service',
      'High-speed Wi-Fi',
      'Air conditioning',
    ];
    
    if (hasLounge) {
      features.add('Private lounge');
    }
    if (hasPrivateBathroom) {
      features.add('Private bathroom');
    }
    
    return features;
  }

  @override
  double getServiceCharge() {
    double charge = 50.0; // Base VIP service charge
    if (hasLounge) charge += 25.0;
    if (hasPrivateBathroom) charge += 30.0;
    return charge;
  }

  @override
  bool canAccommodateSpecialNeeds() {
    return true; // VIP rooms have accessibility features
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['hasLounge'] = hasLounge;
    map['hasPrivateBathroom'] = hasPrivateBathroom;
    return map;
  }

  factory VIPRoom.fromMap(Map<String, dynamic> map) {
    final room = VIPRoom(
      roomNumber: map['roomNumber'],
      basePrice: (map['basePrice'] as num?)?.toDouble() ?? 250.0,
      beds: (map['beds'] as List)
          .map((bedMap) => Bed.fromMap(bedMap))
          .toList(),
      hasLounge: map['hasLounge'] ?? true,
      hasPrivateBathroom: map['hasPrivateBathroom'] ?? true,
    );
    // Set the availability from the map
    room.isAvailable = map['isAvailable'] ?? true;
    return room;
  }
}
