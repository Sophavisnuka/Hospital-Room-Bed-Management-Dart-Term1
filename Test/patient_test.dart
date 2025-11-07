import 'package:test/test.dart';
import 'package:my_first_project/Domain/patient.dart';
import 'package:my_first_project/Domain/patient_service.dart';
import 'package:my_first_project/Domain/hospital.dart';

void main() {
  group('Patient Management Tests', () {
    late Hospital hospital;
    late PatientService patientService;

    setUp(() {
      hospital = Hospital(name: "Test Hospital", address: "123 Test St");
      patientService = hospital.patientService;
    });

    test('Should register a new patient successfully', () async {
      // Arrange
      final patient = Patient(
        name: "John Doe",
        age: 19,
        gender: "Male",
        phone: "123456789",
        dateOfBirth: "1993-01-01",
        reason: "Chest",
        nights: 3,
      );

      // Act
      await patientService.registerPatient(patient);

      // Assert
      expect(patientService.patients.length, equals(1));
      expect(patientService.patients.first.name, equals("John Doe"));
      expect(patientService.patients.first.age, equals(19));
      expect(patientService.patients.first.gender, equals("Male"));
      expect(patientService.patients.first.phone, equals("123456789"));
      expect(patientService.patients.first.nights, equals(3));
    });

    test('Should delete patient successfully', () async {
      // Arrange
      final patient = Patient(
        name: "Test Patient",
        age: 30,
        gender: "Male",
        phone: "123456789",
        dateOfBirth: "1993-01-01",
        reason: "Test",
        nights: 1,
      );
      await patientService.registerPatient(patient);

      // Act
      await patientService.deletePatient(patient.name);

      // Assert
      expect(patientService.patients.length, equals(0));
    });

    test('Should find patient by name successfully', () async {
      // Arrange
      final patient = Patient(
        name: "Charlie Brown",
        age: 28,
        gender: "Male",
        phone: "333333333",
        dateOfBirth: "1995-07-10",
        reason: "Recovery",
        nights: 4,
      );
      await patientService.registerPatient(patient);

      // Act
      final foundPatient = patientService.findPatientByName("Charlie Brown");

      // Assert
      expect(foundPatient, isNotNull);
      expect(foundPatient!.name, equals("Charlie Brown"));
      expect(foundPatient.age, equals(28));
    });
  });
}