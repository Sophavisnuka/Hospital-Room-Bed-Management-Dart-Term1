import 'package:uuid/uuid.dart';

const uuid = Uuid();

class Bed {
  final String id;
  final String _roomId;
  final bool _isOccupied;

  Bed({
    required String? id,
    required final String roomId,
    required final bool isOccupied,
  }): id = id ?? uuid.v4(),
      _roomId = roomId,
      _isOccupied = isOccupied;

  String get roomId => _roomId;
  bool get isOccupied => _isOccupied;
}
