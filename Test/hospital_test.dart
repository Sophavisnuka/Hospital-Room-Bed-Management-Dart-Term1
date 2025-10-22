import 'package:test/test.dart';
import '../lib/Domain/hospital.dart';
import '../lib/Domain/room.dart';
import '../lib/Domain/patient.dart';
import '../lib/Domain/bed.dart';
import '../lib/Domain/booking.dart';
import '../lib/Domain/bookingHistory.dart';

void main() {
  group('Hospital Class Tests', () {
    late Hospital hospital;

    setUp(() {
      hospital = Hospital();
    });

    test('Hospital should be created with empty lists', () {
      expect(hospital.rooms, isEmpty);
      expect(hospital.patients, isEmpty);
      expect(hospital.bookings, isEmpty);
    });

    test('addRoom should add a room with specified bed count', () {
      hospital.addRoom(101, RoomType.normal, 3);
      
      expect(hospital.rooms.length, 1);
      expect(hospital.rooms[0].roomNumber, 101);
      expect(hospital.rooms[0].type, RoomType.normal);
      expect(hospital.rooms[0].beds.length, 3);
    });

    test('addRoom should create multiple rooms', () {
      hospital.addRoom(101, RoomType.normal, 2);
      hospital.addRoom(201, RoomType.vip_private, 1);
      
      expect(hospital.rooms.length, 2);
      expect(hospital.rooms[0].roomNumber, 101);
      expect(hospital.rooms[1].roomNumber, 201);
    });

    test('checkAvailability should return correct number of available beds', () {
      hospital.addRoom(101, RoomType.normal, 3);
      hospital.addRoom(102, RoomType.normal, 2);
      hospital.addRoom(201, RoomType.vip_private, 1);
      
      expect(hospital.checkAvailability(RoomType.normal), 5);
      expect(hospital.checkAvailability(RoomType.vip_private), 1);
      expect(hospital.checkAvailability(RoomType.vip_shared), 0);
    });

    test('addPatientBooking should add patient and create booking', () {
      hospital.addRoom(101, RoomType.normal, 2);
      
      hospital.addPatientBooking({
        'id': 1,
        'name': 'John Doe',
        'age': 30,
        'reason': 'Fever',
        'nights': 3,
        'roomType': RoomType.normal,
      });
      
      expect(hospital.patients.length, 1);
      expect(hospital.bookings.length, 1);
      expect(hospital.patients[0].name, 'John Doe');
      expect(hospital.bookings[0].nights, 3);
    });

    test('addPatientBooking should assign patient to available bed', () {
      hospital.addRoom(101, RoomType.normal, 2);
      
      hospital.addPatientBooking({
        'id': 1,
        'name': 'John Doe',
        'age': 30,
        'reason': 'Fever',
        'nights': 3,
        'roomType': RoomType.normal,
      });
      
      // Check that a bed is now occupied
      var occupiedBeds = hospital.rooms[0].beds.where((bed) => bed.isOccupied());
      expect(occupiedBeds.length, 1);
      expect(occupiedBeds.first.patient?.name, 'John Doe');
    });

    test('addPatientBooking should throw exception when no room available', () {
      hospital.addRoom(101, RoomType.vip_private, 1);
      
      // Fill the only bed
      hospital.addPatientBooking({
        'id': 1,
        'name': 'John Doe',
        'age': 30,
        'reason': 'Fever',
        'nights': 3,
        'roomType': RoomType.vip_private,
      });
      
      // Try to add another patient
      expect(
        () => hospital.addPatientBooking({
          'id': 2,
          'name': 'Jane Smith',
          'age': 25,
          'reason': 'Checkup',
          'nights': 2,
          'roomType': RoomType.vip_private,
        }),
        throwsException,
      );
    });

    test('checkAvailability should decrease after booking', () {
      hospital.addRoom(101, RoomType.normal, 3);
      
      expect(hospital.checkAvailability(RoomType.normal), 3);
      
      hospital.addPatientBooking({
        'id': 1,
        'name': 'John Doe',
        'age': 30,
        'reason': 'Fever',
        'nights': 3,
        'roomType': RoomType.normal,
      });
      
      expect(hospital.checkAvailability(RoomType.normal), 2);
    });

    test('calculateBill should return correct amount', () {
      hospital.addRoom(101, RoomType.normal, 2);
      
      hospital.addPatientBooking({
        'id': 1,
        'name': 'John Doe',
        'age': 30,
        'reason': 'Fever',
        'nights': 3,
        'roomType': RoomType.normal,
      });
      
      double bill = hospital.calculateBill(1);
      // Normal room: 50.0 per night * 3 nights = 150.0
      expect(bill, 150.0);
    });

    test('calculateBill should throw exception for non-existent patient', () {
      expect(
        () => hospital.calculateBill(999),
        throwsException,
      );
    });

    test('movePatient should move patient to new room', () {
      hospital.addRoom(101, RoomType.normal, 2);
      hospital.addRoom(201, RoomType.vip_private, 2);
      
      hospital.addPatientBooking({
        'id': 1,
        'name': 'John Doe',
        'age': 30,
        'reason': 'Fever',
        'nights': 3,
        'roomType': RoomType.normal,
      });
      
      hospital.movePatient(1, 201);
      
      // Check old room is released
      expect(hospital.rooms[0].beds.every((bed) => !bed.isOccupied()), true);
      
      // Check new room has patient
      var occupiedBeds = hospital.rooms[1].beds.where((bed) => bed.isOccupied());
      expect(occupiedBeds.length, 1);
      expect(occupiedBeds.first.patient?.id, 1);
    });

    test('movePatient should update booking with history', () {
      hospital.addRoom(101, RoomType.normal, 2);
      hospital.addRoom(201, RoomType.vip_private, 2);
      
      hospital.addPatientBooking({
        'id': 1,
        'name': 'John Doe',
        'age': 30,
        'reason': 'Fever',
        'nights': 3,
        'roomType': RoomType.normal,
      });
      
      hospital.movePatient(1, 201);
      
      Patient patient = hospital.patients[0];
      expect(patient.booking?.history.length, 1);
      expect(patient.booking?.history[0].roomType, RoomType.normal);
    });

    test('movePatient should throw exception for non-existent patient', () {
      hospital.addRoom(101, RoomType.normal, 2);
      
      expect(
        () => hospital.movePatient(999, 101),
        throwsException,
      );
    });

    test('movePatient should throw exception for non-existent room', () {
      hospital.addRoom(101, RoomType.normal, 2);
      
      hospital.addPatientBooking({
        'id': 1,
        'name': 'John Doe',
        'age': 30,
        'reason': 'Fever',
        'nights': 3,
        'roomType': RoomType.normal,
      });
      
      expect(
        () => hospital.movePatient(1, 999),
        throwsException,
      );
    });

    test('releasePatient should remove patient and free bed', () {
      hospital.addRoom(101, RoomType.normal, 2);
      
      hospital.addPatientBooking({
        'id': 1,
        'name': 'John Doe',
        'age': 30,
        'reason': 'Fever',
        'nights': 3,
        'roomType': RoomType.normal,
      });
      
      expect(hospital.patients.length, 1);
      expect(hospital.checkAvailability(RoomType.normal), 1);
      
      hospital.releasePatient(1);
      
      expect(hospital.patients.length, 0);
      expect(hospital.checkAvailability(RoomType.normal), 2);
    });

    test('releasePatient should throw exception for non-existent patient', () {
      expect(
        () => hospital.releasePatient(999),
        throwsException,
      );
    });

    test('calculateBill with room change should include history', () {
      hospital.addRoom(101, RoomType.normal, 2);
      hospital.addRoom(201, RoomType.vip_private, 2);
      
      hospital.addPatientBooking({
        'id': 1,
        'name': 'John Doe',
        'age': 30,
        'reason': 'Fever',
        'nights': 3,
        'roomType': RoomType.normal,
      });
      
      hospital.movePatient(1, 201);
      
      double bill = hospital.calculateBill(1);
      // Normal: 50.0 * 3 = 150.0 (history)
      // VIP Private: 200.0 * 3 = 600.0 (current)
      // Total: 750.0
      expect(bill, 750.0);
    });
  });

  group('Room Class Tests', () {
    test('Room should be created with beds', () {
      var beds = [Bed(bedNumber: 1), Bed(bedNumber: 2)];
      var room = Room(roomNumber: 101, type: RoomType.normal, beds: beds);
      
      expect(room.roomNumber, 101);
      expect(room.type, RoomType.normal);
      expect(room.beds.length, 2);
    });

    test('hasAvailableBed should return true when bed is free', () {
      var beds = [Bed(bedNumber: 1), Bed(bedNumber: 2)];
      var room = Room(roomNumber: 101, type: RoomType.normal, beds: beds);
      
      expect(room.hasAvailableBed(), true);
    });

    test('hasAvailableBed should return false when all beds occupied', () {
      var patient = Patient(id: 1, name: 'John', age: 30, reason: 'Fever', nights: 2);
      var beds = [Bed(bedNumber: 1, patient: patient)];
      var room = Room(roomNumber: 101, type: RoomType.normal, beds: beds);
      
      expect(room.hasAvailableBed(), false);
    });

    test('getAvailableBed should return first available bed', () {
      var beds = [Bed(bedNumber: 1), Bed(bedNumber: 2)];
      var room = Room(roomNumber: 101, type: RoomType.normal, beds: beds);
      
      var bed = room.getAvailableBed();
      expect(bed?.bedNumber, 1);
    });
  });

  group('Bed Class Tests', () {
    test('Bed should be created unoccupied', () {
      var bed = Bed(bedNumber: 1);
      expect(bed.isOccupied(), false);
    });

    test('assignPatient should occupy bed', () {
      var bed = Bed(bedNumber: 1);
      var patient = Patient(id: 1, name: 'John', age: 30, reason: 'Fever', nights: 2);
      
      bed.assignPatient(patient);
      expect(bed.isOccupied(), true);
      expect(bed.patient?.name, 'John');
    });

    test('release should free bed', () {
      var patient = Patient(id: 1, name: 'John', age: 30, reason: 'Fever', nights: 2);
      var bed = Bed(bedNumber: 1, patient: patient);
      
      expect(bed.isOccupied(), true);
      
      bed.release();
      expect(bed.isOccupied(), false);
      expect(bed.patient, null);
    });
  });

  group('Booking Class Tests', () {
    test('getTotalCost should calculate correctly without history', () {
      var patient = Patient(id: 1, name: 'John', age: 30, reason: 'Fever', nights: 3);
      var booking = Booking(
        bookingId: 1,
        patient: patient,
        roomType: RoomType.normal,
        startDate: DateTime.now(),
        nights: 3,
        pricePerNight: 50.0,
      );
      
      expect(booking.getTotalCost(), 150.0);
    });

    test('getTotalCost should include history', () {
      var patient = Patient(id: 1, name: 'John', age: 30, reason: 'Fever', nights: 3);
      var booking = Booking(
        bookingId: 1,
        patient: patient,
        roomType: RoomType.vip_private,
        startDate: DateTime.now(),
        nights: 3,
        pricePerNight: 200.0,
      );
      
      booking.history.add(BookingHistory(
        roomType: RoomType.normal,
        nights: 2,
        pricePerNight: 50.0,
      ));
      
      // Current: 3 * 200 = 600
      // History: 2 * 50 = 100
      // Total: 700
      expect(booking.getTotalCost(), 700.0);
    });
  });
}
