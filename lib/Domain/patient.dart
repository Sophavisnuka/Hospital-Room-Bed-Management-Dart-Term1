import 'booking.dart';

class Person {
  String name;
  int age;

  Person({
    required this.name,
    required this.age,
  });

  void displayInfo() {
    print('Name: $name, Age: $age');
  }
}

class Patient extends Person {
  int id;
  String reason;
  int nights;
  Booking? booking;

  Patient({
    required this.id,
    required String name,
    required int age,
    required this.reason,
    required this.nights,
    this.booking,
  }) : super(name: name, age: age);

  @override
  void displayInfo() {
    super.displayInfo();
    print('ID: $id, Reason: $reason, Nights: $nights');
  }
}
