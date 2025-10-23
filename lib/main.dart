import 'ui/hospital_console.dart';
import 'dart:io';

void main () {
  Console console = Console();
  print('Welcome to the Hospital Management System');
  print('-----------------------------------------');
  print('\n1. View All Rooms');
  print('\n2. View All Patients');
  stdout.write('Your choice: ');
  String? input = stdin.readLineSync();
    if (input != null) {
      try {
        switch(input) {
          case '1':
            print('Displaying all rooms...');
            console.displayUi();
            break;
          case '2':
            print('Displaying all patients...');
            // console.displayUi();
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