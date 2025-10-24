import 'package:my_first_project/Domain/patient.dart';
import 'package:uuid/uuid.dart';

enum AdmissionStatus {
  admitted,
  transferred,
  pending_discharge,
  discharged
}

const uuid = Uuid();

class Admission {
  final String id;
  final Patient _patient;
  final String _roomId;
  final String _bedId;
  final String _staffId;
  final DateTime _admissionDate;

  Admission({
    required Patient patient,
    required String roomId,
    required String bedId,
    required String staffId,
    required DateTime admissionDate,
  })  : _patient = patient,
        _roomId = roomId,
        _bedId = bedId,
        _staffId = staffId,
        _admissionDate = admissionDate,
        id = uuid.v4();
}