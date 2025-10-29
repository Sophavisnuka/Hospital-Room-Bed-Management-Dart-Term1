import 'dart:io';
import 'package:my_first_project/Domain/hospital.dart';
import 'package:my_first_project/Domain/patient.dart';
import 'package:my_first_project/Util/validation.dart';

class PatientConsole {

  final Hospital hospital;
  PatientConsole(this.hospital);
  //register patient
  Future<void> registerPatient() async {

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
    await hospital.registerPatient(patient);
    print("\nPatient registered successfully!\n");
    print(patient.toString());
  }
  //view all patients
  Future<void> viewAllPatients() async {
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
  //edit patient
  Future<void> editPatient() async {

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

    await hospital.editPatient(updatedPatient);
  }
    //delete patient
  Future<void> deletePatient() async {
    stdout.write("Enter patient name to delete: ");
    String name = stdin.readLineSync()!;
    await hospital.deletePatient(name);
  }
  //search patient
  Future<void> findPatientByKeyword() async {
    stdout.write("Enter keyword to search patient: ");
    String keyword = stdin.readLineSync()!;
    hospital.searchPatient(keyword);
  }

  Future<void> displayPatientUi() async {
    // Implementation for displaying the UI
    while(true) {
      print("\n========================================");
      print("Hospital Management System - Patients");
      print("========================================");
      print("1. View All Patients");
      print("2. Register New Patient");
      print("3. Edit Patient");
      print("4. Delete Patient");
      print("5. Search Patient");
      print("6. Admit Patient");
      print("7. Transfer Patient");
      print("8. Exit");
      stdout.write('Your choice: ');
      String? input = stdin.readLineSync();
      switch (input) {
        case '1': 
          await viewAllPatients();
          break;
        case '2':
          await registerPatient();
          break;
        case '3':
          await editPatient();
          break;
        case '4':
          await deletePatient();
          break;
        case '5':
          await findPatientByKeyword();
          break;
        case '6':
          break;
        case '7':
          break;
        case '8':
          return;
        default:
          print('Invalid choice. Please select a valid option.');
      }
    }
    }
}