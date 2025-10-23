abstract class Person {
  final String _name;
  final int _age;
  final String _gender;
  final String? _phone;
  final String? _dateOfBirth;

  Person({
    required String name,
    required final int age,
    required final String gender,
    final String? phone,
    final String? dateOfBirth,
  })  : _name = name,
        _age = age,
        _gender = gender,
        _phone = phone,
        _dateOfBirth = dateOfBirth;

  String get name => _name;
  int get age => _age;
  String get gender => _gender;
  String? get phone => _phone;
  String? get dateOfBirth => _dateOfBirth;

  @override
  String toString() {
    return """
    name: $_name, 
    age: $_age, 
    gender: $_gender, 
    phone: $_phone, 
    dateOfBirth: $_dateOfBirth,
    """;
  }
}