import 'ui/patient_console.dart';
import 'ui/room_console.dart';
import 'dart:io';

void main () {
  PatientConsole console = PatientConsole();
  RoomConsole roomConsole = RoomConsole();
  print('Welcome to the Hospital Management System');
  print('-----------------------------------------');
  print('\n1. Manage Patients');
  print('\n2. Manage Rooms');
  print('\n3. Discharge Rooms');
  stdout.write('Your choice: ');
  String? input = stdin.readLineSync();
  if (input != null) {
    try {
      switch(input) {
        case '1':
          print('Displaying all patients...');
          console.displayPatientUi();
          break;
        case '2':
          print('Displaying all rooms...');
          roomConsole.displayRoomUi();
          break;
        default:
          print('Invalid choice. Please select a valid option.');
      }
    } catch (e) {
      throw new Exception("Invalid age input. Please enter a number.");
    }
  } else {
    print("No age entered.");
  }
}