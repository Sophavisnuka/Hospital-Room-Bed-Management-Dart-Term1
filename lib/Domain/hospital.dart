import 'dart:convert';
import 'dart:io';
import 'room.dart';
import 'patient.dart';
import 'booking.dart';
import 'bookingHistory.dart';
import 'bed.dart';

class Hospital {
  List<Room> rooms;
  List<Patient> patients;
  List<Booking> bookings;

  Hospital({
    List<Room>? rooms,
    List<Patient>? patients,
    List<Booking>? bookings,
  })  : rooms = rooms ?? [],
        patients = patients ?? [],
        bookings = bookings ?? [];

  // Add a new room to the hospital
  void addRoom(int roomNumber, RoomType type, int bedCount) {
    // Create beds for the room
    List<Bed> beds = [];
    for (int i = 1; i <= bedCount; i++) {
      beds.add(Bed(bedNumber: i));
    }
    
    Room newRoom = Room(
      roomNumber: roomNumber,
      type: type,
      beds: beds,
    );
    
    rooms.add(newRoom);
  }

  // Add a patient and create a booking
  void addPatientBooking(Map<String, dynamic> patientInfo) {
    // Create patient
    Patient patient = Patient(
      id: patientInfo['id'],
      name: patientInfo['name'],
      age: patientInfo['age'],
      reason: patientInfo['reason'],
      nights: patientInfo['nights'],
    );

    // Find available room of requested type
    RoomType requestedType = patientInfo['roomType'];
    Room? availableRoom = rooms.firstWhere(
      (room) => room.type == requestedType && room.hasAvailableBed(),
      orElse: () => throw Exception('No available room of type ${requestedType.name}'),
    );

    // Get available bed and assign patient
    Bed? bed = availableRoom.getAvailableBed();
    if (bed != null) {
      bed.assignPatient(patient);
    }

    // Create booking
    Booking booking = Booking(
      bookingId: bookings.length + 1,
      patient: patient,
      roomType: requestedType,
      startDate: DateTime.now(),
      nights: patientInfo['nights'],
      pricePerNight: _getPriceForRoomType(requestedType),
    );

    patient.booking = booking;
    patients.add(patient);
    bookings.add(booking);
  }

  // Move patient to a different room
  void movePatient(int patientId, int newRoomNumber) {
    // Find patient
    Patient patient = patients.firstWhere(
      (p) => p.id == patientId,
      orElse: () => throw Exception('Patient with ID $patientId not found'),
    );

    // Find current bed and release it
    for (var room in rooms) {
      for (var bed in room.beds) {
        if (bed.patient?.id == patientId) {
          bed.release();
          break;
        }
      }
    }

    // Find new room
    Room newRoom = rooms.firstWhere(
      (room) => room.roomNumber == newRoomNumber,
      orElse: () => throw Exception('Room $newRoomNumber not found'),
    );

    // Get available bed in new room
    Bed? newBed = newRoom.getAvailableBed();
    if (newBed == null) {
      throw Exception('No available bed in room $newRoomNumber');
    }

    // Assign patient to new bed
    newBed.assignPatient(patient);

    // Update booking if exists
    if (patient.booking != null) {
      // Save old booking to history
      patient.booking!.history.add(
        BookingHistory(
          roomType: patient.booking!.roomType,
          nights: patient.booking!.nights,
          pricePerNight: patient.booking!.pricePerNight,
        ),
      );

      // Update current booking
      patient.booking!.roomType = newRoom.type;
      patient.booking!.pricePerNight = _getPriceForRoomType(newRoom.type);
    }
  }

  // Release patient from hospital
  void releasePatient(int patientId) {
    // Find patient to verify it exists
    patients.firstWhere(
      (p) => p.id == patientId,
      orElse: () => throw Exception('Patient with ID $patientId not found'),
    );

    // Find and release bed
    for (var room in rooms) {
      for (var bed in room.beds) {
        if (bed.patient?.id == patientId) {
          bed.release();
          break;
        }
      }
    }

    // Remove patient from list
    patients.removeWhere((p) => p.id == patientId);
    
    // Remove associated booking
    bookings.removeWhere((b) => b.patient.id == patientId);
  }

  // Check availability of a specific room type
  int checkAvailability(RoomType roomType) {
    int availableBeds = 0;
    
    for (var room in rooms) {
      if (room.type == roomType) {
        for (var bed in room.beds) {
          if (!bed.isOccupied()) {
            availableBeds++;
          }
        }
      }
    }
    
    return availableBeds;
  }

