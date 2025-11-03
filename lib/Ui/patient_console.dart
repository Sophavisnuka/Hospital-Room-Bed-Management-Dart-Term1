import 'dart:io';
import 'package:my_first_project/Domain/admission_service.dart';
import 'package:my_first_project/Domain/patient.dart';
import 'package:my_first_project/Domain/patient_service.dart';
import 'package:my_first_project/Util/validation.dart';
import 'package:my_first_project/Util/console_utils.dart';

class PatientConsole {
  // final Hospital hospital;
  final PatientService patientService;
  final AdmissionService admissionService;
  PatientConsole(this.patientService, this.admissionService);
  //register patient
  Future<void> registerPatient() async {
    print('=========================================');
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
    print('=========================================');

    final patient = Patient(
      name: name,
      age: age,
      gender: gender,
      phone: phone,
      dateOfBirth: dob,
      reason: reason,
      nights: nights,
    );
    await patientService.registerPatient(patient);
    print("\nPatient registered successfully!\n");
    print(patient.toString());
  }

  //view all patients
  Future<void> viewAllPatients() async {
    print(
        "===============================================================================");
    print(
        "${_padRight('Name', 25)} ${_padRight('Age', 5)} ${_padRight('Gender', 10)} ${_padRight('Reason', 20)}");
    print(
        "===============================================================================");
    if (patientService.patients.isEmpty) {
      print("No patients found.");
      return;
    }
    for (var p in patientService.patients) {
      String name = _truncate(p.name, 25);
      String age = _padRight(p.age.toString(), 5);
      String gender = _padRight(p.gender, 10);
      String reason = _truncate(p.reason ?? '', 20);
      print("$name $age $gender $reason");
    }
    print(
        "===============================================================================");
  }

  // Helper function to pad right with spaces
  String _padRight(String text, int width) {
    if (text.length >= width) {
      return text.substring(0, width);
    }
    return text.padRight(width);
  }

  // Helper function to truncate text if too long
  String _truncate(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text.padRight(maxLength);
    }
    return text.substring(0, maxLength - 3) + '...';
  }

  //edit patient
  Future<void> editPatient() async {
    stdout.write("Enter patient name to edit: ");
    String name = stdin.readLineSync()!;

    final patient = patientService.patients
        .firstWhere((p) => p.name.toLowerCase() == name.toLowerCase());
    print("\nLeave any field blank to keep current value.");

    print("\n=========================================");
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
    print("\n=========================================");

    final updatedPatient = Patient(
      id: patient.id, // keep same ID
      name: newName.isEmpty ? patient.name : newName,
      age: newAgeInput.isEmpty ? patient.age : int.parse(newAgeInput),
      gender: newGender.isEmpty ? patient.gender : newGender,
      phone: newPhone.isEmpty ? patient.phone : newPhone,
      dateOfBirth: newDOB.isEmpty ? patient.dateOfBirth : newDOB,
      reason: newReason.isEmpty ? patient.reason : newReason,
      nights:
          newNightsInput.isEmpty ? patient.nights : int.parse(newNightsInput),
    );

    await patientService.editPatient(updatedPatient);
  }

  //delete patient
  Future<void> deletePatient() async {
    stdout.write("Enter patient name to delete: ");
    String name = stdin.readLineSync()!;
    await patientService.deletePatient(name);
  }

  //search patient
  Future<void> findPatientByKeyword() async {
    stdout.write("========================================");
    stdout.write("\nEnter keyword to search patient: ");
    String keyword = stdin.readLineSync()!;
    patientService.searchPatient(keyword);
  }

  Future<void> admitPatient() async {
    // Implementation for admitting a patient
    stdout.write('Enter patient name to admit: ');
    String patientName = stdin.readLineSync()!;
    stdout.write('Enter room number to admit to: ');
    int roomNumber = int.parse(stdin.readLineSync()!);
    stdout.write('Enter bed number to admit to: ');
    String bedNumber = stdin.readLineSync()!;
    DateTime admissionDate = DateTime.now();
    await admissionService.admitPatient(patientName, roomNumber, bedNumber, admissionDate);
  }

  Future<void> transferPatient() async {
    // Implementation for transferring a patient
    stdout.write('Enter patient name to transfer: ');
    String patientName = stdin.readLineSync()!;
    stdout.write('Enter current room number: ');
    int currentRoomNum = int.parse(stdin.readLineSync()!);
    stdout.write('Enter current bed number: ');
    String currentBedNum = stdin.readLineSync()!;
    stdout.write('Enter new room number: ');
    int newRoomNum = int.parse(stdin.readLineSync()!);
    stdout.write('Enter new bed number: ');
    String newBedNum = stdin.readLineSync()!;
    stdout.write('Enter reason for transfer: ');
    String transferReason = stdin.readLineSync()!;
    if (patientName.isEmpty || currentBedNum.isEmpty || newBedNum.isEmpty || transferReason.isEmpty || currentRoomNum <=0 || newRoomNum <=0) {
      print('Finished updating bed statuses.');
      pressEnterToContinue();
    }
    await admissionService.transferPatient(patientName: patientName, currentRoomNum: currentRoomNum, currentBedNum: currentBedNum, newRoomNum: newRoomNum, newBedNum: newBedNum, transferReason: transferReason);
  }

  Future<void> dischargePatient() async {
    stdout.write('Enter patient name to discharge: ');
    String patientName = stdin.readLineSync()!;
    stdout.write('Enter room number: ');
    int roomNumber = int.parse(stdin.readLineSync()!);
    stdout.write('Enter bed number: ');
    String bedNumber = stdin.readLineSync()!;
    await admissionService.dischargePatient(patientName: patientName, roomNumber: roomNumber, bedNumber: bedNumber, dischargeReason: 'Patient discharged');
  }

  Future<void> displayPatientUi() async {
    // Implementation for displaying the UI
    while (true) {
      print("\n========================================");
      print("patientService Management System - Patients");
      print("========================================");
      print("1. View All Patients");
      print("2. Register New Patient");
      print("3. Edit Patient");
      print("4. Delete Patient");
      print("5. Search Patient");
      print("6. Admit Patient");
      print("7. Transfer Patient");
      print("8. Discharge Patient");
      print("========================================");
      print("0. Back to Main Menu");
      print("========================================");
      stdout.write('Your choice: ');
      String? input = stdin.readLineSync();
      clearScreen();
      switch (input) {
        case '1':
          await viewAllPatients();
          pressEnterToContinue();
          break;
        case '2':
          await registerPatient();
          pressEnterToContinue();
          break;
        case '3':
          await editPatient();
          pressEnterToContinue();
          break;
        case '4':
          await deletePatient();
          pressEnterToContinue();
          break;
        case '5':
          await findPatientByKeyword();
          pressEnterToContinue();
          break;
        case '6':
          await admitPatient();
          pressEnterToContinue();
          break;
        case '7':
          await transferPatient();
          pressEnterToContinue();
          break;
        case '8':
          await dischargePatient();
          pressEnterToContinue();
          break;
        case '0':
          return;
        default:
          print('Invalid choice. Please select a valid option.');
          pressEnterToContinue();
      }
    }
  }
}
