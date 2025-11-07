import 'package:test/test.dart';
import 'package:my_first_project/Domain/room_service.dart';
import 'package:my_first_project/Domain/hospital.dart';
import 'package:my_first_project/Domain/RoomType/standardRoom.dart';
import 'package:my_first_project/Domain/RoomType/vipRoom.dart';
import 'package:my_first_project/Domain/RoomType/icuRoom.dart';
import 'package:my_first_project/Domain/RoomType/isolationRoom.dart';
import 'package:my_first_project/Domain/bed.dart';

void main() {
  group('Room Management Tests', () {
    late Hospital hospital;
    late RoomService roomService;

    setUp(() {
      hospital = Hospital(name: "Test Hospital", address: "123 Test St");
      roomService = hospital.roomService;
    });

    group('Add Room Tests', () {
      test('Should add a standard room successfully', () async {
        // Arrange
        final beds = <Bed>[
          Bed(id: null, bedNumber: "102-1", status: BedStatus.available),
          Bed(id: null, bedNumber: "102-2", status: BedStatus.available),
        ];
        final room = StandardRoom(
          roomNumber: 102,
          basePrice: 100.0,
          beds: beds,
        );

        // Act
        await roomService.addRoom(room);

        // Assert
        expect(roomService.rooms.length, equals(1));
        expect(roomService.rooms.first.roomNumber, equals(102));
        expect(roomService.rooms.first.beds.length, equals(2));
      });
    });
    test('Should add a VIP room successfully', () async {
      // Arrange
      final beds = <Bed>[
        Bed(id: null, bedNumber: "201-1", status: BedStatus.available),
      ];
      final room = VIPRoom(
        roomNumber: 201,
        basePrice: 200.0,
        beds: beds,
        hasLounge: true,
        hasPrivateBathroom: true,
      );

      // Act
      await roomService.addRoom(room);

      // Assert
      expect(roomService.rooms.length, equals(1));
      final addedRoom = roomService.rooms.first as VIPRoom;
      expect(addedRoom.roomNumber, equals(201));
      expect(addedRoom.hasLounge, isTrue);
      expect(addedRoom.hasPrivateBathroom, isTrue);
    });

    group('ICU Room Tests', () {
      test('Should add an ICU room successfully', () async {
        // Arrange
        final beds = <Bed>[
          Bed(id: null, bedNumber: "301-1", status: BedStatus.available),
          Bed(id: null, bedNumber: "301-2", status: BedStatus.available),
        ];
        final icuRoom = ICURoom(
          roomNumber: 301,
          basePrice: 500.0,
          beds: beds,
          hasVentilator: true,
          hasCardiacMonitor: true,
          nurseToPatientRatio: 2,
        );

        // Act
        await roomService.addRoom(icuRoom);

        // Assert
        expect(roomService.rooms.length, equals(1));
        final addedRoom = roomService.rooms.first as ICURoom;
        expect(addedRoom.roomNumber, equals(301));
        expect(addedRoom.hasVentilator, isTrue);
        expect(addedRoom.hasCardiacMonitor, isTrue);
        expect(addedRoom.nurseToPatientRatio, equals(2));
        expect(addedRoom.beds.length, equals(2));
      });

      test('Should validate ICU room bed count', () {
        // Arrange
        final beds = <Bed>[
          Bed(id: null, bedNumber: "301-1", status: BedStatus.available),
          Bed(id: null, bedNumber: "301-2", status: BedStatus.available),
          Bed(id: null, bedNumber: "301-3", status: BedStatus.available),
          Bed(id: null, bedNumber: "301-4", status: BedStatus.available),
          Bed(id: null, bedNumber: "301-5", status: BedStatus.available), // Too many beds
        ];

        // Act & Assert
        expect(
          () => ICURoom(
            roomNumber: 301,
            basePrice: 500.0,
            beds: beds,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('Should validate ICU room nurse to patient ratio', () {
        // Arrange
        final beds = <Bed>[
          Bed(id: null, bedNumber: "301-1", status: BedStatus.available),
        ];

        // Act & Assert
        expect(
          () => ICURoom(
            roomNumber: 301,
            basePrice: 500.0,
            beds: beds,
            nurseToPatientRatio: 5, // Invalid ratio
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Isolation Room Tests', () {
      test('Should add an Isolation room successfully', () async {
        // Arrange
        final beds = <Bed>[
          Bed(id: null, bedNumber: "401-1", status: BedStatus.available),
        ];
        final isolationRoom = IsolationRoom(
          roomNumber: 401,
          basePrice: 400.0,
          beds: beds,
          hasNegativePressure: true,
          hasAntechamber: true,
          isolationType: 'airborne',
        );

        // Act
        await roomService.addRoom(isolationRoom);

        // Assert
        expect(roomService.rooms.length, equals(1));
        final addedRoom = roomService.rooms.first as IsolationRoom;
        expect(addedRoom.roomNumber, equals(401));
        expect(addedRoom.hasNegativePressure, isTrue);
        expect(addedRoom.hasAntechamber, isTrue);
        expect(addedRoom.isolationType, equals('airborne'));
        expect(addedRoom.beds.length, equals(1));
      });
    });

    group('General Room Management Tests', () {
      test('Should not add room with duplicate room number', () async {
        // Arrange
        final beds1 = <Bed>[Bed(id: null, bedNumber: "500-1", status: BedStatus.available)];
        final beds2 = <Bed>[Bed(id: null, bedNumber: "500-2", status: BedStatus.available)];
        
        final room1 = StandardRoom(roomNumber: 500, basePrice: 100.0, beds: beds1);
        final room2 = VIPRoom(roomNumber: 500, basePrice: 200.0, beds: beds2, hasLounge: true, hasPrivateBathroom: true); // Same room number

        // Act
        await roomService.addRoom(room1);

        // Assert
        expect(
          () async => await roomService.addRoom(room2),
          throwsA(isA<StateError>()),
        );
        
        // Verify only the first room was added
        expect(roomService.rooms.length, equals(1));
        expect(roomService.rooms.first.roomNumber, equals(500));
        expect(roomService.rooms.first, isA<StandardRoom>());
      });

      test('Should update room price successfully', () async {
        // Arrange
        final beds = <Bed>[Bed(id: null, bedNumber: "201-1", status: BedStatus.available)];
        final room = StandardRoom(roomNumber: 201, basePrice: 200.0, beds: beds);
        await roomService.addRoom(room);

        // Act
        final oldPrice = await roomService.editRoomPrice(201, 500.0);

        // Assert
        expect(oldPrice, equals(200.0));
        expect(roomService.rooms.first.basePrice, equals(500.0));
      });

      test('Should update bed status successfully', () async {
        // Arrange
        final beds = <Bed>[
          Bed(id: null, bedNumber: "101-1", status: BedStatus.cleaning),
          Bed(id: null, bedNumber: "101-2", status: BedStatus.available),
        ];
        final room = StandardRoom(roomNumber: 101, basePrice: 100.0, beds: beds);
        await roomService.addRoom(room);

        // Act
        await roomService.editRoomStatus(101, "101-1", BedStatus.occupied);

        // Assert
        final updatedRoom = roomService.rooms.first;
        final updatedBed = updatedRoom.beds.firstWhere((b) => b.bedNumber == "101-1");
        expect(updatedBed.getStatus, equals(BedStatus.occupied));
      });
    });
  });
}