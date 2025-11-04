import 'package:my_first_project/Domain/admission.dart';
import 'package:my_first_project/Domain/discharge.dart';
import 'package:my_first_project/Domain/patient_service.dart';
import 'package:my_first_project/Domain/room_service.dart';
import 'package:my_first_project/Domain/bed.dart';
import 'package:my_first_project/Data/hospital_repository.dart';

class AdmissionService {
  final HospitalRepository _repository;
  final PatientService _patientService;
  final RoomService _roomService;
  final List<Admission> _admissions = [];
  final List<Discharge> _discharges = [];

  AdmissionService(this._repository, this._patientService, this._roomService);

  // Encapsulated access - return immutable copies
  List<Admission> get admissions => List.unmodifiable(_admissions);
  List<Discharge> get discharges => List.unmodifiable(_discharges);

  // Load data from storage
  Future<void> loadAdmissions() async {
    try {
      final loadedAdmissions = await _repository.loadData(
          'admission_data.json', (map) => Admission.fromMap(map));
      _admissions.clear();
      _admissions.addAll(loadedAdmissions);
    } catch (e) {
      print('Error loading admissions: $e');
    }
  }

  Future<void> loadDischarges() async {
    try {
      final loadedDischarges = await _repository.loadData(
          'discharge_data.json', (map) => Discharge.fromMap(map));
      _discharges.clear();
      _discharges.addAll(loadedDischarges);
    } catch (e) {
      print('Error loading discharges: $e');
    }
  }

  // Admit a patient to a room
  Future<void> admitPatient(String patientName, int roomNumber, String bedNumber, DateTime admissionDate) async {
    // Find and validate patient
    final patient = _patientService.findPatientByName(patientName);
    if (patient == null) {
      throw StateError('Patient "$patientName" not found');
    }

    // Validate patient nights
    if (patient.nights == null || patient.nights! <= 0) {
      throw ArgumentError('Patient must have a valid number of nights (greater than 0)');
    }

    // Check if patient is already admitted
    if (_isPatientCurrentlyAdmitted(patientName)) {
      final currentAdmission = _getCurrentAdmission(patientName);
      throw StateError(
          'Patient "$patientName" is already admitted!\n'
          'Current admission: Room ${currentAdmission!.roomNumber}, Bed ${currentAdmission.bedNumber}\n'
          'Use transfer patient option to move to another room.');
    }

    // Find and validate room
    final room = _roomService.findRoomByNumber(roomNumber);
    if (room == null) {
      throw StateError('Room $roomNumber not found');
    }

    // Find and validate bed
    final bed = room.beds.where((b) => b.bedNumber == bedNumber).firstOrNull;
    if (bed == null) {
      throw StateError('Bed $bedNumber not found in room $roomNumber');
    }

    // Check if bed is available
    if (bed.getStatus != BedStatus.available) {
      throw StateError('Bed $bedNumber is not available. Current status: ${bed.getStatus.toString().split('.').last}');
    }

    // Check if room has available beds
    final availableBeds = room.beds.where((b) => b.getStatus == BedStatus.available).length;
    if (availableBeds == 0) {
      throw StateError('Room $roomNumber has no available beds');
    }

    // Calculate total price using polymorphism
    double totalPrice = room.calculateTotalCost(patient.nights!);

    // Create admission record
    final admission = Admission(
      patient: patient.name,
      roomNumber: roomNumber,
      bedNumber: bedNumber,
      admissionDate: admissionDate,
      totalPrice: totalPrice,
    );

    // Update bed status
    bed.setStatus = BedStatus.occupied;

    // Update room availability if all beds are now occupied
    if (room.beds.every((b) => b.getStatus != BedStatus.available)) {
      room.isAvailable = false;
    }

    // Save changes
    _admissions.add(admission);
    await _saveAdmissions();
    await _roomService.saveRooms(); // Save room changes

    print('\n✓ Patient ${patient.name} admitted successfully!');
    print('  Room: $roomNumber');
    print('  Bed: $bedNumber');
    print('  Base Price: \$${room.basePrice.toStringAsFixed(2)} per night');
    print('  Number of Nights: ${patient.nights}');
    print('  Total Price: \$${totalPrice.toStringAsFixed(2)}');
    print('  Available beds in room: ${availableBeds - 1}/${room.beds.length}');
  }

