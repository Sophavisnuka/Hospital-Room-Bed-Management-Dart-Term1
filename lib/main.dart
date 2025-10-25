import 'dart:io';
import 'Domain/hospital.dart';
import 'Ui/patient_console.dart';
import 'Ui/admission_console.dart';
import 'Ui/room_console.dart';

void main () {
  final hospital = Hospital(name: "City Hospital", address: "123 Main St");
  PatientConsole patientConsole = PatientConsole(hospital);
  AdmissionConsole admissionConsole = AdmissionConsole(hospital);
  RoomConsole roomConsole = RoomConsole(hospital);

  print('Welcome to the Hospital Management System');
  print('-----------------------------------------');
  print('1. Manage Patients');
  print('2. Manage Rooms');
  print('3. Manage Admissions');
  stdout.write('Your choice: ');
  String? input = stdin.readLineSync();
  switch(input) {
    case '1':
      print('Patient Menu..');
      patientConsole.displayPatientUi();
      break;
    case '2':
      print('Rooms Menu..');
      roomConsole.displayRoomUi();
      break;
    case '3':
      print('Admission Menu..');
      admissionConsole.displayAdmissionUi();
      break;
    default:
      print('Invalid choice. Please select a valid option.');
  }
}