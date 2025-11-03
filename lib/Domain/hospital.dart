import 'package:my_first_project/Domain/admission_service.dart';
import 'package:my_first_project/Domain/patient_service.dart';
import 'package:my_first_project/Domain/room_service.dart';
import '../Data/hospital_repository.dart';

// const uuid = Uuid();

class Hospital {
  final String name;
  final String address;
  
  late final PatientService patientService;
  late final RoomService roomService;
  late final AdmissionService admissionService;
  
  Hospital({required this.name, required this.address}) {
    final repository = HospitalRepository();
    patientService = PatientService(repository);
    roomService = RoomService(repository);
    admissionService = AdmissionService(repository, patientService, roomService);
  }
  // Add this method to load all data from services
  Future<void> loadAllData() async {
    print('Loading patients...');
    await patientService.loadPatients();
    
    print('Loading rooms...');
    await roomService.loadRooms();
    
    print('Loading admissions...');
    await admissionService.loadAdmissions();
    
    print('Loading discharges...');
    await admissionService.loadDischarges();
    
    // Debug output
    print('✓ Loaded ${patientService.patients.length} patients');
    print('✓ Loaded ${roomService.rooms.length} rooms');
    print('✓ Loaded ${admissionService.admissions.length} admissions');
    print('✓ Loaded ${admissionService.discharges.length} discharges');
  }

  // Getter methods for easy access (optional)
  String get hospitalName => name;
  String get hospitalAddress => address;
}
