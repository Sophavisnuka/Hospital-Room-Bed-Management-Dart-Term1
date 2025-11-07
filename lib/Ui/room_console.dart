import 'dart:io';
// import 'package:my_first_project/Domain/hospital.dart';
import 'package:my_first_project/Domain/bed.dart';
import 'package:my_first_project/Domain/room_service.dart';
import 'package:my_first_project/Domain/standardRoom.dart';
import 'package:my_first_project/Domain/vipRoom.dart';
import 'package:my_first_project/Util/console_utils.dart';

class RoomConsole {
  // final Hospital hospital;
  final RoomService roomService;
  RoomConsole(this.roomService);

  Future<void> createRoom() async {
    print("\n================================================");
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
    if (roomService.rooms.any((r) => r.roomNumber == roomNumber)) {
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

        await roomService.addRoom(standardRoom);
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
      await roomService.addRoom(vipRoom);
      print("VIP Room $roomNumber added successfully!");
    } else {
      print("Invalid room type choice.");
      return;
    }
  }

  Future<void> updateBedStatus() async {
    print("\n================================================");
    // Implementation for updating a bed status
    stdout.write('Enter room number to update: ');
    int? roomNumber = int.tryParse(stdin.readLineSync()!);
    if (roomNumber == null) {
      print('Finished updating bed statuses.');
      pressEnterToContinue();
    }
    try {
      final room = roomService.rooms.firstWhere((r) => r.roomNumber == roomNumber);
      print('\n--- Room $roomNumber Beds ---');
      for (var bed in room.beds) {
        String status = bed.getStatus.toString().split('.').last;
        print('Bed Number: ${bed.bedNumber}, Status: $status');
      }
    } catch (e) {
      print('Room $roomNumber not found.');
      return;
    }
    while (true) {
      stdout.write('Enter bed number to update: ');
      String bedNumber = stdin.readLineSync()!;
      // Exit condition: if user presses Enter without input
      if (bedNumber.isEmpty) {
        print('Finished updating bed statuses.');
        break;
      }
      
      // print('Current status of bed $bedNumber: $currentBedStatus');
      print('Select new status:');
      print('1. Available');
      print('2. Occupied');
      print('3. Cleaning');
      print('4. Maintenance');
      stdout.write('Enter new status (available/occupied/cleaning/maintenance): ');
      int? status = int.tryParse(stdin.readLineSync()!);
      switch (status) {
        case 1:
          await roomService.editRoomStatus(roomNumber!, bedNumber, BedStatus.available);
          print('Bed status updated to Available.');
          break;
        case 2:
          await roomService.editRoomStatus(roomNumber!, bedNumber, BedStatus.occupied);
          print('Bed status updated to Occupied.');
          break;
        case 3:
          await roomService.editRoomStatus(roomNumber!, bedNumber, BedStatus.cleaning);
          print('Bed status updated to Cleaning.');
          break;
        case 4:
          await roomService.editRoomStatus(roomNumber!, bedNumber, BedStatus.maintenance);
          print('Bed status updated to Maintenance.');
          break;
        default:
          print('Invalid status entered.');
      }
    }
  }

  Future<void> viewAllRooms() async {
    // Implementation for viewing all rooms
    if (roomService.rooms.isEmpty) {
      print("No rooms found.");
      return;
    }
    for (var room in roomService.rooms) {
      print("\n===================================================");
      print("Room Number: ${room.roomNumber}");
      print("Room Type: ${room.roomType}");
      print("Base Price: ${room.basePrice}");
      print("Available Beds: ${room.getAvailableBedCount()}/${room.beds.length}");
      print("Special Needs Support: ${room.canAccommodateSpecialNeeds() ? 'Yes' : 'No'}");
      //Show room features
      print("Features: ${room.getRoomFeatures().join(', ')}");
      //Show service charges if any
      double serviceCharge = room.getServiceCharge();
      if (serviceCharge > 0) {
        print("Service Charge: \$${serviceCharge.toStringAsFixed(2)} per night");
      }
      print("Is Available: ${room.isAvailable}");
      print("Beds:");
      for (var bed in room.beds) {
        String status = bed.getStatus.toString().split('.').last;
        print("  - Bed Number: ${bed.bedNumber}, Status: $status");
      }
      print("------------------------------------------------------");
    }
  }
  Future<void> updateRoomPrice() async {
    stdout.write('Enter room number to edit price: ');
    int? roomNumber = int.tryParse(stdin.readLineSync()!);
    // print('Current room price: ${}')
    stdout.write('Enter new price for room $roomNumber: ');
    double? newPrice = double.tryParse(stdin.readLineSync()!);
    if (roomNumber == null || newPrice == null) {
      print('Invalid room number or price.');
      pressEnterToContinue();
      return;
    }
    if (newPrice < 0) {
      print('Price cannot be negative.');
      pressEnterToContinue();
      return;
    }
    try {
      double oldPrice = await roomService.editRoomPrice(roomNumber, newPrice);
      print('\nRoom $roomNumber price updated successfully');
      print('Old Price: $oldPrice');
      print('New Price: $newPrice');
    } catch (e) {
      print(e);
    }
  }
  Future<void> removeRoom() async {
    
    // Implementation for removing a room
    stdout.write("Enter room number to remove: ");
    int? roomNumber = int.tryParse(stdin.readLineSync()!);
    if (roomNumber == null) {
      print("Invalid room number.");
      return;
    }
    await roomService.deleteRoom(roomNumber);
  }
  Future<void> removeBedFromRoom() async {
    // Implementation for removing a bed from a room
    stdout.write("Enter room number to remove bed from: ");
    int? roomNumber = int.tryParse(stdin.readLineSync()!);
    if (roomNumber == null) {
      print("Invalid room number.");
      return;
    }
    stdout.write("Enter bed number to remove: ");
    String bedNumber = stdin.readLineSync()!;
    await roomService.deleteBedFromRoom(roomNumber, bedNumber);
  }
  Future<void> displayRoomUi() async {
    while (true) {
      // Implementation for displaying the UI
      clearScreen();
      print("\n=========================================");
      print("\nHospital Management System - Rooms");
      print("\n=========================================");
      print("1. View All Rooms");
      print("2. Add New Rooms");
      print("3. Edit Bed Status");
      print("4. Edit Room Price");
      print("5. Remove Room");
      print("6. Remove Bed from Room");
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
          await updateBedStatus();
          pressEnterToContinue();
          break;
        case '4':
          await updateRoomPrice();
          pressEnterToContinue();
          break;
        case '5':
          await removeRoom();  
          pressEnterToContinue();
          break;
        case '6':
          await removeBedFromRoom();
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
