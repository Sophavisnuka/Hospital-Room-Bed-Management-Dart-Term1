# Hospital Room & Bed Management System

## Project Overview
A Dart-based hospital management system focused on room and bed allocation, designed specifically for Cambodian hospitals. This system allows staff to manage patient admissions, room assignments, transfers, and billing based on different room types and sharing arrangements.

## System Requirements
- Staff-operated system (patients do not directly interact)
- Support for various room types with different pricing
- Room/bed availability tracking
- Patient admission and discharge workflows
- Room transfer handling with price adjustments
- Billing based on room type, duration, and sharing status
- Support for Cambodian hospital context

## Domain Layer Structure

### Person (Abstract Base Class)
- **Attributes**: name, age, gender, phone, dateOfBirth
- **Methods**: toString()

### Patient
- **Extends**: Person
- **Attributes**: id, reason, nights, booking, admissionDate
- **Methods**: extendStay()

### Staff
- **Extends**: Person
- **Attributes**: id, workShift, position
- **Methods**: toString()

### Room
- **Attributes**: roomNumber, type, beds, floor
- **Methods**: hasAvailableBed(), getAvailableBed(), addBed(), removeBed(), getOccupancyStatus()

### Bed
- **Attributes**: bedNumber, patient, isClean
- **Methods**: isOccupied(), assignPatient(), release(), markForCleaning(), markAsClean()

### Booking
- **Attributes**: bookingId, patient, roomType, startDate, nights, pricePerNight, history, status
- **Methods**: getTotalCost(), extendStay(), changeRoom(), isActive()

### BookingHistory
- **Attributes**: roomType, nights, pricePerNight, startDate, endDate, isShared
- **Methods**: getCost()

### Hospital (Management Class)
- **Attributes**: rooms, patients, bookings, nextBookingId
- **Methods**: addRoom(), addPatientBooking(), movePatient(), releasePatient(), checkAvailability(), calculateBill(), saveData(), loadData()

### Enums
- **RoomType**: normal, normal_semi, vip_shared, vip_private, vip_single
- **WorkShift**: morning, afternoon, evening, night
- **BookingStatus**: reserved, active, completed, cancelled
- **RoomStatus**: available, partiallyOccupied, fullyOccupied, maintenance, cleaning

## System Functionalities

### 1. Booking Management
- Create new booking
- View all active bookings
- Search for specific booking
- Modify booking (extend stay, upgrade room)
- Process checkout and calculate bill
- Cancel booking

### 2. Room & Bed Management
- View all rooms with status
- Check room availability by type
- Assign beds to patients
- Mark rooms for maintenance/cleaning
- Transfer patients between rooms/beds

### 3. Patient Management
- Register new patients
- Search for patients in system
- Track patient location in hospital
- View patient history and bookings

### 4. Staff Management
- View staff on duty by shift
- Assign staff to handle patient admissions

### 5. Billing & Financial
- Calculate bills based on room type, duration, sharing status
- Handle different pricing scenarios (room changes, upgrades)
- Generate itemized invoices

## Implementation Guidelines

1. **Layered Architecture**
   - Domain: Business entities and logic
   - Data: Persistence layer for saving/loading data
   - UI: Console interface for interaction

2. **OOP Principles**
   - Encapsulation: Private fields with getters
   - Inheritance: Person base class
   - Polymorphism: Method overrides

3. **Special Cambodian Hospital Considerations**
   - Family accommodation tracking
   - Cash payment handling
   - Room sharing customs

4. **Data Persistence**
   - File-based storage (JSON format)
   - Regular auto-save functionality

## Console UI Navigation Flow
1. Main Menu
2. Booking Management Submenu
3. Room Management Submenu
4. Patient Management Submenu
5. Staff Management Submenu
6. Reporting & Data Submenu

## User Stories
- As a staff member, I can check available rooms to assign a new patient
- As a staff member, I can move a patient to a different room when requested
- As a staff member, I can calculate a patient's bill upon discharge
- As a staff member, I can view occupancy reports for the hospital