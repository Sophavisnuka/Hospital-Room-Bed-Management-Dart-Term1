import 'package:uuid/uuid.dart';
import 'package:my_first_project/Domain/bed.dart';

enum RoomType {
  normal,
  vip_shared,
  vip_single,
}

const uuid = Uuid();
class Room{
  final String id;
  final List<String> _bedId;
  final RoomType _roomType;
  final List<String> _patientId;
  final bool _isClean;
  final List<Bed> beds = [];

  Room({
    required String? id,
    required final List<String> bedId,
    required final RoomType roomType,
    required final List<String> patientId,
    required final bool isClean,
  }): id = id ?? uuid.v4(),
      _bedId = bedId,
      _roomType = roomType,
      _patientId = patientId,
      _isClean = isClean;
  List<String> get bedId => _bedId;
  RoomType get roomType => _roomType;
  List<String> get patientId => _patientId;
  bool get isClean => _isClean;

  //method
  bool isAvailableRoom () {
    if (beds.isEmpty) {
      return false;
    }
    for (var bed in beds) {
      if (isAvailableBed(bed)) {
        return true;
      }
    }
    return false;
  }
  bool isAvailableBed (Bed bed) {
    if (bed.status == BedStatus.occupied || bed.status == BedStatus.cleaning || bed.status == BedStatus.maintenance) {
      return false;
    } 
    return bed.status == BedStatus.available;
  }
}