import 'dart:io';
import 'Domain/hospital.dart';
import 'Ui/patient_console.dart';
import 'Ui/admission_console.dart';
import 'Ui/room_console.dart';

Future<void> main() async {
  final hospital = Hospital(name: "City Hospital", address: "123 Main St");
  
  // Load existing data from JSON files BEFORE showing menu
  print('Loading hospital data...');
  await hospital.loadAllData();
  print('Data loaded successfully!\n');
  
  PatientConsole patientConsole = PatientConsole(hospital);
  AdmissionConsole admissionConsole = AdmissionConsole(hospital);
  RoomConsole roomConsole = RoomConsole(hospital);

  while (true) {
    print('\n========================================');
    print('Welcome to the Hospital Management System');
    print('========================================');
    print('1. Manage Patients');
    print('2. Manage Rooms');
    print('3. Manage Admissions');
    print('4. Exit Program');
    stdout.write('Your choice: ');
    
    String? input = stdin.readLineSync();
    switch(input) {
      case '1':
        print('\nPatient Menu..');
        await patientConsole.displayPatientUi();
        break;
      case '2':
        print('\nRooms Menu..');
        await roomConsole.displayRoomUi();
        break;
      case '3':
        print('\nAdmission Menu..');
        await admissionConsole.displayAdmissionUi();
        break;
      case '4':
        print('\nThank you for using Hospital Management System!');
        exit(0);
      default:
        print('Invalid choice. Please select a valid option.');
    }
  }
}