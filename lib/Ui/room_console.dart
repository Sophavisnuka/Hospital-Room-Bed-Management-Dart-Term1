import 'dart:io';

class RoomConsole {
  void displayRoomUi() {
    // Implementation for displaying the UI
    print("\nHospital Management System UI");
    print("------------------------------");
    print("1. View All Rooms");
    print("2. View Available Rooms");
    print("3. View All Beds");
    print("4. Remove Bed");
    print("5. Change Room Status");
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