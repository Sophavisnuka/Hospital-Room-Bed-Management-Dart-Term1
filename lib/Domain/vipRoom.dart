import 'package:my_first_project/Domain/room.dart';
import 'package:my_first_project/Domain/bed.dart';

class VIPRoom extends Room {
  final bool hasLounge;
  final bool hasPrivateBathroom;

  VIPRoom({
    required int roomNumber,
    required List<Bed> beds,
    this.hasLounge = true,
    this.hasPrivateBathroom = true,
  }) : super(
    roomNumber: roomNumber,
    roomType: RoomType.vip,
    basePrice: 250.0, // Higher base price for VIP
    beds: beds,
  );

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map['hasLounge'] = hasLounge;
    map['hasPrivateBathroom'] = hasPrivateBathroom;
    return map;
  }

  factory VIPRoom.fromMap(Map<String, dynamic> map) {
    return VIPRoom(
      roomNumber: map['roomNumber'],
      beds: (map['beds'] as List)
          .map((bedMap) => Bed.fromMap(bedMap))
          .toList(),
      hasLounge: map['hasLounge'],
      hasPrivateBathroom: map['hasPrivateBathroom'],
    )
      ..id = map['id']
      ..isAvailable = map['isAvailable'];
  }
}
