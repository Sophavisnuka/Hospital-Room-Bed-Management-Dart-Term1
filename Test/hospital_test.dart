import 'package:my_first_project/Domain/hospital.dart';
import 'package:my_first_project/Ui/patient_console.dart';
void main () {
  final hospital = Hospital(name: "City Hospital", address: "123 Main St");
  final patientConsole = PatientConsole(hospital.patientService, hospital.admissionService);
  patientConsole.displayPatientUi();
}