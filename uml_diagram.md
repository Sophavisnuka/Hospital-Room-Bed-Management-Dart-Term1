# 🏥 Hospital Room Booking & Management System  
### *Final Dart OOP Project (Cambodian Hospital Context)*  

---

## 🧩 UML Class Diagram (Mermaid)

```mermaid
classDiagram
    class Person {
        - String name
        - int age
        + displayInfo()
    }

    class Patient {
        - int id
        - String reason
        - int nights
        - Booking booking
        + displayInfo()
    }

    class Booking {
        - int bookingId
        - Patient patient
        - RoomType roomType
        - DateTime startDate
        - int nights
        - double pricePerNight
        - List~BookingHistory~ history
        + getTotalCost() double
    }

    class BookingHistory {
        - RoomType roomType
        - int nights
        - double pricePerNight
        + getCost() double
    }

    class Bed {
        - int bedNumber
        - Patient patient
        + isOccupied() bool
        + assignPatient(Patient)
        + release()
    }

    class Room {
        - int roomNumber
        - RoomType type
        - List~Bed~ beds
        + hasAvailableBed() bool
        + getAvailableBed() Bed
        + addBed()
        + removeBed(bedNumber)
        + showStatus()
    }

    class Hospital {
        - List~Room~ rooms
        - List~Patient~ patients
        - List~Booking~ bookings
        + addRoom(roomNumber, type, bedCount)
        + addPatientBooking(patientInfo)
        + movePatient(patientId, newRoomNumber)
        + releasePatient(patientId)
        + checkAvailability(roomType)
        + calculateBill(patientId)
        + saveData()
        + loadData()
    }

    enum RoomType {
        normal
        vip_shared
        vip_private
        vip_single
    }

    Person <|-- Patient
    Hospital --> Room
    Room --> Bed
    Bed --> Patient
    Patient --> Booking
    Booking --> BookingHistory
    Booking --> RoomType
    Room --> RoomType
