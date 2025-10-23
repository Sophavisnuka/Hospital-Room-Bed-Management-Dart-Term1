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
  final WorkShift workShift;
  final String position;

  Staff({
    final String? id,
    required final String name,
    required final int age,
    required final String gender,
    required final String phone,
    required final String dateOfBirth,
    required final WorkShift workShift,
    required final String position,
  }): id = id ?? uuid.v4(),
      workShift = workShift,
      position = position,
      super(
        name: name,
        age: age,
        gender: gender,
        phone: phone,
        dateOfBirth: dateOfBirth,
      );
  }