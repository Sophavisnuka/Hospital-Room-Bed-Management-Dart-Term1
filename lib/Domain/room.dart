import 'bed.dart';

enum RoomType {
  normal,
  vip_shared,
  vip_private,
  vip_single
}

class Room {
  int roomNumber;
  RoomType type;
  List<Bed> beds;

  Room({
    required this.roomNumber,
    required this.type,
    required this.beds,
  });

  bool hasAvailableBed() {
    return beds.any((bed) => !bed.isOccupied());
  }

  Bed? getAvailableBed() {
    try {
      return beds.firstWhere((bed) => !bed.isOccupied());
    } catch (e) {
      return null;
    }
  }

  void addBed(Bed bed) {
    beds.add(bed);
  }

  void removeBed(int bedNumber) {
    beds.removeWhere((bed) => bed.bedNumber == bedNumber);
  }

  void showStatus() {
    print('Room $roomNumber (${type.name}):');
    for (var bed in beds) {
      print('  Bed ${bed.bedNumber}: ${bed.isOccupied() ? "Occupied" : "Available"}');
    }
  }
}
