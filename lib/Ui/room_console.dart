import 'dart:io';
// import 'package:my_first_project/Domain/hospital.dart';
import 'package:my_first_project/Domain/bed.dart';
import 'package:my_first_project/Domain/room_service.dart';
import 'package:my_first_project/Domain/RoomType/standardRoom.dart';
import 'package:my_first_project/Domain/RoomType/vipRoom.dart';
import 'package:my_first_project/Domain/RoomType/icuRoom.dart';
import 'package:my_first_project/Domain/RoomType/isolationRoom.dart';
import 'package:my_first_project/Util/console_utils.dart';

class RoomConsole {
  // final Hospital hospital;
  final RoomService roomService;
  RoomConsole(this.roomService);

  Future<void> createRoom() async {
    print("\n=========================================");
    print("           Add New Room");
    print("=========================================");
    print("\nSelect room type:");
    print("=========================================");
    print("1. Standard Room (General Ward, 1-12 beds)");
    print("2. VIP Room (1 bed, premium)");
    print("3. ICU - Intensive Care Unit (1-4 beds)");
    print("4. Isolation Room (1 bed)");
    print("=========================================");
    stdout.write("Your choice: ");
    int? typeChoice = int.tryParse(stdin.readLineSync()!);

    print("\n-----------------------------------------");
    stdout.write("Enter room number: ");
    int? roomNumber = int.tryParse(stdin.readLineSync()!);

    if (roomNumber == null || roomNumber <= 0) {
      print("\nError: Invalid room number. Room not created.");
      return;
    }
    // Check if room number already exists
    if (roomService.rooms.any((r) => r.roomNumber == roomNumber)) {
      print("\nError: Room number $roomNumber already exists!");
      return;
    }

    print("-----------------------------------------");

    switch (typeChoice) {
      case 1: // Standard Room
        stdout.write("Enter number of beds (1-12): ");
        int? bedCount = int.parse(stdin.readLineSync()!);

        if (bedCount <= 0 || bedCount > 12) {
          print("\nError: Invalid number of beds. Room not created.");
          return;
        }
        List<Bed> beds = List.generate(
            bedCount,
            (i) => Bed(
                bedNumber: "$roomNumber-${i + 1}",
                id: null,
                status: BedStatus.available));

        final standardRoom = StandardRoom(roomNumber: roomNumber, beds: beds);
        await roomService.addRoom(standardRoom);
        print("\n=========================================");
        print("Standard Room $roomNumber added successfully!");
        print("=========================================");
        break;

      case 2: // VIP Room
        print("\n--- VIP Room Features ---");
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
        print("\n=========================================");
        print("VIP Room $roomNumber added successfully!");
        print("=========================================");
        break;

      case 3: // ICU Room
        stdout.write("Enter number of beds (1-4): ");
        int? bedCount = int.tryParse(stdin.readLineSync()!);

        if (bedCount == null || bedCount < 1 || bedCount > 4) {
          print(
              "\nError: Invalid number of beds. ICU rooms must have 1-4 beds.");
          return;
        }

        print("\n--- ICU Equipment & Staffing ---");
        stdout.write("Does this ICU have a ventilator? (y/n): ");
        bool hasVentilator = stdin.readLineSync()!.toLowerCase() == 'y';

        stdout.write("Does this ICU have cardiac monitors? (y/n): ");
        bool hasCardiacMonitor = stdin.readLineSync()!.toLowerCase() == 'y';

        stdout.write("Enter nurse-to-patient ratio (1-4, e.g., 2 for 1:2): ");
        int? nurseRatio = int.tryParse(stdin.readLineSync()!);
        if (nurseRatio == null || nurseRatio < 1 || nurseRatio > 4) {
          print("Warning: Invalid ratio. Using default 1:2.");
          nurseRatio = 2;
        }

        List<Bed> beds = List.generate(
            bedCount,
            (i) => Bed(
                bedNumber: "$roomNumber-${i + 1}",
                id: null,
                status: BedStatus.available));

        final icuRoom = ICURoom(
          roomNumber: roomNumber,
          beds: beds,
          hasVentilator: hasVentilator,
          hasCardiacMonitor: hasCardiacMonitor,
          nurseToPatientRatio: nurseRatio,
        );
        await roomService.addRoom(icuRoom);
        print("\n=========================================");
        print("ICU Room $roomNumber added successfully!");
        print("=========================================");
        break;

      case 4: // Isolation Room
        print("\n--- Isolation Room Features ---");
        stdout.write(
            "Does this room have negative pressure ventilation? (y/n): ");
        bool hasNegativePressure = stdin.readLineSync()!.toLowerCase() == 'y';

        stdout.write("Does this room have an antechamber? (y/n): ");
        bool hasAntechamber = stdin.readLineSync()!.toLowerCase() == 'y';

        print("\n--- Select Isolation Type ---");
        print("1. Airborne");
        print("2. Droplet");
        print("3. Contact");
        print("4. Protective");
        print("-----------------------------");
        stdout.write("Your choice: ");
        int? isoChoice = int.tryParse(stdin.readLineSync()!);

        String isolationType;
        switch (isoChoice) {
          case 1:
            isolationType = 'airborne';
            break;
          case 2:
            isolationType = 'droplet';
            break;
          case 3:
            isolationType = 'contact';
            break;
          case 4:
            isolationType = 'protective';
            break;
          default:
            print("Warning: Invalid choice. Using 'airborne' as default.");
            isolationType = 'airborne';
        }

        List<Bed> beds = [
          Bed(bedNumber: "$roomNumber-1", id: null, status: BedStatus.available)
        ];

        final isolationRoom = IsolationRoom(
          roomNumber: roomNumber,
          beds: beds,
          hasNegativePressure: hasNegativePressure,
          hasAntechamber: hasAntechamber,
          isolationType: isolationType,
        );
        await roomService.addRoom(isolationRoom);
        print("\n=========================================");
        print("Isolation Room $roomNumber added successfully!");
        print("=========================================");
        break;

      default:
        print("\nError: Invalid room type choice.");
        return;
    }
  }