  // Transfer patient between rooms
  Future<void> transferPatient({required String patientName, required int currentRoomNum, required String currentBedNum, required int newRoomNum, required String newBedNum, required  String transferReason}) async {
    // Find patient
    final patient = _patientService.findPatientByName(patientName);
    if (patient == null) {
      throw StateError('Patient "$patientName" not found');
    }

    // Find current and new rooms
    final currentRoom = _roomService.findRoomByNumber(currentRoomNum);
    final newRoom = _roomService.findRoomByNumber(newRoomNum);
    
    if (currentRoom == null) {
      throw StateError('Current room $currentRoomNum not found');
    }
    if (newRoom == null) {
      throw StateError('New room $newRoomNum not found');
    }

    // Find current and new beds
    final currentBed = currentRoom.beds.where((b) => b.bedNumber == currentBedNum).firstOrNull;
    final newBed = newRoom.beds.where((b) => b.bedNumber == newBedNum).firstOrNull;
    
    if (currentBed == null) {
      throw StateError('Current bed $currentBedNum not found in room $currentRoomNum');
    }
    if (newBed == null) {
      throw StateError('New bed $newBedNum not found in room $newRoomNum');
    }

    // Validate bed statuses
    if (currentBed.getStatus != BedStatus.occupied) {
      throw StateError('Current bed $currentBedNum is not occupied');
    }
    if (newBed.getStatus != BedStatus.available) {
      throw StateError('New bed $newBedNum is not available. Current status: ${newBed.getStatus.toString().split('.').last}');
    }

    // Find current admission record
    final currentAdmission = _admissions.where((a) => 
        a.patient == patientName && 
        a.roomNumber == currentRoomNum && 
        a.bedNumber == currentBedNum &&
        a.dischargeDate == null).firstOrNull;
    
    if (currentAdmission == null) {
      throw StateError('No active admission found for $patientName in room $currentRoomNum');
    }

    // Update bed statuses
    currentBed.setStatus = BedStatus.available;
    newBed.setStatus = BedStatus.occupied;

    // Update room availability
    currentRoom.isAvailable = true; // Current room now has at least one available bed
    if (newRoom.beds.every((b) => b.getStatus != BedStatus.available)) {
      newRoom.isAvailable = false;
    }

    // Calculate new total price for the new room
    double newTotalPrice = newRoom.calculateTotalCost(patient.nights!);

    // Create new admission record
    final newAdmission = Admission(
      patient: patientName,
      roomNumber: newRoomNum,
      bedNumber: newBedNum,
      admissionDate: DateTime.now(),
      transferReason: transferReason,
      previousRoomNumber: currentRoomNum,
      previousBedNumber: currentBedNum,
      totalPrice: newTotalPrice,
    );

    // Close the old admission record
    currentAdmission.dischargeDate = DateTime.now();
    currentAdmission.dischargeReason = 'Transferred to Room $newRoomNum';

    // Add new admission
    _admissions.add(newAdmission);

    // Save changes
    await _saveAdmissions();
    await _roomService.saveRooms();

    print('\n✓ Patient $patientName transferred successfully!');
    print('  From: Room $currentRoomNum, Bed $currentBedNum');
    print('  To: Room $newRoomNum, Bed $newBedNum');
    print('  Reason: $transferReason');
    print('  New Total Price: \$${newTotalPrice.toStringAsFixed(2)}');
    print('  Transfer Date: ${DateTime.now()}');
  }

