abstract class Person {
  final String _name;
  final int? _age;
  final String? _phone;
  final String? _dateOfBirth;

  Person({
    required String name,
    int? age,
    String? phone,
    String? dateOfBirth,
    }) : _name = name,
         _age = age, 
         _phone = phone, 
         _dateOfBirth = dateOfBirth;

  String get name => _name;
  int? get age => _age;
  String? get phone => _phone;
  String? get dateOfBirth => _dateOfBirth;

  String displayInfo() {
    final parts = <String>[];
    parts.add('Name: $_name');
    if (_age != null) parts.add('Age: $_age');
    if (_phone != null) parts.add('Phone: $_phone');
    if (_dateOfBirth != null) parts.add('DOB: $_dateOfBirth');
    return parts.join(', ');
  }
} 