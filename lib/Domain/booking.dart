import 'patient.dart';
import 'room.dart';
import 'bookingHistory.dart';

class Booking {
  int bookingId;
  Patient patient;
  RoomType roomType;
  DateTime startDate;
  int nights;
  double pricePerNight;
  List<BookingHistory> history;

  Booking({
    required this.bookingId,
    required this.patient,
    required this.roomType,
    required this.startDate,
    required this.nights,
    required this.pricePerNight,
    List<BookingHistory>? history,
  }) : history = history ?? [];

  double getTotalCost() {
    double currentCost = nights * pricePerNight;
    double historyCost = history.fold(0.0, (sum, h) => sum + h.getCost());
    return currentCost + historyCost;
  }
}
