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
    print('\n=========================================');
    print('--------- Register New Patient ----------');
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
    if (patientService.patients.isEmpty) {
      print("No patients found.");
      return;
    }
    
    print("===============================================================================");
    print("                           ALL REGISTERED PATIENTS");
    print("===============================================================================");
    
    for (int i = 0; i < patientService.patients.length; i++) {
      var patient = patientService.patients[i];
      
      print("\n--- Patient ${i + 1} ---");
      print("Patient ID: ${patient.id}");
      print("Name: ${patient.name}");
      print("Age: ${patient.age} years old");
      print("Gender: ${patient.gender}");
      print("Phone: ${patient.phone ?? 'Not provided'}");
      print("Date of Birth: ${patient.dateOfBirth ?? 'Not provided'}");
      print("Reason for Admission: ${patient.reason ?? 'Not specified'}");
      print("Number of Nights: ${patient.nights ?? 'Not specified'}");
      print("Registration Date: ${DateTime.now().toLocal().toString().split(' ')[0]}");
      print("-------------------------");
    }
    
    print("\nTotal Patients: ${patientService.patients.length}");
    print("===============================================================================");
  }

  //edit patient
  Future<void> editPatient() async {
    print('\n=========================================');
    print('--------- Edit Patient Details ----------');
    print('=========================================');
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
    print('\n=========================================');
    print('----------- Delete Patient --------------');
    print('=========================================');
    stdout.write("Enter patient name to delete: ");
    String name = stdin.readLineSync()!;
    await patientService.deletePatient(name);
  }

  //search patient
  Future<void> findPatientByKeyword() async {
    print('\n=========================================');
    print('----------- Search Patient --------------');
    print('=========================================');
    print("Patient Search Options:");
    print("1. Search by name, phone, or reason");
    print("2. Search by exact name");
    print("========================================");
    stdout.write("Choose search option (1-2): ");
    String? searchOption = stdin.readLineSync();
    
    if (searchOption == null || (searchOption != '1' && searchOption != '2')) {
      print("Invalid option. Please choose 1 or 2.");
      return;
    }
    
    stdout.write("Enter search term: ");
    String keyword = stdin.readLineSync()!;
    
    if (keyword.trim().isEmpty) {
      print("Search term cannot be empty.");
      return;
    }
    
    List<Patient> searchResults = [];
    
    if (searchOption == '1') {
      // Search by keyword (name, phone, reason)
      searchResults = patientService.searchPatient(keyword);
    } else if (searchOption == '2') {
      // Search by exact name
      final patient = patientService.findPatientByName(keyword);
      if (patient != null) {
        searchResults = [patient];
      }
    }
    
    if (searchResults.isEmpty) {
      print("\nNo patients found matching '$keyword'.");
      return;
    }
    
    print("\nFound ${searchResults.length} patient(s) matching '$keyword':");
    print("=========================================================================");
    
    for (int i = 0; i < searchResults.length; i++) {
      final patient = searchResults[i];
      print("\n--- Patient ${i + 1} ---");
      print("ID: ${patient.id}");
      print("Name: ${patient.name}");
      print("Age: ${patient.age} years old");
      print("Gender: ${patient.gender}");
      print("Phone: ${patient.phone ?? 'N/A'}");
      print("Date of Birth: ${patient.dateOfBirth ?? 'N/A'}");
      print("Reason for Admission: ${patient.reason ?? 'N/A'}");
      print("Number of Nights: ${patient.nights ?? 'N/A'}");
      print("-------------------------");
    }
    
    print("\n Search completed. Found ${searchResults.length} patient(s).");
    print("=========================================================================");
  }

  Future<void> admitPatient() async {
    // Implementation for admitting a patient
    print('\n=========================================');
    print('----------- Admit Patient --------------');
    print('=========================================');
    stdout.write('Enter patient name to admit: ');
    String patientName = stdin.readLineSync()!;
    stdout.write('Enter room number to admit to: ');
    int roomNumber = int.parse(stdin.readLineSync()!);
    stdout.write('Enter bed number to admit to: ');
    String bedNumber = stdin.readLineSync()!;
    DateTime admissionDate = DateTime.now();
    await admissionService.admitPatient(patientName: patientName, roomNumber: roomNumber, bedNumber: bedNumber, admissionDate: admissionDate);
  }

  Future<void> transferPatient() async {
    print('\n=========================================');
    print('----------- Transfer Patient -------------');
    print('=========================================');
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
    print('\n=========================================');
    print('----------- Discharge Patient -----------');
    print('=========================================');
    stdout.write('Enter patient name to discharge: ');
    String patientName = stdin.readLineSync()!;
    stdout.write('Enter room number: ');
    int roomNumber = int.parse(stdin.readLineSync()!);
    stdout.write('Enter bed number: ');
    String bedNumber = stdin.readLineSync()!;
    await admissionService.dischargePatient(patientName: patientName, roomNumber: roomNumber, bedNumber: bedNumber, dischargeReason: 'discharged');
  }

  Future<void> displayPatientUi() async {
    // Implementation for displaying the UI
    while (true) {
      clearScreen();
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
