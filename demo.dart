import 'lib/Domain/hospital.dart';
import 'lib/Domain/room.dart';

void main() {
  print('=== Hospital Management System Demo ===\n');
  
  // Create hospital
  Hospital hospital = Hospital();
  print('✓ Created hospital');
  
  // Add rooms
  hospital.addRoom(101, RoomType.normal, 3);
  hospital.addRoom(102, RoomType.normal, 2);
  hospital.addRoom(201, RoomType.vip_private, 1);
  hospital.addRoom(202, RoomType.vip_single, 1);
  print('✓ Added 4 rooms\n');
  
  // Check availability
  print('Available beds:');
  print('  Normal: ${hospital.checkAvailability(RoomType.normal)}');
  print('  VIP Private: ${hospital.checkAvailability(RoomType.vip_private)}');
  print('  VIP Single: ${hospital.checkAvailability(RoomType.vip_single)}\n');
  
  // Add patient booking
  hospital.addPatientBooking({
    'id': 1,
    'name': 'Sophea Chan',
    'age': 35,
    'reason': 'Surgery',
    'nights': 5,
    'roomType': RoomType.normal,
  });
  print('✓ Added patient: Sophea Chan (ID: 1)');
  
  hospital.addPatientBooking({
    'id': 2,
    'name': 'Dara Sok',
    'age': 28,
    'reason': 'Recovery',
    'nights': 3,
    'roomType': RoomType.vip_private,
  });
  print('✓ Added patient: Dara Sok (ID: 2)\n');
  
  // Check availability after booking
  print('Available beds after booking:');
  print('  Normal: ${hospital.checkAvailability(RoomType.normal)}');
  print('  VIP Private: ${hospital.checkAvailability(RoomType.vip_private)}\n');
  
  // Calculate bills
  double bill1 = hospital.calculateBill(1);
  print('Bill for Sophea Chan: \$${bill1.toStringAsFixed(2)}');
  
  double bill2 = hospital.calculateBill(2);
  print('Bill for Dara Sok: \$${bill2.toStringAsFixed(2)}\n');
  
  // Move patient
  print('Moving Sophea Chan to VIP Single room...');
  hospital.addRoom(203, RoomType.vip_single, 2);
  hospital.movePatient(1, 203);
  print('✓ Patient moved successfully');
  
  double newBill1 = hospital.calculateBill(1);
  print('New bill for Sophea Chan: \$${newBill1.toStringAsFixed(2)}\n');
  
  // Show room status
  print('Room statuses:');
  for (var room in hospital.rooms) {
    room.showStatus();
  }
  print('');
  
  // Release patient
  print('Releasing Dara Sok...');
  hospital.releasePatient(2);
  print('✓ Patient released');
  print('Remaining patients: ${hospital.patients.length}\n');
  
  // Save data
  print('Saving hospital data...');
  hospital.saveData();
  
  // Create new hospital and load data
  print('\nCreating new hospital instance and loading data...');
  Hospital newHospital = Hospital();
  newHospital.loadData();
  print('Loaded rooms: ${newHospital.rooms.length}');
  print('Loaded patients: ${newHospital.patients.length}');
  print('Loaded bookings: ${newHospital.bookings.length}\n');
  
  print('=== Demo Complete ===');
}
