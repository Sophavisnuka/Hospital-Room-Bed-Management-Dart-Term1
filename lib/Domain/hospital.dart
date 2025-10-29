import 'package:my_first_project/Domain/admission.dart';
import 'package:my_first_project/Domain/room.dart';
import 'package:my_first_project/Domain/staff.dart';
import 'package:my_first_project/Domain/patient.dart';
import 'package:my_first_project/Domain/bed.dart';
import 'package:uuid/uuid.dart';
import '../Data/hospital_repository.dart';
// import 'dart:io';
// import 'dart:convert';

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

  List<Patient> get patients => _patient;
  List<Room> get room => _room;

  // Load all data from JSON files
  Future<void> loadAllData() async {
    _patient = await _repository.loadData('patient_data.json', (map) => Patient.fromMap(map));
    _room = await _repository.loadData('room_data.json', (map) => Room.fromMap(map));
    // _admission = await _repository.getAllAdmissions();
    print('Loaded ${_patient.length} patients');
    print('Loaded ${_room.length} rooms');
  }

  // method for room
  Future<void> addRoom(Room room) async {
    // Check if room number already exists
    _room.add(room);
    _room.sort((a, b) => a.roomNumber.compareTo(b.roomNumber));
    await _repository.saveData('room_data.json', _room, (r) => r.toMap());
    print("Room added and data saved successfully!");
  }
  // method for patient
  Future<void> registerPatient(Patient patient) async {
    if (patient.age < 0) {
      print("Invalid age. Patient not registered.");
      return;
    }
    patients.add(patient);
    await _repository.saveData('patient_data.json', _patient, (p) => p.toMap());
    print("\nPatient registered successfully!\n");
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
    final matches = patients.where((p) => p.name.toLowerCase().contains(keyword.toLowerCase())).toList();

    if (matches.isEmpty) {
      print('No patients found matching "$keyword".');
    } else {
      print('Found ${matches.length} patient(s):');
      for (var p in matches) {
        print(p);
      }
    }
  }
  void admitPatient(Patient patient, Room room, Bed bed, Staff staff) {
    // Implementation for admitting a patient
  }
  void transferPatient(String admissionId, Room newRoom, Bed newBed, String reason) {
    // Implementation for transferring a patient
  }
  void dischargePatient(String admissionId) {
    // Implementation for discharging a patient
  }
  void calculateBilling(String admissionId) {
    // Implementation for calculating billing
  }
  // Future<void> loadFromJson() async {
  //   try {
  //     _patient = await _repository.getAllPatients();
  //     _room = await _repository.getAllRooms();
  //     // _admission = await _repository.getAllAdmissions();
  //     print('Data loaded successfully');
  //   } catch (e) {
  //     print('Error loading data: $e');
  //   }
  // }

  // Future<void> saveToJson() async {
  //   try {
  //     await _repository.savePatients(_patient);
  //     await _repository.saveRooms(_room);
  //     // await _repository.saveAdmissions(_admission);
  //     print('Data saved successfully');
  //   } catch (e) {
  //     print('Error saving data: $e');
  //   }
  // }
}