  Future<void> updateBedStatus() async {
    print("\n=========================================");
    print("          Update Bed Status");
    print("=========================================");
    stdout.write('Enter room number to update: ');
    int? roomNumber = int.tryParse(stdin.readLineSync()!);

    if (roomNumber == null) {
      print('\nFinished updating bed statuses.');
      pressEnterToContinue();
      return;
    }

    try {
      final room =
          roomService.rooms.firstWhere((r) => r.roomNumber == roomNumber);
      print('\n=========================================');
      print('         Room $roomNumber - Bed List');
      print('=========================================');
      for (var bed in room.beds) {
        String status = bed.getStatus.toString().split('.').last;
        print(
            '  Bed: ${bed.bedNumber.padRight(15)} Status: ${status.toUpperCase()}');
      }
      print('=========================================');
    } catch (e) {
      print('\nError: Room $roomNumber not found.');
      return;
    }

    while (true) {
      print('\n-----------------------------------------');
      stdout.write('Enter bed number to update (or press Enter to finish): ');
      String bedNumber = stdin.readLineSync()!;

      // Exit condition: if user presses Enter without input
      if (bedNumber.isEmpty) {
        print('\nFinished updating bed statuses.');
        break;
      }

      print('\n--- Select New Bed Status ---');
      print('1. Available');
      print('2. Occupied');
      print('3. Cleaning');
      print('4. Maintenance');
      print('-----------------------------');
      stdout.write('Your choice: ');
      int? status = int.tryParse(stdin.readLineSync()!);

      switch (status) {
        case 1:
          await roomService.editRoomStatus(
              roomNumber, bedNumber, BedStatus.available);
          print('\nBed $bedNumber status updated to: AVAILABLE');
          break;
        case 2:
          await roomService.editRoomStatus(
              roomNumber, bedNumber, BedStatus.occupied);
          print('\nBed $bedNumber status updated to: OCCUPIED');
          break;
        case 3:
          await roomService.editRoomStatus(
              roomNumber, bedNumber, BedStatus.cleaning);
          print('\nBed $bedNumber status updated to: CLEANING');
          break;
        case 4:
          await roomService.editRoomStatus(
              roomNumber, bedNumber, BedStatus.maintenance);
          print('\nBed $bedNumber status updated to: MAINTENANCE');
          break;
        default:
          print('\nError: Invalid status entered.');
      }
    }
  }

