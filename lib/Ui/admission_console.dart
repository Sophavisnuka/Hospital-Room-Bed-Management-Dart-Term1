import 'dart:io';
import 'package:my_first_project/Domain/hospital.dart';

class AdmissionConsole {
  
  final Hospital hospital;
  AdmissionConsole(this.hospital);

  Future<void> displayAdmissionUi() async {
    while (true) {
      // Implementation for displaying the UI
      print("\nHospital Management System UI");
      print("------------------------------");
      print("1. View All Admissions");
      print('2. View Admission Details');
      print("3. Calculate Billing");
      print("4. View Billing Summary");
      print('5. Edit Admission Details');
      print('6. Delete Admission');
      print("7. Discharge Patient");
      print("8. Exit");
      stdout.write('Your choice: ');
      String? input = stdin.readLineSync();
      switch (input) {
        case '1': 
          break;
        case '2':
          break;
        case '3':
          break;
        case '4':
          break;
        case '5':
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