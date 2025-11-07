import 'package:test/test.dart';
import 'package:my_first_project/Domain/patient.dart';
import 'package:my_first_project/Domain/patient_service.dart';
import 'package:my_first_project/Domain/room_service.dart';
import 'package:my_first_project/Domain/admission_service.dart';
import 'package:my_first_project/Domain/hospital.dart';
import 'package:my_first_project/Domain/RoomType/standardRoom.dart';
import 'package:my_first_project/Domain/RoomType/vipRoom.dart';
import 'package:my_first_project/Domain/bed.dart';

void main() {
  group('Admission Management Tests', () {
    late Hospital hospital;
    late PatientService patientService;
    late RoomService roomService;
    late AdmissionService admissionService;

    setUp(() {
      hospital = Hospital(name: "Test Hospital", address: "123 Test St");
      patientService = hospital.patientService;
      roomService = hospital.roomService;
      admissionService = hospital.admissionService;
    });

    group('Patient Admission Tests', () {
      test('Should admit patient successfully', () async {
        // Arrange
        final patient = Patient(
          name: "Alice Johnson",
          age: 35,
          gender: "Female",
          phone: "987654321",
          dateOfBirth: "1988-05-15",
          reason: "Surgery",
          nights: 3,
        );
        await patientService.registerPatient(patient);

        final beds = <Bed>[
          Bed(id: null, bedNumber: "101-1", status: BedStatus.available),
          Bed(id: null, bedNumber: "101-2", status: BedStatus.available),
        ];
        final room = StandardRoom(roomNumber: 101, basePrice: 100.0, beds: beds);
        await roomService.addRoom(room);

        // Act
        await admissionService.admitPatient(
          patientName: "Alice Johnson",
          roomNumber: 101,
          bedNumber: "101-1",
          admissionDate: DateTime(2024, 1, 15),
        );

        // Assert
        expect(admissionService.admissions.length, equals(1));
        final admission = admissionService.admissions.first;
        expect(admission.patient, equals("Alice Johnson"));
        expect(admission.roomNumber, equals(101));
        expect(admission.bedNumber, equals("101-1"));
        
        // Check bed status updated
        final updatedRoom = roomService.rooms.first;
        final bed = updatedRoom.beds.firstWhere((b) => b.bedNumber == "101-1");
        expect(bed.getStatus, equals(BedStatus.occupied));
      });

      test('Should not admit patient if already admitted', () async {
        // Arrange
        final patient = Patient(
          name: "Bob Wilson",
          age: 40,
          gender: "Male",
          phone: "555123456",
          dateOfBirth: "1983-10-20",
          reason: "Treatment",
          nights: 2,
        );
        await patientService.registerPatient(patient);

        final beds = <Bed>[
          Bed(id: null, bedNumber: "102-1", status: BedStatus.available),
          Bed(id: null, bedNumber: "102-2", status: BedStatus.available),
        ];
        final room = StandardRoom(roomNumber: 102, basePrice: 100.0, beds: beds);
        await roomService.addRoom(room);

        // First admission
        await admissionService.admitPatient(
          patientName: "Bob Wilson",
          roomNumber: 102,
          bedNumber: "102-1",
          admissionDate: DateTime(2024, 1, 15),
        );

        // Act & Assert
        expect(
          () async => await admissionService.admitPatient(
            patientName: "Bob Wilson",
            roomNumber: 102,
            bedNumber: "102-2",
            admissionDate: DateTime(2024, 1, 16),
          ),
          throwsA(isA<StateError>()),
        );
      });

      test('Should not admit patient if bed is occupied', () async {
        // Arrange
        final patient1 = Patient(
          name: "Patient One",
          age: 30,
          gender: "Male",
          phone: "111111111",
          dateOfBirth: "1993-01-01",
          reason: "Test",
          nights: 1,
        );
        final patient2 = Patient(
          name: "Patient Two",
          age: 25,
          gender: "Female",
          phone: "222222222",
          dateOfBirth: "1998-01-01",
          reason: "Test",
          nights: 1,
        );
        await patientService.registerPatient(patient1);
        await patientService.registerPatient(patient2);

        final beds = <Bed>[
          Bed(id: null, bedNumber: "103-1", status: BedStatus.available),
        ];
        final room = StandardRoom(roomNumber: 103, basePrice: 100.0, beds: beds);
        await roomService.addRoom(room);

        // First admission
        await admissionService.admitPatient(
          patientName: "Patient One",
          roomNumber: 103,
          bedNumber: "103-1",
          admissionDate: DateTime(2024, 1, 15),
        );

        // Act & Assert
        expect(
          () async => await admissionService.admitPatient(
            patientName: "Patient Two",
            roomNumber: 103,
            bedNumber: "103-1",
            admissionDate: DateTime(2024, 1, 16),
          ),
          throwsA(isA<StateError>()),
        );
      });

      test('Should not admit patient if patient not found', () async {
        // Arrange
        final beds = <Bed>[
          Bed(id: null, bedNumber: "104-1", status: BedStatus.available),
        ];
        final room = StandardRoom(roomNumber: 104, basePrice: 100.0, beds: beds);
        await roomService.addRoom(room);

        // Act & Assert
        expect(
          () async => await admissionService.admitPatient(
            patientName: "Non Existent Patient",
            roomNumber: 104,
            bedNumber: "104-1",
            admissionDate: DateTime(2024, 1, 15),
          ),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('Patient Transfer Tests', () {
      test('Should transfer patient successfully', () async {
        // Arrange
        final patient = Patient(
          name: "Charlie Brown",
          age: 28,
          gender: "Male",
          phone: "333444555",
          dateOfBirth: "1995-07-10",
          reason: "Recovery",
          nights: 4,
        );
        await patientService.registerPatient(patient);

        // Create two rooms
        final beds1 = <Bed>[
          Bed(id: null, bedNumber: "201-1", status: BedStatus.available),
        ];
        final beds2 = <Bed>[
          Bed(id: null, bedNumber: "202-1", status: BedStatus.available),
        ];
        final room1 = StandardRoom(roomNumber: 201, basePrice: 100.0, beds: beds1);
        final room2 = VIPRoom(
          roomNumber: 202,
          basePrice: 200.0,
          beds: beds2,
          hasLounge: true,
          hasPrivateBathroom: true,
        );
        await roomService.addRoom(room1);
        await roomService.addRoom(room2);

        // Initial admission
        await admissionService.admitPatient(
          patientName: "Charlie Brown",
          roomNumber: 201,
          bedNumber: "201-1",
          admissionDate: DateTime(2024, 1, 15),
        );

        // Act
        await admissionService.transferPatient(
          patientName: "Charlie Brown",
          currentRoomNum: 201,
          currentBedNum: "201-1",
          newRoomNum: 202,
          newBedNum: "202-1",
          transferReason: "Upgrade to VIP",
        );

        // Assert
        expect(admissionService.admissions.length, equals(1));
        expect(admissionService.discharges.length, equals(1));
        
        final currentAdmission = admissionService.admissions.first;
        expect(currentAdmission.roomNumber, equals(202));
        expect(currentAdmission.bedNumber, equals("202-1"));
        expect(currentAdmission.transferReason, equals("Upgrade to VIP"));

        // Check bed statuses
        final oldRoom = roomService.findRoomByNumber(201)!;
        final newRoom = roomService.findRoomByNumber(202)!;
        expect(oldRoom.beds.first.getStatus, equals(BedStatus.available));
        expect(newRoom.beds.first.getStatus, equals(BedStatus.occupied));
      });

      test('Should not transfer patient if not currently admitted', () async {
        // Arrange
        final patient = Patient(
          name: "Diana Prince",
          age: 29,
          gender: "Female",
          phone: "777888999",
          dateOfBirth: "1994-03-15",
          reason: "Test",
          nights: 1,
        );
        await patientService.registerPatient(patient);

        final beds1 = <Bed>[Bed(id: null, bedNumber: "203-1", status: BedStatus.available)];
        final beds2 = <Bed>[Bed(id: null, bedNumber: "204-1", status: BedStatus.available)];
        final room1 = StandardRoom(roomNumber: 203, basePrice: 100.0, beds: beds1);
        final room2 = StandardRoom(roomNumber: 204, basePrice: 100.0, beds: beds2);
        await roomService.addRoom(room1);
        await roomService.addRoom(room2);

        // Act & Assert
        expect(
          () async => await admissionService.transferPatient(
            patientName: "Diana Prince",
            currentRoomNum: 203,
            currentBedNum: "203-1",
            newRoomNum: 204,
            newBedNum: "204-1",
            transferReason: "Test transfer",
          ),
          throwsA(isA<StateError>()),
        );
      });

      test('Should not transfer if new bed is occupied', () async {
        // Arrange
        final patient1 = Patient(
          name: "Transfer Patient One",
          age: 30,
          gender: "Male",
          phone: "111222333",
          dateOfBirth: "1993-01-01",
          reason: "Test",
          nights: 2,
        );
        final patient2 = Patient(
          name: "Transfer Patient Two",
          age: 25,
          gender: "Female",
          phone: "444555666",
          dateOfBirth: "1998-01-01",
          reason: "Test",
          nights: 2,
        );
        await patientService.registerPatient(patient1);
        await patientService.registerPatient(patient2);

        final beds1 = <Bed>[Bed(id: null, bedNumber: "205-1", status: BedStatus.available)];
        final beds2 = <Bed>[Bed(id: null, bedNumber: "206-1", status: BedStatus.available)];
        final room1 = StandardRoom(roomNumber: 205, basePrice: 100.0, beds: beds1);
        final room2 = StandardRoom(roomNumber: 206, basePrice: 100.0, beds: beds2);
        await roomService.addRoom(room1);
        await roomService.addRoom(room2);

        // Admit both patients
        await admissionService.admitPatient(
          patientName: "Transfer Patient One",
          roomNumber: 205,
          bedNumber: "205-1",
          admissionDate: DateTime(2024, 1, 15),
        );
        await admissionService.admitPatient(
          patientName: "Transfer Patient Two",
          roomNumber: 206,
          bedNumber: "206-1",
          admissionDate: DateTime(2024, 1, 15),
        );

        // Act & Assert - Try to transfer Patient One to occupied bed
        expect(
          () async => await admissionService.transferPatient(
            patientName: "Transfer Patient One",
            currentRoomNum: 205,
            currentBedNum: "205-1",
            newRoomNum: 206,
            newBedNum: "206-1", // Occupied by Patient Two
            transferReason: "Test transfer",
          ),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('Patient Discharge Tests', () {
      test('Should discharge patient successfully', () async {
        // Arrange
        final patient = Patient(
          name: "Eve Adams",
          age: 32,
          gender: "Female",
          phone: "666777888",
          dateOfBirth: "1991-12-01",
          reason: "Observation",
          nights: 2,
        );
        await patientService.registerPatient(patient);

        final beds = <Bed>[
          Bed(id: null, bedNumber: "301-1", status: BedStatus.available),
        ];
        final room = StandardRoom(roomNumber: 301, basePrice: 100.0, beds: beds);
        await roomService.addRoom(room);

        // Admit patient
        await admissionService.admitPatient(
          patientName: "Eve Adams",
          roomNumber: 301,
          bedNumber: "301-1",
          admissionDate: DateTime(2024, 1, 15),
        );

        // Act
        await admissionService.dischargePatient(
          patientName: "Eve Adams",
          roomNumber: 301,
          bedNumber: "301-1",
          dischargeReason: "Recovered",
        );

        // Assert
        expect(admissionService.admissions.length, equals(0));
        expect(admissionService.discharges.length, equals(1));
        
        final discharge = admissionService.discharges.first;
        expect(discharge.dischargeReason, equals("Recovered"));
        expect(discharge.admission.patient, equals("Eve Adams"));

        // Check bed status updated to available
        final updatedRoom = roomService.rooms.first;
        final bed = updatedRoom.beds.first;
        expect(bed.getStatus, equals(BedStatus.available));
        expect(updatedRoom.isAvailable, isTrue);
      });

      test('Should not discharge patient if not admitted', () async {
        // Arrange
        final patient = Patient(
          name: "Frank Miller",
          age: 45,
          gender: "Male",
          phone: "888999000",
          dateOfBirth: "1978-08-20",
          reason: "Test",
          nights: 1,
        );
        await patientService.registerPatient(patient);

        // Act & Assert
        expect(
          () async => await admissionService.dischargePatient(
            patientName: "Frank Miller",
            roomNumber: 302,
            bedNumber: "302-1",
            dischargeReason: "Test discharge",
          ),
          throwsA(isA<StateError>()),
        );
      });

      test('Should not discharge if patient not found', () async {
        // Act & Assert
        expect(
          () async => await admissionService.dischargePatient(
            patientName: "Non Existent Patient",
            roomNumber: 303,
            bedNumber: "303-1",
            dischargeReason: "Test discharge",
          ),
          throwsA(isA<StateError>()),
        );
      });
    });
  });
}