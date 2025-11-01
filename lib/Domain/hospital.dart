import 'package:my_first_project/Domain/admission.dart';
import 'package:my_first_project/Domain/room.dart';
import 'package:my_first_project/Domain/staff.dart';
import 'package:my_first_project/Domain/patient.dart';
import 'package:my_first_project/Domain/bed.dart';
import 'package:uuid/uuid.dart';
import '../Data/hospital_repository.dart';

const uuid = Uuid();

class Hospital {
  String _id;
  String _name;
  String _address;
  int _nextAdmissionId;
  List<Bed> _bed;
  List<Room> _room;
  List<Patient> _patient = [];
  List<Admission> _admission;
  List<Staff> _staff;

  final HospitalRepository _repository = HospitalRepository();

  Hospital({required String name, required String address})
      : _name = name,
        _address = address,
        _nextAdmissionId = 1,
        _bed = [],
        _room = [],
        _patient = [],
        _admission = [],
        _staff = [],
        _id = uuid.v4();

  List<Bed> get beds => _bed;
  List<Patient> get patients => _patient;
  List<Room> get rooms => _room;
  List<Admission> get admissions => _admission;

  // Load all data from JSON files
  Future<void> loadAllData() async {
    _patient = await _repository.loadData(
        'patient_data.json', (map) => Patient.fromMap(map));
    _room = await _repository.loadData(
        'room_data.json', (map) => Room.fromMap(map));
    _admission = await _repository.loadData(
        'admission_data.json', (map) => Admission.fromMap(map));
    // _admission = await _repository.getAllAdmissions();
    print('Loaded ${_patient.length} patients');
    print('Loaded ${_room.length} rooms');
    print('Loaded ${_admission.length} admissions');
  }

  // method for room
  Future<void> addRoom(Room room) async {
    // Check if room number already exists
    _room.add(room);
    _room.sort((a, b) => a.roomNumber.compareTo(b.roomNumber));
    await _repository.saveData('room_data.json', _room, (r) => r.toMap());
    print("Room added and data saved successfully!");
  }
  Future<String> editRoomStatus(int roomNumber, String bedNumber, BedStatus status) async {
    final room = rooms.firstWhere(
      (r) => r.roomNumber == roomNumber,
      orElse: () => throw Exception('Room $roomNumber not found.'),
    );
    final bed = room.beds.firstWhere(
      (b) => b.bedNumber == bedNumber,
      orElse: () => throw Exception('Bed $bedNumber not found.'),
    );
    String currentBedStatus = bed.getStatus.toString().split('.').last;
    bed.setStatus = status;
    // update room availability 
    final availableBeds = room.beds.where((b) => b.getStatus == BedStatus.available).length;
    if (availableBeds > 0) {
      room.isAvailable = true;
    } else {
      room.isAvailable = false;
    }
    await _repository.saveData('room_data.json', _room, (r) => r.toMap());
    print('Bed $bedNumber status updated to ${status.toString().split('.').last}');
    return currentBedStatus;
  }
  // method for patient
  Future<void> registerPatient(Patient patient) async {
    if (patient.age < 0) {
      print("Invalid age. Patient not registered.");
      return;
    }
    patients.add(patient);
    await _repository.saveData('patient_data.json', _patient, (p) => p.toMap());
  }

  Future<void> editPatient(Patient updatedPatient) async {
    final index = _patient.indexWhere((p) => p.id == updatedPatient.id);
    if (index == -1) {
      print("Patient not found.");
      return;
    }

    _patient[index] = updatedPatient;
    print("Patient '${updatedPatient.name}' updated successfully!");
    await _repository.saveData('patient_data.json', _patient, (p) => p.toMap());
    print('Patient updated successfully');
  }

  Future<void> deletePatient(String patientName) async {
    final patient = patients.firstWhere((p) => p.name == patientName);
    patients.remove(patient);
    print('Patient has been deleted.');
    await _repository.saveData('patient_data.json', _patient, (p) => p.toMap());
    print('Patient deleted successfully');
  }

  void searchPatient(String keyword) {
    // Implementation for searching a patient
    final matches = patients
        .where((p) => p.name.toLowerCase().contains(keyword.toLowerCase()))
        .toList();

    if (matches.isEmpty) {
      print('No patients found matching "$keyword".');
    } else {
      print('Found ${matches.length} patient(s):');
      for (var p in matches) {
        print(p);
      }
    }
  }

