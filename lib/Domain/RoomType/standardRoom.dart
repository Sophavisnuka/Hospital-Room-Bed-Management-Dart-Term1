import 'package:my_first_project/Domain/room.dart';
import 'package:my_first_project/Domain/bed.dart';

class StandardRoom extends Room {
  StandardRoom({
    required int roomNumber,
    required List<Bed> beds,
    double basePrice = 100.0,
  }) : super(
    roomNumber: roomNumber,
    roomType: RoomType.standard,
    basePrice: basePrice,
    beds: beds,
  );

  // Polymorphic implementation for standard room
  @override
  double calculateTotalCost(int nights) {
    return basePrice * nights;
  }

  @override
  List<String> getRoomFeatures() {
    return [
      'Standard amenities',
      'Shared bathroom',
      'Basic TV',
      'Wi-Fi access',
      'Air conditioning',
    ];
  }

  @override
  double getServiceCharge() {
    return 0.0; // No additional service charge for standard rooms
  }

  @override
  bool canAccommodateSpecialNeeds() {
    return false; // Standard rooms don't have special accessibility features
  }

  factory StandardRoom.fromMap(Map<String, dynamic> map) {
    final room = StandardRoom(
      roomNumber: map['roomNumber'],
      basePrice: (map['basePrice'] as num?)?.toDouble() ?? 100.0,
      beds: (map['beds'] as List)
          .map((bedMap) => Bed.fromMap(bedMap))
          .toList(),
    );
    // Set the availability from the map
    room.isAvailable = map['isAvailable'] ?? true;
    return room;
  }
}