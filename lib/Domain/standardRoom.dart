import 'package:my_first_project/Domain/room.dart';
import 'package:my_first_project/Domain/bed.dart';

class StandardRoom extends Room {
  StandardRoom({
    required int roomNumber,
    required List<Bed> beds,
  }) : super(
    roomNumber: roomNumber,
    roomType: RoomType.normal,
    basePrice: 100.0, // Base price per night
    beds: beds,
  );

  factory StandardRoom.fromMap(Map<String, dynamic> map) {
    return StandardRoom(
      roomNumber: map['roomNumber'],
      beds: (map['beds'] as List)
          .map((bedMap) => Bed.fromMap(bedMap))
          .toList(),
    )
    ..id = map['id']
    ..isAvailable = map['isAvailable'];
  }
}