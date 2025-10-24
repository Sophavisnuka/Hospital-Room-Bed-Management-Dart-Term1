import 'dart:io';

class PatientConsole {
  void displayPatientUi() {
    // Implementation for displaying the UI
    print("\nHospital Management System UI");
    print("------------------------------");
    print("1. View All Patients");
    print("2. Register New Patient");
    print("3. Admit Patient");
    print("4. Transfer Patient");
    print("5. Search Patient");
    print("6. Exit");
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
      case  '6':
        break;
      default:
        print('Invalid choice. Please select a valid option.');
    }
  }
}