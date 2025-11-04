import 'package:my_first_project/Domain/room.dart';
import 'package:my_first_project/Domain/bed.dart';
import 'package:my_first_project/Data/hospital_repository.dart';

class RoomService {
  final HospitalRepository _repository;
  final List<Room> _rooms = [];

  RoomService(this._repository);

  // Encapsulated access - return immutable copy
  List<Room> get rooms => List.unmodifiable(_rooms);

  // Load rooms from storage
  Future<void> loadRooms() async {
    try {
      final loadedRooms = await _repository.loadData(
          'room_data.json', (map) => Room.fromMap(map));
      _rooms.clear();
      _rooms.addAll(loadedRooms);
      _sortRooms();
    } catch (e) {
      print('Error loading rooms: $e');
    }
  }

  // Add a new room with validation
  Future<void> addRoom(Room room) async {
    // Check if room number already exists
    if (_rooms.any((r) => r.roomNumber == room.roomNumber)) {
      throw StateError('Room number ${room.roomNumber} already exists');
    }

    // Validate room data
    _validateRoom(room);

    _rooms.add(room);
    _sortRooms();
    await saveRooms();
    print("Room ${room.roomNumber} added successfully!");
  }

  // Edit room bed status
  Future<String> editRoomStatus(int roomNumber, String bedNumber, BedStatus status) async {
    final room = _findRoomByNumber(roomNumber);
    final bed = _findBedInRoom(room, bedNumber);
    
    String oldStatus = bed.getStatus.toString().split('.').last;
    bed.setStatus = status;
    
    // Update room availability based on bed statuses
    _updateRoomAvailability(room);
    
    await saveRooms();
    print('Bed $bedNumber status updated from $oldStatus to ${status.toString().split('.').last}');
    return oldStatus;
  }

  // Edit room price
  Future<double> editRoomPrice(int roomNumber, double newPrice) async {
    if (newPrice < 0) {
      throw ArgumentError('Room price cannot be negative');
    }

    final room = _findRoomByNumber(roomNumber);
    double oldPrice = room.price;
    
    room.price = newPrice;
    await saveRooms();
    
    print('Room $roomNumber price updated from \$${oldPrice.toStringAsFixed(2)} to \$${newPrice.toStringAsFixed(2)}');
    return oldPrice;
  }

  // Delete a room
  Future<void> deleteRoom(int roomNumber) async {
    final room = _findRoomByNumber(roomNumber);
    
    // Check if room has any occupied beds
    if (room.beds.any((bed) => bed.getStatus == BedStatus.occupied)) {
      throw StateError('Cannot delete room $roomNumber: has occupied beds');
    }

    _rooms.removeWhere((r) => r.roomNumber == roomNumber);
    await saveRooms();
    print('Room $roomNumber deleted successfully.');
  }

  // Delete a bed from room
  Future<void> deleteBedFromRoom(int roomNumber, String bedNumber) async {
    final room = _findRoomByNumber(roomNumber);
    final bed = _findBedInRoom(room, bedNumber);
    
    // Check if bed is occupied
    if (bed.getStatus == BedStatus.occupied) {
      throw StateError('Cannot delete bed $bedNumber: bed is occupied');
    }

    room.beds.removeWhere((b) => b.bedNumber == bedNumber);
    
    // Update room availability
    _updateRoomAvailability(room);
    
    await saveRooms();
    print('Bed $bedNumber deleted from Room $roomNumber successfully.');
  }

  // Get available rooms
  List<Room> getAvailableRooms() {
    return _rooms.where((room) => room.isAvailable).toList();
  }

  // Get rooms by type
  List<Room> getRoomsByType(RoomType type) {
    return _rooms.where((room) => room.roomType == type).toList();
  }

  // Get available beds in a specific room
  List<Bed> getAvailableBedsInRoom(int roomNumber) {
    final room = _findRoomByNumber(roomNumber);
    return room.beds.where((bed) => bed.getStatus == BedStatus.available).toList();
  }

