import 'package:my_first_project/Domain/patient.dart';
import 'package:my_first_project/Data/hospital_repository.dart';

class PatientService {
  final HospitalRepository _repository;
  final List<Patient> _patients = [];

  PatientService(this._repository);

  // Encapsulated access - return immutable copy
  List<Patient> get patients => List.unmodifiable(_patients);

  // Load patients from storage
  Future<void> loadPatients() async {
    try {
      final loadedPatients = await _repository.loadData(
          'patient_data.json', (map) => Patient.fromMap(map));
      _patients.clear();
      _patients.addAll(loadedPatients);
    } catch (e) {
      print('Error loading patients: $e');
    }
  }

  // Register a new patient with validation
  Future<void> registerPatient(Patient patient) async {
    // Validation
    if (patient.age < 0) {
      throw ArgumentError("Invalid age. Patient age cannot be negative.");
    }

    // Check for duplicate patient by name and phone
    if (_patients.any((p) => p.name == patient.name && p.phone == patient.phone)) {
      throw StateError('Patient with same name and phone already exists');
    }

    // Check for duplicate ID
    if (_patients.any((p) => p.id == patient.id)) {
      throw StateError('Patient with this ID already exists');
    }

    _patients.add(patient);
    await _savePatients();
    print("Patient '${patient.name}' registered successfully!");
  }

  // Edit patient information
  Future<void> editPatient(Patient updatedPatient) async {
    final index = _patients.indexWhere((p) => p.id == updatedPatient.id);
    if (index == -1) {
      throw StateError("Patient with ID '${updatedPatient.id}' not found.");
    }

    // Validate the updated patient
    if (updatedPatient.age < 0) {
      throw ArgumentError("Invalid age. Patient age cannot be negative.");
    }

    _patients[index] = updatedPatient;
    await _savePatients();
    print("Patient '${updatedPatient.name}' updated successfully!");
  }

  // Delete patient by name
  Future<void> deletePatient(String patientName) async {
    final initialLength = _patients.length;
    _patients.removeWhere((p) => p.name.toLowerCase() == patientName.toLowerCase());
    
    if (_patients.length == initialLength) {
      throw StateError('Patient "$patientName" not found.');
    }

    await _savePatients();
    print('Patient "$patientName" deleted successfully.');
  }

  // Search patients by keyword
  List<Patient> searchPatient(String keyword) {
    if (keyword.trim().isEmpty) {
      return [];
    }

    final searchTerm = keyword.toLowerCase();
    final matches = _patients
        .where((p) => 
            p.name.toLowerCase().contains(searchTerm) ||
            (p.phone?.toLowerCase().contains(searchTerm) ?? false) ||
            (p.reason?.toLowerCase().contains(searchTerm) ?? false) ||
            (p.gender.toLowerCase().contains(searchTerm)) ||
            (p.dateOfBirth?.toLowerCase().contains(searchTerm) ?? false) ||
            p.age.toString().contains(keyword) ||
            (p.nights?.toString().contains(keyword) ?? false))
        .toList();

    return matches;
  }

  // Find patient by ID
  Patient? findPatientById(String id) {
    try {
      return _patients.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // Find patient by name
  Patient? findPatientByName(String name) {
    try {
      return _patients.firstWhere((p) => p.name.toLowerCase() == name.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  // Private method to save patients
  Future<void> _savePatients() async {
    try {
      await _repository.saveData('patient_data.json', _patients, (p) => p.toMap());
    } catch (e) {
      print('Error saving patients: $e');
      throw StateError('Failed to save patient data');
    }
  }

  // Validate patient data
  static void validatePatient(Patient patient) {
    if (patient.name.trim().isEmpty) {
      throw ArgumentError('Patient name cannot be empty');
    }
    if (patient.age < 0 || patient.age > 150) {
      throw ArgumentError('Patient age must be between 0 and 150');
    }
    if (patient.gender.trim().isEmpty) {
      throw ArgumentError('Patient gender cannot be empty');
    }
    if (patient.nights != null && patient.nights! <= 0) {
      throw ArgumentError('Number of nights must be positive');
    }
  }
}