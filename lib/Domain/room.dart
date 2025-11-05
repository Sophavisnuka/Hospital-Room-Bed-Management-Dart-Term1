import 'package:uuid/uuid.dart';
import 'package:my_first_project/Domain/bed.dart';
import 'package:my_first_project/Domain/standardRoom.dart';
import 'package:my_first_project/Domain/vipRoom.dart';

enum RoomType {
  normal,
  vip,
}

const uuid = Uuid();

abstract class Room {
  final String id;
  final int roomNumber;
  final List<Bed> beds;
  final RoomType roomType;
  double _basePrice;
  bool isAvailable;

  Room({
    String? id,
    required double basePrice,
    required this.roomNumber,
    required this.beds,
    required this.roomType,
    this.isAvailable = true,
  })  : id = id ?? uuid.v4(),
        _basePrice = basePrice {
    // Validate in constructor
    if (roomNumber <= 0) {
      throw ArgumentError("Room number must be positive.");
    }
    if (basePrice < 0) {
      throw ArgumentError("Room price cannot be negative.");
    }
  }

  // Encapsulated access to basePrice
  double get basePrice => _basePrice;
  
  set price(double newPrice) {
    if (newPrice < 0) {
      throw ArgumentError("Room price cannot be negative.");
    }
    _basePrice = newPrice;
  }
  
  double get price => _basePrice;

  // Abstract methods for polymorphism
  double calculateTotalCost(int nights);
  List<String> getRoomFeatures();
  double getServiceCharge();
  bool canAccommodateSpecialNeeds();

  // Common methods
  // bool isAvailableBed(Bed bed) {
  //   return bed.getStatus == BedStatus.available;
  // }

  // // Get available bed count
  int getAvailableBedCount() {
    return beds.where((bed) => bed.getStatus == BedStatus.available).length;
  }

  // // Get occupied bed count
  // int getOccupiedBedCount() {
  //   return beds.where((bed) => bed.getStatus == BedStatus.occupied).length;
  // }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'roomNumber': roomNumber,
      'roomType': roomType.toString().split('.').last,
      'basePrice': _basePrice,
      'bed quantity': beds.length,
      'beds': beds.map((bed) => bed.toMap()).toList(),
      'isAvailable': isAvailable,
    };
  }

  factory Room.fromMap(Map<String, dynamic> map) {
    final type = RoomType.values.firstWhere(
      (e) => e.toString().split('.').last == map['roomType']
    );
    switch (type) {
      case RoomType.normal:
        return StandardRoom.fromMap(map);
      case RoomType.vip:
        return VIPRoom.fromMap(map);
    }
  }

  @override
  String toString() {
    return '''
Room ${roomNumber} (${roomType.toString().split('.').last.toUpperCase()})
Base Price: \$${_basePrice.toStringAsFixed(2)}
Beds: ${beds.length}
Available: ${isAvailable ? 'Yes' : 'No'}
Features: ${getRoomFeatures().join(', ')}
''';
  }
}