  // Find room by number
  Room? findRoomByNumber(int roomNumber) {
    try {
      return _rooms.firstWhere((r) => r.roomNumber == roomNumber);
    } catch (e) {
      return null;
    }
  }

  // Check room availability
  bool isRoomAvailable(int roomNumber) {
    final room = findRoomByNumber(roomNumber);
    return room?.isAvailable ?? false;
  }

  // Get room capacity
  int getRoomCapacity(int roomNumber) {
    final room = _findRoomByNumber(roomNumber);
    return room.beds.length;
  }

  // Get occupied bed count in room
  int getOccupiedBedCount(int roomNumber) {
    final room = _findRoomByNumber(roomNumber);
    return room.beds.where((bed) => bed.getStatus == BedStatus.occupied).length;
  }

  // Get room occupancy rate
  double getRoomOccupancyRate(int roomNumber) {
    final room = _findRoomByNumber(roomNumber);
    if (room.beds.isEmpty) return 0.0;
    
    int occupiedBeds = room.beds.where((bed) => bed.getStatus == BedStatus.occupied).length;
    return occupiedBeds / room.beds.length;
  }

  // Get total room count
  int get roomCount => _rooms.length;

  // Get total bed count
  int get totalBedCount => _rooms.fold(0, (sum, room) => sum + room.beds.length);

  // View all rooms with formatting
  void viewAllRooms() {
    if (_rooms.isEmpty) {
      print("No rooms found.");
      return;
    }

    print("\n=======================================================");
    print("                    ALL ROOMS");
    print("=======================================================");
    
    for (var room in _rooms) {
      print("\nRoom Number: ${room.roomNumber}");
      print("Room Type: ${_capitalize(room.roomType.toString().split('.').last)}");
      print("Base Price: \$${room.basePrice.toStringAsFixed(2)}");
      print("Is Available: ${room.isAvailable ? 'Yes' : 'No'}");
      print("Beds (${room.beds.length}):");
      
      for (var bed in room.beds) {
        String statusName = _capitalize(bed.getStatus.toString().split('.').last);
        print("  - Bed Number: ${bed.bedNumber}, Status: $statusName");
      }
      print("-------------------------------------------------------");
    }
  }

  // Private helper methods
  Room _findRoomByNumber(int roomNumber) {
    try {
      return _rooms.firstWhere((r) => r.roomNumber == roomNumber);
    } catch (e) {
      throw StateError('Room $roomNumber not found');
    }
  }

  Bed _findBedInRoom(Room room, String bedNumber) {
    try {
      return room.beds.firstWhere((b) => b.bedNumber == bedNumber);
    } catch (e) {
      throw StateError('Bed $bedNumber not found in room ${room.roomNumber}');
    }
  }

  void _updateRoomAvailability(Room room) {
    final availableBeds = room.beds.where((b) => b.getStatus == BedStatus.available).length;
    room.isAvailable = availableBeds > 0;
  }

  void _sortRooms() {
    _rooms.sort((a, b) => a.roomNumber.compareTo(b.roomNumber));
  }

  void _validateRoom(Room room) {
    if (room.roomNumber <= 0) {
      throw ArgumentError('Room number must be positive');
    }
    if (room.basePrice < 0) {
      throw ArgumentError('Room price cannot be negative');
    }
    if (room.beds.isEmpty) {
      throw ArgumentError('Room must have at least one bed');
    }
    
    // Validate bed numbers are unique within the room
    final bedNumbers = room.beds.map((b) => b.bedNumber).toSet();
    if (bedNumbers.length != room.beds.length) {
      throw ArgumentError('Room contains duplicate bed numbers');
    }
  }

  Future<void> saveRooms() async {
    try {
      await _repository.saveData('room_data.json', _rooms, (r) => r.toMap());
    } catch (e) {
      print('Error saving rooms: $e');
      throw StateError('Failed to save room data');
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}