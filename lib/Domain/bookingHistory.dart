import 'room.dart';

class BookingHistory {
  RoomType roomType;
  int nights;
  double pricePerNight;

  BookingHistory({
    required this.roomType,
    required this.nights,
    required this.pricePerNight,
  });

  double getCost() {
    return nights * pricePerNight;
  }
}
