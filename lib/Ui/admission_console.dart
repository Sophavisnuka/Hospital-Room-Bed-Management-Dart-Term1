import 'dart:io';
import 'package:my_first_project/Domain/hospital.dart';
import 'package:my_first_project/Util/console_utils.dart';

class AdmissionConsole {
  final Hospital hospital;
  AdmissionConsole(this.hospital);

  Future<void> viewAllAdmissions() async {
    if (hospital.admissions.isEmpty) {
      print('No admissions found.');
    } else {
      print('List of Admissions:');
      for (var admission in hospital.admissions) {
        print('ID: ${admission.id}, Patient: ${admission.patient}, Room: ${admission.roomNumber}, Bed: ${admission.bedNumber}, Admission Date: ${admission.admissionDate}');
      }
    }
    pressEnterToContinue();
  }
  Future<void> dischargePatient() async {
    // print('=========================================');
    // stdout.write('Enter patient name to discharge: ');
    // String patientName = stdin.readLineSync()!;

    // final admission = hospital.admissions.firstWhere(
    //   (a) => a.patient == patientName && a.dischargeDate == null,
    //   orElse: () => throw Exception('No active admission found for patient $patientName.'),
    // );

    // stdout.write('Enter discharge reason: ');
    // String dischargeReason = stdin.readLineSync()!;

    // await hospital.dischargePatient(patientName, dischargeReason);
    // print('\nPatient $patientName discharged successfully!');
    // pressEnterToContinue();
  }
  Future<void> displayAdmissionUi() async {
    while (true) {
      // Implementation for displaying the UI
      print('=========================================');
      print("Hospital Management System - Admissions");
      print('=========================================');
      print("1. View All Admissions");
      print('2. Edit Admission');
      print('3. Delete Admission');
      print("4. Discharge Patient");
      print("5. View Billing Summary");
      print('=========================================');
      print("0. Back to Main Menu");
      print('=========================================');
      stdout.write('Your choice: ');
      String? input = stdin.readLineSync();
      clearScreen();
      switch (input) {
        case '1':
          await viewAllAdmissions();
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
        case '0':
          return;
        default:
          print('Invalid choice. Please select a valid option.');
          pressEnterToContinue();
      }
    }
  }
}
