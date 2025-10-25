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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'phone': phone,
      'date of birth': dateOfBirth,
      'reason': _reason,
      'nights': _nights,
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'],
      name: map['name'],
      age: map['age'],
      gender: map['gender'],
      phone: map['phone'],
      dateOfBirth: map['date of birth'],
      reason: map['reason'],
      nights: map['nights'],
    );
  }

  @override
  String toString() {
    return '\nPatient id: $id, \nname: $name, \nage: $age, \ngender: $gender, \nphone: $phone, dateOfBirth: $dateOfBirth, reason: $_reason, nights: $_nights';
  }
}