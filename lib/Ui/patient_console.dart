import 'dart:io';
import 'package:my_first_project/Domain/hospital.dart';
import 'package:my_first_project/Domain/patient.dart';
import 'package:my_first_project/Util/validation.dart';

class PatientConsole {

  final Hospital hospital;
  PatientConsole(this.hospital);
  //register patient
  void registerPatient() {
    // Load existing data if available
    hospital.loadFromJson();
    stdout.write("Enter patient name: ");
    String name = stdin.readLineSync()!;
    stdout.write("Enter age: ");
    int age = int.parse(stdin.readLineSync()!);
    String gender = validateGender();    
    String phone = validatePhoneNum();     
    String dob = validateDateOfBirth();
    stdout.write("Enter reason for admission: ");
    String reason = stdin.readLineSync()!;
    stdout.write("Enter number of nights: ");
    int nights = int.parse(stdin.readLineSync()!);
    final patient = Patient(
      name: name,
      age: age,
      gender: gender,
      phone: phone,
      dateOfBirth: dob,
      reason: reason,
      nights: nights,
    );
    hospital.registerPatient(patient);
    print("\nPatient registered successfully!\n");
    print(patient.toString());
    // Save new data to file
    hospital.saveToJson();
  }
  //view all patients
  void viewAllPatients() {
    hospital.loadFromJson();

    print("\n\tName\t\tAge\tGender\tReason");
    print("-------------------------------------------------------");
    if (hospital.patients.isEmpty) {
      print("No patients found.");
      return;
    }
    for (var p in hospital.patients) {
      print("\t${p.name}\t${p.age}\t${p.gender}\t${p.reason}");
    }
  }
  //delete patient
  void deletePatient() {
    hospital.loadFromJson();
    stdout.write("Enter patient name to delete: ");
    String name = stdin.readLineSync()!;
    hospital.deletePatient(name);
  }
  //edit patient
  void editPatient() {
    hospital.loadFromJson();

    stdout.write("Enter patient name to edit: ");
    String name = stdin.readLineSync()!;

    final patient = hospital.patients.firstWhere((p) => p.name.toLowerCase() == name.toLowerCase());
    print("\nLeave any field blank to keep current value.");

    stdout.write("New name (${patient.name}): ");
    String newName = stdin.readLineSync()!;
    stdout.write("New age (${patient.age}): ");
    String newAgeInput = stdin.readLineSync()!;
    stdout.write("New gender (${patient.gender}): ");
    String newGender = stdin.readLineSync()!;
    stdout.write("New phone (${patient.phone ?? 'N/A'}): ");
    String newPhone = stdin.readLineSync()!;
    stdout.write("New date of birth (${patient.dateOfBirth ?? 'N/A'}): ");
    String newDOB = stdin.readLineSync()!;
    stdout.write("New reason (${patient.reason ?? 'N/A'}): ");
    String newReason = stdin.readLineSync()!;
    stdout.write("New number of nights (${patient.nights ?? 0}): ");
    String newNightsInput = stdin.readLineSync()!;

    final updatedPatient = Patient(
      id: patient.id, // keep same ID
      name: newName.isEmpty ? patient.name : newName,
      age: newAgeInput.isEmpty ? patient.age : int.parse(newAgeInput),
      gender: newGender.isEmpty ? patient.gender : newGender,
      phone: newPhone.isEmpty ? patient.phone : newPhone,
      dateOfBirth: newDOB.isEmpty ? patient.dateOfBirth : newDOB,
      reason: newReason.isEmpty ? patient.reason : newReason,
      nights: newNightsInput.isEmpty ? patient.nights : int.parse(newNightsInput),
    );

    hospital.editPatient(updatedPatient);
  }

  void displayPatientUi() {
    // Implementation for displaying the UI
    print("\nHospital Management System UI");
    print("------------------------------");
    print("1. View All Patients");
    print("2. Register New Patient");
    print("3. Edit Patient");
    print("4. Delete Patient");
    print("5. Admit Patient");
    print("6. Transfer Patient");
    print("7. Search Patient");
    print("8. Exit");
    stdout.write('Your choice: ');
    String? input = stdin.readLineSync();
    switch (input) {
      case '1': 
        viewAllPatients();
        break;
      case '2':
        registerPatient();
        break;
      case '3':
        editPatient();
        break;
      case '4':
        deletePatient();
        break;
      case '5':
        break;
      case  '6':
        break;
      default:
        print('Invalid choice. Please select a valid option.');
    }
  }
}