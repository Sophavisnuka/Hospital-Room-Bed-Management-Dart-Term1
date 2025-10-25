import 'package:my_first_project/Domain/admission.dart';
import 'package:my_first_project/Domain/room.dart';
import 'package:my_first_project/Domain/staff.dart';
import 'package:my_first_project/Domain/patient.dart';
import 'package:my_first_project/Domain/bed.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'dart:convert';

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

  
  // HOSPITAL METHODS
  void addRoom(Room room) {
    _room.add(room);
  }
  void registerPatient(Patient patient) {
    if (patient.age < 0) {
      print("Invalid age. Patient not registered.");
      return;
    }
    patients.add(patient);
  }
  void editPatient(Patient updatedPatient) {
    final index = _patient.indexWhere((p) => p.id == updatedPatient.id);
    if (index == -1) {
      print("Patient not found.");
      return;
    }

    _patient[index] = updatedPatient;
    print("Patient '${updatedPatient.name}' updated successfully!");
    saveToJson();
  }
  void deletePatient(String patientName) {
    final patient = patients.firstWhere((p) => p.name == patientName);
    patients.remove(patient);
    print('Patient has been deleted.');
    saveToJson();
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
  void saveToJson() {
    // Implementation for saving to JSON
    final file = File('lib/Data/patient_data.json');
    if (file.existsSync() == false) {
      throw Exception("File not found");
    }
    final data = _patient.map((p) => p.toMap()).toList();
    
    const encoder = JsonEncoder.withIndent('  ');
    file.writeAsStringSync(encoder.convert(data));
    print("Patients saved to patients.json");
  }
  void loadFromJson() {
    final file = File('lib/data/patient_data.json');
    if (file.existsSync()) {
      final content = file.readAsStringSync();
      final List decoded = jsonDecode(content);
      _patient = decoded.map((e) => Patient.fromMap(e)).toList();
      print("Loaded ${_patient.length} patients from JSON");
    } else {
      print("No existing patients.json found. Starting fresh.");
    }
  }
}