  // Calculate bill for a patient
  double calculateBill(int patientId) {
    // Find patient
    Patient patient = patients.firstWhere(
      (p) => p.id == patientId,
      orElse: () => throw Exception('Patient with ID $patientId not found'),
    );

    // Return total cost from booking
    if (patient.booking != null) {
      return patient.booking!.getTotalCost();
    }

    return 0.0;
  }

  // Save data to file
  void saveData() {
    try {
      Map<String, dynamic> data = {
        'rooms': rooms.map((room) => {
          'roomNumber': room.roomNumber,
          'type': room.type.index,
          'beds': room.beds.map((bed) => {
            'bedNumber': bed.bedNumber,
            'patientId': bed.patient?.id,
          }).toList(),
        }).toList(),
        'patients': patients.map((patient) => {
          'id': patient.id,
          'name': patient.name,
          'age': patient.age,
          'reason': patient.reason,
          'nights': patient.nights,
        }).toList(),
        'bookings': bookings.map((booking) => {
          'bookingId': booking.bookingId,
          'patientId': booking.patient.id,
          'roomType': booking.roomType.index,
          'startDate': booking.startDate.toIso8601String(),
          'nights': booking.nights,
          'pricePerNight': booking.pricePerNight,
          'history': booking.history.map((h) => {
            'roomType': h.roomType.index,
            'nights': h.nights,
            'pricePerNight': h.pricePerNight,
          }).toList(),
        }).toList(),
      };

      File file = File('hospital_data.json');
      file.writeAsStringSync(jsonEncode(data));
      print('Data saved successfully to hospital_data.json');
    } catch (e) {
      print('Error saving data: $e');
    }
  }

  // Load data from file
  void loadData() {
    try {
      File file = File('hospital_data.json');
      if (!file.existsSync()) {
        print('No saved data found');
        return;
      }

      String content = file.readAsStringSync();
      Map<String, dynamic> data = jsonDecode(content);

      // Clear current data
      rooms.clear();
      patients.clear();
      bookings.clear();

      // Load rooms
      List roomsData = data['rooms'] ?? [];
      for (var roomData in roomsData) {
        List<Bed> beds = [];
        for (var bedData in roomData['beds']) {
          beds.add(Bed(bedNumber: bedData['bedNumber']));
        }
        
        rooms.add(Room(
          roomNumber: roomData['roomNumber'],
          type: RoomType.values[roomData['type']],
          beds: beds,
        ));
      }

      // Load patients
      List patientsData = data['patients'] ?? [];
      Map<int, Patient> patientMap = {};
      for (var patientData in patientsData) {
        Patient patient = Patient(
          id: patientData['id'],
          name: patientData['name'],
          age: patientData['age'],
          reason: patientData['reason'],
          nights: patientData['nights'],
        );
        patients.add(patient);
        patientMap[patient.id] = patient;
      }

      // Load bookings
      List bookingsData = data['bookings'] ?? [];
      for (var bookingData in bookingsData) {
        Patient patient = patientMap[bookingData['patientId']]!;
        
        List<BookingHistory> history = [];
        for (var historyData in bookingData['history']) {
          history.add(BookingHistory(
            roomType: RoomType.values[historyData['roomType']],
            nights: historyData['nights'],
            pricePerNight: historyData['pricePerNight'],
          ));
        }

        Booking booking = Booking(
          bookingId: bookingData['bookingId'],
          patient: patient,
          roomType: RoomType.values[bookingData['roomType']],
          startDate: DateTime.parse(bookingData['startDate']),
          nights: bookingData['nights'],
          pricePerNight: bookingData['pricePerNight'],
          history: history,
        );

        patient.booking = booking;
        bookings.add(booking);
      }

      // Re-assign patients to beds
      for (var roomData in roomsData) {
        Room room = rooms.firstWhere((r) => r.roomNumber == roomData['roomNumber']);
        List bedsData = roomData['beds'];
        
        for (int i = 0; i < bedsData.length; i++) {
          var bedData = bedsData[i];
          if (bedData['patientId'] != null) {
            Patient? patient = patientMap[bedData['patientId']];
            if (patient != null) {
              room.beds[i].assignPatient(patient);
            }
          }
        }
      }

      print('Data loaded successfully from hospital_data.json');
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  // Helper method to get price for room type
  double _getPriceForRoomType(RoomType type) {
    switch (type) {
      case RoomType.normal:
        return 50.0;
      case RoomType.vip_shared:
        return 100.0;
      case RoomType.vip_private:
        return 200.0;
      case RoomType.vip_single:
        return 300.0;
    }
  }
}
