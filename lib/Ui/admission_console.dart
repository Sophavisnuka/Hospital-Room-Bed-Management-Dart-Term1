import 'dart:io';
import 'package:my_first_project/Domain/hospital.dart';
import 'package:my_first_project/Util/console_utils.dart';

class AdmissionConsole {
  final Hospital hospital;
  AdmissionConsole(this.hospital);

  Future<void> displayAdmissionUi() async {
    while (true) {
      // Implementation for displaying the UI
      print('=========================================');
      print("Hospital Management System - Admissions");
      print('=========================================');
      print("1. View All Admissions");
      print('2. View Admission Details');
      print("3. Calculate Billing");
      print("4. View Billing Summary");
      print('5. Edit Admission Details');
      print('6. Delete Admission');
      print("7. Discharge Patient");
      print('=========================================');
      print("0. Back to Main Menu");
      print('=========================================');
      stdout.write('Your choice: ');
      String? input = stdin.readLineSync();
      clearScreen();
      switch (input) {
        case '1':
          pressEnterToContinue();
          break;
        case '2':
          pressEnterToContinue();
          break;
        case '3':
          pressEnterToContinue();
          break;
        case '4':
          pressEnterToContinue();
          break;
        case '5':
          pressEnterToContinue();
          break;
        case '6':
          pressEnterToContinue();
          break;
        case '7':
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
