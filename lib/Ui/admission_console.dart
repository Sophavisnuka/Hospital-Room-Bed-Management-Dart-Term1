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
  Future<void> deleteAdmission() async {
    stdout.write('Enter patient name to delete admission: ');
    String? input = stdin.readLineSync();
    if (input == null || input.isEmpty) {
      print('Invalid input. Patient name cannot be empty.');
      pressEnterToContinue();
      return;
    }
    await hospital.deleteAdmissionByPatientName(input);
  }
  Future<void> searchAdmissionsByPatientName() async {
    stdout.write('Enter patient name to search admissions: ');
    String? input = stdin.readLineSync();
    if (input == null || input.isEmpty) {
      print('Invalid input. Patient name cannot be empty.');
      pressEnterToContinue();
      return;
    }
    await hospital.searchAdmission(input);
  }
  Future<void> viewDischargeSummary() async {
    for (var discharge in hospital.discharges) {
      print('\nDischarge ID: ${discharge.id}, \nPatient: ${discharge.patient}, \nDischarge Date: ${discharge.dischargeDate}');
    }
    pressEnterToContinue();
  }
  Future<void> displayAdmissionUi() async {
    while (true) {
      // Implementation for displaying the UI
      print('=========================================');
      print("Hospital Management System - Admissions");
      print('=========================================');
      print("1. View All Admissions");
      print('2. Delete Admission');
      print("3. Search Admissions by Patient Name");
      print("4. View All Discharge Summaries");
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
          await deleteAdmission();
          pressEnterToContinue();
          break;
        case '3':
          await searchAdmissionsByPatientName();
          pressEnterToContinue();
          break;
        case '4':
          await viewDischargeSummary();
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
