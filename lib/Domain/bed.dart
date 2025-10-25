import 'package:uuid/uuid.dart';

const uuid = Uuid();

enum BedStatus {
  available,
  occupied,
  cleaning,
  maintenance,
}

class Bed {
  final String id;
  final String _roomId;
  final BedStatus _status;

  Bed({
    required String? id,
    required final String roomId,
    required final BedStatus status,
  }): id = id ?? uuid.v4(),
      _roomId = roomId,
      _status = status;

  String get roomId => _roomId;
  BedStatus get status => _status;
}