  Future<void> viewAllRooms() async {
    if (roomService.rooms.isEmpty) {
      print("\n=========================================");
      print("  No rooms found in the system.");
      print("=========================================");
      return;
    }

    print("\n=========================================");
    print("         All Hospital Rooms");
    print("=========================================");

    for (var room in roomService.rooms) {
      print("\n╔═══════════════════════════════════════");
      print("║  ROOM #${room.roomNumber}");
      print("╠═══════════════════════════════════════");
      print("║  Type: ${room.roomType.name.toUpperCase()}");
      print("║  Base Price: \$${room.basePrice.toStringAsFixed(2)}");
      print(
          "║  Available Beds: ${room.getAvailableBedCount()}/${room.beds.length}");
      print(
          "║  Special Needs: ${room.canAccommodateSpecialNeeds() ? 'Yes' : 'No'}");
      print("║  Room Available: ${room.isAvailable ? 'Yes' : 'No'}");

      double serviceCharge = room.getServiceCharge();
      if (serviceCharge > 0) {
        print("║  Service Charge: \$${serviceCharge.toStringAsFixed(2)}/night");
      }

      print("╠═══════════════════════════════════════");
      print("║  Features:");
      for (var feature in room.getRoomFeatures()) {
        print("║    • $feature");
      }

      print("╠═══════════════════════════════════════");
      print("║  Beds:");
      for (var bed in room.beds) {
        String status = bed.getStatus.toString().split('.').last.toUpperCase();
        String bedInfo = "${bed.bedNumber} - $status";
        print("║    $bedInfo");
      }
      print("╚═══════════════════════════════════════");
    }
  }

  Future<void> updateRoomPrice() async {
    print("\n=========================================");
    print("          Update Room Price");
    print("=========================================");
    stdout.write('Enter room number: ');
    int? roomNumber = int.tryParse(stdin.readLineSync()!);

    if (roomNumber == null) {
      print('\nError: Invalid room number.');
      pressEnterToContinue();
      return;
    }

    stdout.write('Enter new price for room $roomNumber: \$');
    double? newPrice = double.tryParse(stdin.readLineSync()!);

    if (newPrice == null) {
      print('\nError: Invalid price entered.');
      pressEnterToContinue();
      return;
    }

    if (newPrice < 0) {
      print('\nError: Price cannot be negative.');
      pressEnterToContinue();
      return;
    }

    try {
      double oldPrice = await roomService.editRoomPrice(roomNumber, newPrice);
      print('\n=========================================');
      print('Room $roomNumber Price Updated!');
      print('=========================================');
      print('  Old Price: \$${oldPrice.toStringAsFixed(2)}');
      print('  New Price: \$${newPrice.toStringAsFixed(2)}');
      print('=========================================');
    } catch (e) {
      print('\nError: $e');
    }
  }

  Future<void> removeRoom() async {
    print("\n=========================================");
    print("            Remove Room");
    print("=========================================");
    stdout.write("Enter room number to remove: ");
    int? roomNumber = int.tryParse(stdin.readLineSync()!);

    if (roomNumber == null) {
      print("\nError: Invalid room number.");
      return;
    }

    print(
        "\nWarning: Are you sure you want to remove room $roomNumber? (y/n): ");
    stdout.write("Confirm: ");
    String? confirm = stdin.readLineSync()?.toLowerCase();

    if (confirm == 'y' || confirm == 'yes') {
      await roomService.deleteRoom(roomNumber);
      print("\n=========================================");
      print("Room $roomNumber removed successfully!");
      print("=========================================");
    } else {
      print("\nRoom removal cancelled.");
    }
  }

  Future<void> removeBedFromRoom() async {
    print("\n=========================================");
    print("         Remove Bed from Room");
    print("=========================================");
    stdout.write("Enter room number: ");
    int? roomNumber = int.tryParse(stdin.readLineSync()!);

    if (roomNumber == null) {
      print("\nError: Invalid room number.");
      return;
    }

    stdout.write("Enter bed number to remove: ");
    String bedNumber = stdin.readLineSync()!;

    print(
        "\nWarning: Are you sure you want to remove bed $bedNumber from room $roomNumber? (y/n): ");
    stdout.write("Confirm: ");
    String? confirm = stdin.readLineSync()?.toLowerCase();

    if (confirm == 'y' || confirm == 'yes') {
      await roomService.deleteBedFromRoom(roomNumber, bedNumber);
      print("\n=========================================");
      print("Bed $bedNumber removed successfully!");
      print("=========================================");
    } else {
      print("\nBed removal cancelled.");
    }
  }

  Future<void> displayRoomUi() async {
    while (true) {
      print("\n=========================================");
      print("  Hospital Management System - Rooms");
      print("=========================================");
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
          print('\nInvalid choice. Please select a valid option.');
          pressEnterToContinue();
      }
    }
  }
}
