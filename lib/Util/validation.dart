import 'dart:io';

String validatePhoneNum() {
  while (true) {
    stdout.write("Enter phone number: ");
    String phoneNumber = stdin.readLineSync()!.trim();

    final phoneRegExp = RegExp(r'^\+?[0-9]{7,15}$');

    if (!phoneRegExp.hasMatch(phoneNumber)) {
      print("Invalid phone number format. Must be 7–15 digits (with optional +).");
      continue; // ask again
    }

    return phoneNumber; // valid number
  }
}

String validateDateOfBirth() {
  while (true) {
    stdout.write("Enter Date of Birth (dd-mm-yyyy): ");
    String dob = stdin.readLineSync()!.trim();

    final dobRegExp = RegExp(r'^\d{2}-\d{2}-\d{4}$');
    if (dob.isEmpty) {
      print("Date of Birth cannot be empty.");
      continue;
    }

    if (!dobRegExp.hasMatch(dob)) {
      print("Invalid format. Please use dd-mm-yyyy.");
      continue;
    }

    try {
      // Check if valid date and not in the future
      final parts = dob.split('-');
      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]);
      final date = DateTime(year, month, day);

      if (date.isAfter(DateTime.now())) {
        print("Date of Birth cannot be in the future.");
        continue;
      }

      if (date.day != day || date.month != month || date.year != year) {
        print("Invalid date values. Please check again.");
        continue;
      }

      return dob; // valid
    } catch (e) {
      print("Invalid date. Please re-enter.");
    }
  }
}

String validateGender() {
  while (true) {
    stdout.write("Enter gender (male/female/other): ");
    String gender = stdin.readLineSync()!.trim().toLowerCase();

    final validGenders = ['male', 'female', 'other', 'm', 'f'];

    if (gender.isEmpty) {
      print("Gender cannot be empty.");
      continue;
    }

    if (!validGenders.contains(gender)) {
      print("Invalid gender. Please enter 'male', 'female', or 'other'.");
      continue;
    }

    return gender; //valid gender
  }
}