  // Discharge a patient
  Future<void> dischargePatient({required String patientName, required int roomNumber, required String bedNumber, required String dischargeReason}) async {
    // Find patient
    final patient = _patientService.findPatientByName(patientName);
    if (patient == null) {
      throw StateError('Patient "$patientName" not found');
    }

    // Find active admission
    final admission = _getCurrentAdmission(patientName);
    if (admission == null) {
      throw StateError('No active admission found for "$patientName"');
    }

    // Find the room and bed
    final room = _roomService.findRoomByNumber(admission.roomNumber)!;
    final bed = room.beds.firstWhere((b) => b.bedNumber == admission.bedNumber);

    // Calculate actual nights stayed and final price
    final dischargeDate = DateTime.now();
    final nightsStayed = dischargeDate.difference(admission.admissionDate).inDays;
    final actualNights = nightsStayed > 0 ? nightsStayed : 1; // Minimum 1 night
    final finalPrice = room.calculateTotalCost(actualNights);

    // Create discharge record
    final discharge = Discharge(
      admissionId: admission.id,
      patient: patientName,
      roomNumber: admission.roomNumber,
      bedNumber: admission.bedNumber,
      admissionDate: admission.admissionDate,
      dischargeDate: dischargeDate,
      dischargeReason: dischargeReason,
      totalPrice: finalPrice,
      nightsStayed: actualNights,
    );

    // Update bed status to available
    bed.setStatus = BedStatus.available;

    // Update room availability
    room.isAvailable = true;

    // Remove admission from active list and add to discharge list
    _admissions.removeWhere((a) => a.id == admission.id);
    _discharges.add(discharge);

    // Save changes
    await _saveAdmissions();
    await _saveDischarges();
    await _roomService.saveRooms();

    print('\n✓ Patient $patientName discharged successfully!');
    print('  Room: ${admission.roomNumber}');
    print('  Bed: ${admission.bedNumber}');
    print('  Admission Date: ${admission.admissionDate.toLocal()}');
    print('  Discharge Date: ${dischargeDate.toLocal()}');
    print('  Nights Stayed: $actualNights');
    print('  Final Price: \$${finalPrice.toStringAsFixed(2)}');
    print('  Reason: $dischargeReason');
  }

  // Delete admission by patient name
  Future<void> deleteAdmissionByPatientName(String patientName) async {
    final initialLength = _admissions.length;
    _admissions.removeWhere((a) => a.patient.toLowerCase() == patientName.toLowerCase());
    
    if (_admissions.length == initialLength) {
      throw StateError('No admission found for patient "$patientName"');
    }

    await _saveAdmissions();
    print('Admission for patient "$patientName" deleted successfully.');
  }

  // Search admissions by patient name
  List<Admission> searchAdmission(String patientName) {
    if (patientName.trim().isEmpty) {
      return [];
    }

    return _admissions
        .where((a) => a.patient.toLowerCase().contains(patientName.toLowerCase()))
        .toList();
  }

  // Private helper methods
  bool _isPatientCurrentlyAdmitted(String patientName) {
    return _admissions.any((a) => 
        a.patient.toLowerCase() == patientName.toLowerCase() && 
        a.dischargeDate == null);
  }

  Admission? _getCurrentAdmission(String patientName) {
    try {
      return _admissions.firstWhere((a) => 
          a.patient.toLowerCase() == patientName.toLowerCase() && 
          a.dischargeDate == null);
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveAdmissions() async {
    try {
      await _repository.saveData('admission_data.json', _admissions, (a) => a.toMap());
    } catch (e) {
      print('Error saving admissions: $e');
      throw StateError('Failed to save admission data');
    }
  }

  Future<void> _saveDischarges() async {
    try {
      await _repository.saveData('discharge_data.json', _discharges, (d) => d.toMap());
    } catch (e) {
      print('Error saving discharges: $e');
      throw StateError('Failed to save discharge data');
    }
  }
}