  Future<void> admitPatient(String patientName, int roomNumber, String bedNumber, DateTime admissionDate) async {
    // Implementation for admitting a patient
    final patient = patients.firstWhere(
      (p) => p.name == patientName,
      orElse: () => throw Exception('Patient $patientName not found.'),
    );
    final checkPatientAdmission = _admission.where(
      (a) => a.patient == patient.name && a.dischargeDate == null,
    ).toList();
    if (checkPatientAdmission.isNotEmpty) {
      print('\nError: Patient ${patient.name} is already admitted!');
      print('Current admission details:');
      print('  Room: ${checkPatientAdmission.first.roomNumber}');
      print('  Bed: ${checkPatientAdmission.first.bedNumber}');
      print('  Admission Date: ${checkPatientAdmission.first.admissionDate}');
      print('\nPlease use "Transfer Patient" option to move to another room.');
      return;
    }
    final room = rooms.firstWhere(
      (r) => r.roomNumber == roomNumber, 
      orElse: () => throw Exception('Room $roomNumber not found.'),
    );
    final bed = room.beds.firstWhere(
      (b) => b.bedNumber == bedNumber, 
      orElse: () => throw Exception('Bed $bedNumber not found.'),
    );
    // Check if the bed is available
    if (bed.getStatus != BedStatus.available) {
      print('Error: Bed $bedNumber in Room $roomNumber is not available.');
      print('Current status: ${bed.getStatus}');
      return;
    }
    // Check if all beds in the room are occupied (update room availability)
    final availableBeds = room.beds.where((b) => b.getStatus == BedStatus.available).length;
    if (availableBeds == 0) {
      print('Error: Room $roomNumber has no available beds.');
      return;
    }
    final admission = Admission(
      patient: patient.name,
      roomNumber: roomNumber, 
      bedNumber: bedNumber,
      admissionDate: admissionDate,
    );
    bed.setStatus = BedStatus.occupied;
    // Add admission and save data
    _admission.add(admission);
    await _repository.saveData('room_data.json', _room, (r) => r.toMap());
    await _repository.saveData('admission_data.json', _admission, (a) => a.toMap());

    print('\nPatient ${patient.name} admitted successfully!');
    print('  Room: $roomNumber');
    print('  Bed: $bedNumber');
    print('  Available beds in room: ${availableBeds - 1}/${room.beds.length}');
  }

  Future<void> transferPatient(String patientName, int currentRoomNum, String currentBedNum, String newBedNum, int newRoomNum, String transferReason) async {
    // Implementation for transferring a patient
    final patient = patients.firstWhere(
      (p) => p.name == patientName,
      orElse: () => throw Exception('Patient $patientName not found.'),
    );
    final currentRoom = rooms.firstWhere(
      (r) => r.roomNumber == currentRoomNum, 
      orElse: () => throw Exception('Current Room $currentRoomNum not found.'),
    );
    final newRoom = rooms.firstWhere(
      (r) => r.roomNumber == newRoomNum,
      orElse: () => throw Exception('New Room $newRoomNum not found.'),
    );
    final currentBed = currentRoom.beds.firstWhere(
      (b) => b.bedNumber == currentBedNum, 
      orElse: () => throw Exception('Current Bed $currentBedNum not found.'),
    );
    final newBed = newRoom.beds.firstWhere(
      (b) => b.bedNumber == newBedNum, 
      orElse: () => throw Exception('New Bed $newBedNum not found.'),
    ); 
    // Check if current bed is occupied
    if (currentBed.getStatus != BedStatus.occupied) {
      print('Error: Current bed $currentBedNum is not occupied.');
      return;
    }
    // Check if new bed is available
    if (newBed.getStatus != BedStatus.available) {
      print('Error: New bed $newBedNum in Room $newRoomNum is not available.');
      print('Current status: ${newBed.getStatus}');
      return;
    }

    //Find the current admission record 
    final currentAdmission = _admission.firstWhere(
      (a) => a.patient == patient.name && a.roomNumber == currentRoomNum && a.bedNumber == currentBedNum,
      orElse: () => throw Exception('Current admission not found.')
    );

    currentBed.setStatus = BedStatus.available;
    // Update old room availability if it was full
    if (!currentRoom.isAvailable) {
      currentRoom.isAvailable = true;
    }
    newBed.setStatus = BedStatus.occupied;
    // Update new room availability if all beds are now occupied
    if (newRoom.beds.every((b) => b.getStatus != BedStatus.available)) {
      newRoom.isAvailable = false;
    }

    final newAdmission = Admission(
      patient: patient.name,
      roomNumber: newRoomNum,
      bedNumber: newBedNum,
      admissionDate: DateTime.now(),
      transferReason: transferReason,
      previousRoomNumber: currentRoomNum,
      previousBedNumber: currentBedNum,
    );
    // Close the old admission record
    currentAdmission.dischargeDate = DateTime.now();
    currentAdmission.dischargeReason = 'Transferred to Room $newRoomNum';

    _admission.add(newAdmission);
    await _repository.saveData('room_data.json', _room, (r) => r.toMap());
    await _repository.saveData('admission_data.json', _admission, (a) => a.toMap());
    print('\nPatient ${patient.name} transferred successfully!');
    print('  From: Room $currentRoomNum, Bed $currentBedNum');
    print('  To: Room $newRoomNum, Bed $newBedNum');
    print('  Reason: $transferReason');
    print('  Transfer Date: ${DateTime.now()}');
  }
  Future<void> dischargePatient(String admissionId) async {
    // Implementation for discharging a patient
  }
  Future<void> calculateBilling(String admissionId) async {
    // Implementation for calculating billing
  }
}
