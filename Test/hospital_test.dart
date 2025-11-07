import 'package:test/test.dart';
import 'package:my_first_project/Domain/patient.dart';
import 'package:my_first_project/Domain/patient_service.dart';
import 'package:my_first_project/Domain/room_service.dart';
import 'package:my_first_project/Domain/hospital.dart';
import 'package:my_first_project/Domain/RoomType/standardRoom.dart';
import 'package:my_first_project/Domain/RoomType/vipRoom.dart';
import 'package:my_first_project/Domain/bed.dart';

void main() {
  group('Hospital Management System Tests', () {
    late Hospital hospital;
    late PatientService patientService;
    late RoomService roomService;

    setUp(() {
      hospital = Hospital(name: "Test Hospital", address: "123 Test St");
      patientService = hospital.patientService;
      roomService = hospital.roomService;
    });

    group('Patient Management Tests', () {
      test('Should register a new patient successfully', () async {
        // Arrange
        final patient = Patient(
          name: "John Doe",
          age: 19,
          gender: "Male",
          phone: "123456789",
          dateOfBirth: "1993-01-01", // String format
          reason: "Chest",
          nights: 3,
        );

        // Act
        await patientService.registerPatient(patient);

        // Assert
        expect(patientService.patients.length, equals(1));
        expect(patientService.patients.first.name, equals("John Doe"));
      }); 
      test('Should delete patient successfully', () async {
        // Arrange
        final patient = Patient(
          name: "Test Patient",
          age: 30,
          gender: "Male",
          phone: "123456789",
          dateOfBirth: "1993-01-01", //  String format
          reason: "Test",
          nights: 1,
        );
        await patientService.registerPatient(patient);

        // Act
        await patientService.deletePatient(patient.name); //  Use name instead of ID

        // Assert
        expect(patientService.patients.length, equals(0));
      });
    });

    group('Room Management Tests', () {
      test('Should add a standard room successfully', () async {
        // Arrange
        final beds = <Bed>[ //  Explicit type
          Bed(id: null, bedNumber: "101-1", status: BedStatus.available), //  Added id parameter
          Bed(id: null, bedNumber: "101-2", status: BedStatus.available), //  Added id parameter
          Bed(id: null, bedNumber: "101-3", status: BedStatus.available), //  Added id parameter
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
        expect(roomService.rooms.first.roomNumber, equals(101));
        expect(roomService.rooms.first.beds.length, equals(2));
      });

      test('Should add a VIP room successfully', () async {
        // Arrange
        final beds = <Bed>[ //  Explicit type
          Bed(id: null, bedNumber: "201-1", status: BedStatus.available), //  Added id parameter
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

      test('Should not add room with duplicate room number', () async {
        // Arrange
        final beds1 = <Bed>[Bed(id: null, bedNumber: "101-1", status: BedStatus.available)]; //  Fixed
        final beds2 = <Bed>[Bed(id: null, bedNumber: "101-2", status: BedStatus.available)]; //  Fixed
        
        final room1 = StandardRoom(roomNumber: 101, basePrice: 100.0, beds: beds1);
        final room2 = StandardRoom(roomNumber: 101, basePrice: 150.0, beds: beds2);

        // Act & Assert
        await roomService.addRoom(room1);
        expect(
          () async => await roomService.addRoom(room2),
          throwsA(isA<StateError>()),
        );
      });

      test('Should update room price successfully', () async {
        // Arrange
        final beds = <Bed>[Bed(id: null, bedNumber: "101-1", status: BedStatus.available)]; //  Fixed
        final room = StandardRoom(roomNumber: 101, basePrice: 100.0, beds: beds);
        await roomService.addRoom(room);

        // Act
        final oldPrice = await roomService.editRoomPrice(101, 150.0);

        // Assert
        expect(oldPrice, equals(100.0)); //  Returns old price
        expect(roomService.rooms.first.basePrice, equals(150.0)); //  Check actual price was updated
      });

      test('Should update bed status successfully', () async {
        // Arrange
        final beds = <Bed>[ //  Explicit type
          Bed(id: null, bedNumber: "101-1", status: BedStatus.available), //  Added id parameter
          Bed(id: null, bedNumber: "101-2", status: BedStatus.available), //  Added id parameter
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