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
  final BedStatus _status;
  final String bedNumber;

  Bed({
    required String? id,
    required final BedStatus status,
    required this.bedNumber,
  }): id = id ?? uuid.v4(),
      _status = status;
  BedStatus get status => _status;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'status': _status.toString().split('.').last,
      'bedNumber': bedNumber,
    };
  }
  factory Bed.fromMap(Map<String, dynamic> map) {
    return Bed(
      id: map['id'],
      status: BedStatus.values.firstWhere(
        (e) => e.toString() == 'BedStatus.' + map['status']
      ),
      bedNumber: map['bedNumber'],
    );
  }
}
