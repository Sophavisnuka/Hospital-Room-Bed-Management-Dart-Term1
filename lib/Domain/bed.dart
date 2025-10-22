import 'patient.dart';

class Bed {
  int bedNumber;
  Patient? patient;

  Bed({
    required this.bedNumber,
    this.patient,
  });

  bool isOccupied() {
    return patient != null;
  }

  void assignPatient(Patient p) {
    patient = p;
  }

  void release() {
    patient = null;
  }
}
