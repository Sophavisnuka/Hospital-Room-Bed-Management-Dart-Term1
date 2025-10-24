import 'package:uuid/uuid.dart';

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
}