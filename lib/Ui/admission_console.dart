import 'dart:io';
import 'package:my_first_project/Domain/admission_service.dart';
import 'package:my_first_project/Util/console_utils.dart';
// import 'package:my_first_project/Domain/hospital.dart';

class AdmissionConsole {
  // final Hospital hospital;
  final AdmissionService admissionService;
  AdmissionConsole(this.admissionService);

  Future<void> viewAllAdmissions() async {
    print("\n================================================");
    if (admissionService.admissions.isEmpty) {
      print('No admissions found.');
    } else {
      print('List of Admissions:');
      for (var admission in admissionService.admissions) {
        print('----------------------------------------------');
        print('ID: ${admission.id}, \nPatient: ${admission.patient}, \nRoom: ${admission.roomNumber}, \nBed: ${admission.bedNumber}, \nAdmission Date: ${admission.admissionDate}, \nDischarge Date: ${admission.dischargeDate}, \nTotal Cost: \$${admission.totalPrice}');
        print('==============================================\n');
      }
    }
    pressEnterToContinue();
  }
  Future<void> deleteAdmission() async {
    print("\n================================================");
    stdout.write('Enter patient name to delete admission: ');
    String? input = stdin.readLineSync();
    if (input == null || input.isEmpty) {
      print('Invalid input. Patient name cannot be empty.');
      pressEnterToContinue();
      return;
    }
    await admissionService.deleteAdmissionByPatientName(input);
  }
  Future<void> searchAdmissionsByPatientName() async {
    print("\n================================================");
    stdout.write('Enter patient name to search admissions: ');
    String? input = stdin.readLineSync();
    if (input == null || input.isEmpty) {
      print('Invalid input. Patient name cannot be empty.');
      pressEnterToContinue();
      return;
    }
    
    // Get search results and display them
    final searchResults = admissionService.searchAdmission(input);
    
    if (searchResults.isEmpty) {
      print('\nNo admissions found for patient "$input".');
      pressEnterToContinue();
      return;
    }
    
    print('\nFound ${searchResults.length} admission(s) for "$input":');
    print('=========================================================================');
    
    for (int i = 0; i < searchResults.length; i++) {
      final admission = searchResults[i];
      print('\n--- Admission ${i + 1} ---');
      print('Admission ID: ${admission.id}');
      print('Patient: ${admission.patient}');
      print('Room: ${admission.roomNumber}');
      print('Bed: ${admission.bedNumber}');
      print('Admission Date: ${admission.admissionDate.toLocal()}');
      print('Total Price: \$${admission.totalPrice.toStringAsFixed(2)}');
      
      if (admission.dischargeDate != null) {
        print('Discharge Date: ${admission.dischargeDate!.toLocal()}');
        print('Status: DISCHARGED');
      } else {
        print('Status: ACTIVE');
      }
      
      if (admission.transferReason != null) {
        print('Transfer Reason: ${admission.transferReason}');
        if (admission.previousRoomNumber != null) {
          print('Previous Location: Room ${admission.previousRoomNumber}, Bed ${admission.previousBedNumber}');
        }
      }
      
      if (admission.dischargeReason != null) {
        print('Discharge Reason: ${admission.dischargeReason}');
      }
      
      print('-------------------------');
    }
    
    print('\nSearch completed. Found ${searchResults.length} admission(s).');
    print('=========================================================================');
  }
  Future<void> viewDischargeSummary() async {
    for (var discharge in admissionService.discharges) {
      print('------------------------------------------------------');
      print('\nDischarge ID: ${discharge.id},\nAdmission ID: ${discharge.admissionId}, \nPatient: ${discharge.patient}, \nDischarge Date: ${discharge.dischargeDate}, \nDischarge Reason: ${discharge.dischargeReason}, \nTotal Cost: \$${discharge.totalPrice}, \nStay Duration: ${discharge.nightsStayed} nights');
      print('======================================================\n');
    }
    pressEnterToContinue();
  }
  Future<void> displayAdmissionUi() async {
    while (true) {
      // Implementation for displaying the UI
      clearScreen();
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
