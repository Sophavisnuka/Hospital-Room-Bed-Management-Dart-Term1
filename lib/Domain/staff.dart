import 'package:my_first_project/Domain/person.dart';
import 'package:uuid/uuid.dart';

enum WorkShift {
  morning,
  afternoon,
  evening,
  night,
}

final uuid = Uuid();

class Staff extends Person {
  final String id;
  final WorkShift _workShift;
  final String _position;
  final List<String> _admissionId;

  Staff({
    final String? id,
    required String name,
    required int age,
    required String gender,
    required String phone,
    required String dateOfBirth,
    required final WorkShift workShift,
    required final String position,
    required final List<String> admissionId,
  }): id = id ?? uuid.v4(),
      _workShift = workShift,
      _position = position,
      _admissionId = admissionId,
      super(
        name: name,
        age: age,
        gender: gender,
        phone: phone,
        dateOfBirth: dateOfBirth,
      );

  WorkShift get workShift => _workShift;
  String get position => _position;
  List<String> get admissionId => _admissionId;
}