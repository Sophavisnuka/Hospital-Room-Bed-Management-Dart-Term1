import 'package:my_first_project/Domain/person.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();

class Patient extends Person {
  final String id;
  final String? _reason;
  final int? _nights;

  Patient({
    final String? id,
    required final String name,
    required final int age,
    required final String gender,
    final String? phone,
    final String? dateOfBirth,
    final String? reason,
    final int? nights = 1,
  }): id = id ?? uuid.v4(),
      _reason = reason,
      _nights = nights,
      super(
        name: name,
        age: age,
        gender: gender,
        phone: phone,
        dateOfBirth: dateOfBirth,
      );

  String? get reason => _reason;
  int? get nights => _nights;
}