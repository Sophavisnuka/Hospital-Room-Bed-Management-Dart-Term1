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
      
      //
      await _cleanupInconsistentData();
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

  Future<void> _cleanupInconsistentData() async {
    bool hasChanges = false;
    
    // Move discharged admissions to discharge list
    final dischargedAdmissions = _admissions.where((a) => a.dischargeDate != null).toList();
    
    for (final admission in dischargedAdmissions) {
      // Create discharge record if it doesn't exist
      final existingDischarge = _discharges.where((d) => d.admissionId == admission.id).firstOrNull;

      if (existingDischarge == null) {
        final discharge = Discharge(
          admission: admission,  // Pass the entire admission object
          dischargeDate: admission.dischargeDate!,
          dischargeReason: admission.dischargeReason ?? 'Unknown',
          nightsStayed: admission.dischargeDate!.difference(admission.admissionDate).inDays,
        );
        _discharges.add(discharge);
        hasChanges = true;
      }
      
      // Remove from admissions
      _admissions.remove(admission);
      hasChanges = true;
    }
    
    if (hasChanges) {
      await _saveAdmissions();
      await _saveDischarges();
      print('Cleaned up ${dischargedAdmissions.length} inconsistent admission records');
    }
  }

  // Admit a patient to a room
  Future<void> admitPatient({required String patientName, required int roomNumber, required String bedNumber, required DateTime admissionDate}) async {
    // Find and validate patient
    final patient = _patientService.findPatientByName(patientName);
    if (patient == null) {
      throw StateError('Patient "$patientName" not found');
    }

    // Validate patient nights
    if (patient.nights == null || patient.nights! <= 0) {
      throw ArgumentError('Patient must have a valid number of nights (greater than 0)');
    }

    // Check if patient is currently admitted (only active admissions)
    if (_isPatientCurrentlyAdmitted(patientName)) {
      final currentAdmission = _getCurrentActiveAdmission(patientName);
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
    await _roomService.saveRooms();

    print('\nPatient ${patient.name} admitted successfully!');
    print('  Room: $roomNumber');
    print('  Bed: $bedNumber');
    print('  Base Price: \$${room.basePrice.toStringAsFixed(2)} per night');
    print('  Number of Nights: ${patient.nights}');
    print('  Total Price: \$${totalPrice.toStringAsFixed(2)}');
    print('  Available beds in room: ${availableBeds - 1}/${room.beds.length}');
  }

  // Transfer patient between rooms
  Future<void> transferPatient({required String patientName, required int currentRoomNum, required String currentBedNum, required int newRoomNum, required String newBedNum, required String transferReason}) async {
    // Find patient
    final patient = _patientService.findPatientByName(patientName);
    if (patient == null) {
      throw StateError('Patient "$patientName" not found');
    }

    // Find current admission record
    final currentAdmission = _getCurrentActiveAdmission(patientName);
    if (currentAdmission == null) {
      throw StateError('No active admission found for "$patientName"');
    }

    // Validate the current room/bed matches admission
    if (currentAdmission.roomNumber != currentRoomNum || currentAdmission.bedNumber != currentBedNum) {
      throw StateError('Patient "$patientName" is not in Room $currentRoomNum, Bed $currentBedNum. '
          'Current location: Room ${currentAdmission.roomNumber}, Bed ${currentAdmission.bedNumber}');
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

    // Update bed statuses
    currentBed.setStatus = BedStatus.available;
    newBed.setStatus = BedStatus.occupied;

    // Update room availability
    currentRoom.isAvailable = true;
    if (newRoom.beds.every((b) => b.getStatus != BedStatus.available)) {
      newRoom.isAvailable = false;
    }

    // Calculate new total price for the new room
    double newTotalPrice = newRoom.calculateTotalCost(patient.nights!);

    // Create discharge record for old admission
    final transferDischarge = Discharge(
      admission: currentAdmission,  // Pass the entire admission object
      dischargeDate: DateTime.now(),
      dischargeReason: 'Transferred to Room $newRoomNum',
      nightsStayed: DateTime.now().difference(currentAdmission.admissionDate).inDays,
    );

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

    _admissions.removeWhere((a) => a.id == currentAdmission.id);
    _admissions.add(newAdmission);
    _discharges.add(transferDischarge);

    // Save changes
    await _saveAdmissions();
    await _saveDischarges();
    await _roomService.saveRooms();

    print('\nPatient $patientName transferred successfully!');
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

    //Find active admission
    final admission = _getCurrentActiveAdmission(patientName);
    if (admission == null) {
      throw StateError('No active admission found for "$patientName"');
    }

    // Find the room and bed
    final room = _roomService.findRoomByNumber(admission.roomNumber)!;
    final bed = room.beds.firstWhere((b) => b.bedNumber == admission.bedNumber);

    // Calculate actual nights stayed and final price
    final dischargeDate = DateTime.now();
    final nightsStayed = dischargeDate.difference(admission.admissionDate).inDays;
    final actualNights = nightsStayed > 0 ? nightsStayed : 1;
    final finalPrice = room.calculateTotalCost(actualNights);

    // Update the admission's total price with final calculated price
    admission.totalPrice = finalPrice;

    // Create discharge record with embedded admission
    final discharge = Discharge(
      admission: admission,  // Pass the entire admission object
      dischargeDate: dischargeDate,
      dischargeReason: dischargeReason,
      nightsStayed: actualNights,
    );

    // Update bed status to available
    bed.setStatus = BedStatus.available;
    room.isAvailable = true;

    _admissions.removeWhere((a) => a.id == admission.id);
    _discharges.add(discharge);

    // Save changes
    await _saveAdmissions();
    await _saveDischarges();
    await _roomService.saveRooms();

    print('\nPatient $patientName discharged successfully!');
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

  //Only check active admissions (no dischargeDate)
  bool _isPatientCurrentlyAdmitted(String patientName) {
    return _admissions.any((a) => 
        a.patient.toLowerCase() == patientName.toLowerCase() && 
        a.dischargeDate == null);
  }

  //Get active admission only
  Admission? _getCurrentActiveAdmission(String patientName) {
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