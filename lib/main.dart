import 'dart:io';
import 'Domain/hospital.dart';
import 'Ui/patient_console.dart';
import 'Ui/admission_console.dart';
import 'Ui/room_console.dart';
import 'Util/console_utils.dart';

Future<void> main() async {
  final hospital = Hospital(name: "City Hospital", address: "123 Main St");
  
  // Load existing data from JSON files BEFORE showing menu
  clearScreen();
  print('=========================================');
  print('Loading hospital data...');
  await hospital.loadAllData();
  print('Data loaded successfully!');
  print('=========================================');

  PatientConsole patientConsole = PatientConsole(hospital.patientService, hospital.admissionService);
  AdmissionConsole admissionConsole = AdmissionConsole(hospital.admissionService);
  RoomConsole roomConsole = RoomConsole(hospital.roomService);

  while (true) {
    print('\n=========================================');
    print('Welcome to the Hospital Management System');
    print('=========================================');
    print('1. Manage Patients');
    print('2. Manage Rooms');
    print('3. Manage Admissions');
    print('=========================================');
    print('0. Exit Program');
    print('=========================================');
    stdout.write('Your choice: ');
    
    String? input = stdin.readLineSync();
    clearScreen();
    switch(input) {
      case '1':
        await patientConsole.displayPatientUi();
        break;
      case '2':
        await roomConsole.displayRoomUi();
        break;
      case '3':
        await admissionConsole.displayAdmissionUi();
        break;
      case '0':
        print('\n=========================================');
        print('Thank you for using Hospital Management System!');
        print('=========================================');
        exit(0);
      default:
        print('Invalid choice. Please select a valid option.');
        pressEnterToContinue();
    }
  }
}