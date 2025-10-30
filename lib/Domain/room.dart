import 'package:uuid/uuid.dart';
import 'package:my_first_project/Domain/bed.dart';
import 'package:my_first_project/Domain/standardRoom.dart';
import 'package:my_first_project/Domain/vipRoom.dart';

enum RoomType {
  normal,
  vip,
}

const uuid = Uuid();

abstract class Room {
  String id;
  final int roomNumber;
  final List<Bed> beds;
  final RoomType roomType;
  final double basePrice;
  bool isAvailable;

  Room({
    String? id,
    required this.basePrice,
    required this.roomNumber,
    required this.beds,
    required this.roomType,
    this.isAvailable = true,
  })  : id = id ?? uuid.v4();

  // Getters
  int get roomNum => roomNumber;

  set roomNum(int roomNumber) {
    if (roomNumber <= 0) {
      throw ArgumentError("Room number must be positive.");
    }
  }

  bool isAvailableBed(Bed bed) {
    return bed.status == BedStatus.available;
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'roomNumber': roomNumber,
      'roomType': roomType.toString().split('.').last,
      'basePrice': basePrice,
      'bed quality': beds.length,
      'beds': beds.map((bed) => bed.toMap()).toList(),
      'isAvailable': isAvailable,
    };
  }
  factory Room.fromMap(Map<String, dynamic> map) {
    final type = RoomType.values.firstWhere(
      (e) => e.toString().split('.').last == map['roomType']
    );
    switch (type) {
      case RoomType.normal:
        return StandardRoom.fromMap(map);
      case RoomType.vip:
        return VIPRoom.fromMap(map);
    }
  }
}
