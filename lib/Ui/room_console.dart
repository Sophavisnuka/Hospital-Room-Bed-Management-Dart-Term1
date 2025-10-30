import 'dart:io';
import 'package:my_first_project/Domain/hospital.dart';
import 'package:my_first_project/Domain/bed.dart';
import 'package:my_first_project/Domain/standardRoom.dart';
import 'package:my_first_project/Domain/vipRoom.dart';
import 'package:my_first_project/Util/console_utils.dart';

class RoomConsole {
  final Hospital hospital;
  RoomConsole(this.hospital);

  Future<void> createRoom() async {
    // Create a standard room with 4 beds
    print("\n--- Add New Room ---");

    // Choose room type
    print("Select room type:");
    print("1. Standard Room");
    print("2. VIP Room");
    stdout.write("Your choice: ");
    int? typeChoice = int.tryParse(stdin.readLineSync()!);

    // Get room number
    stdout.write("Enter room number: ");
    int? roomNumber = int.tryParse(stdin.readLineSync()!);

    if (roomNumber == null || roomNumber <= 0) {
      print("Invalid room number. Room not created.");
      return;
    }
    // Check if room number already exists
    if (hospital.room.any((r) => r.roomNumber == roomNumber)) {
      print("Error: Room number $roomNumber already exists!");
      return;
    }

    if (typeChoice == 1) {
      // Standard Room
      stdout.write("Enter number of beds (1-12): ");
      int? bedCount = int.parse(stdin.readLineSync()!);

      if (bedCount <= 0 || bedCount > 12) {
        print("Invalid number of beds. Room not created.");
        return;
      } else {
        List<Bed> beds = List.generate(
            bedCount,
            (i) => Bed(
                bedNumber: "$roomNumber-${i + 1}",
                id: null,
                status: BedStatus.available));

        final standardRoom = StandardRoom(roomNumber: roomNumber, beds: beds);

        await hospital.addRoom(standardRoom);
        print("Standard Room $roomNumber added successfully!");
      }
    } else if (typeChoice == 2) {
      // VIP Room (typically 1 bed)
      stdout.write("Does this VIP room have a lounge? (y/n): ");
      bool hasLounge = stdin.readLineSync()!.toLowerCase() == 'y';

      stdout.write("Does this VIP room have a private bathroom? (y/n): ");
      bool hasPrivateBathroom = stdin.readLineSync()!.toLowerCase() == 'y';

      List<Bed> beds = [
        Bed(bedNumber: "$roomNumber-1", id: null, status: BedStatus.available)
      ];

      final vipRoom = VIPRoom(
        roomNumber: roomNumber,
        beds: beds,
        hasLounge: hasLounge,
        hasPrivateBathroom: hasPrivateBathroom,
      );
      await hospital.addRoom(vipRoom);
      print("VIP Room $roomNumber added successfully!");
    } else {
      print("Invalid room type choice.");
      return;
    }
  }

  Future<void> viewAllRooms() async {
    // Implementation for viewing all rooms
    if (hospital.room.isEmpty) {
      print("No rooms found.");
      return;
    }
    for (var room in hospital.room) {
      print("Room Number: ${room.roomNumber}");
      print("Room Type: ${room.roomType}");
      print("Base Price: ${room.basePrice}");
      print("Is Available: ${room.isAvailable}");
      print("Beds:");
      for (var bed in room.beds) {
        print("  - Bed Number: ${bed.bedNumber}, Status: ${bed.status}");
      }
      print("------------------------------");
    }
  }

  Future<void> displayRoomUi() async {
    while (true) {
      // Implementation for displaying the UI
      print("\n=========================================");
      print("\nHospital Management System - Rooms");
      print("\n=========================================");
      print("1. View All Rooms");
      print("2. Add New Rooms");
      print("3. Edit Room");
      print('4. Delete Room');
      print("5. Change Room Status");
      print("=========================================");
      print("0. Back to Main Menu");
      print("=========================================");
      stdout.write('Your choice: ');
      String? input = stdin.readLineSync();
      clearScreen();
      switch (input) {
        case '1':
          await viewAllRooms();
          pressEnterToContinue();
          break;
        case '2':
          await createRoom();
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
