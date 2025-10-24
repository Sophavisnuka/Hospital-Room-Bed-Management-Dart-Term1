# Domain Layer Implementation - Classes with Attributes & Getters

## Summary of Implemented Classes

### 1. **Person** (Abstract Base Class)
**Attributes:**
- `_name`: String
- `_age`: int
- `_gender`: String
- `_phone`: String?
- `_dateOfBirth`: String?

**Getters:**
- `name`: String
- `age`: int
- `gender`: String
- `phone`: String?
- `dateOfBirth`: String?

---

### 2. **Patient** (extends Person)
**Attributes:**
- `_id`: String (auto-generated UUID)
- `_reason`: String?
- `_nights`: int?
- `_admissionDate`: DateTime?

**Getters:**
- `id`: String
- `reason`: String?
- `nights`: int?
- `admissionDate`: DateTime?

---

### 3. **Staff** (extends Person)
**Attributes:**
- `_id`: String (auto-generated UUID)
- `_workShift`: WorkShift (enum)
- `_position`: String

**Getters:**
- `id`: String
- `workShift`: WorkShift
- `position`: String

---

### 4. **Room**
**Attributes:**
- `_id`: String (auto-generated UUID)
- `_roomNumber`: int
- `_roomType`: RoomType (enum)
- `_floor`: int
- `_bedIds`: List<String>
- `_isActive`: bool

**Getters:**
- `id`: String
- `roomNumber`: int
- `roomType`: RoomType
- `floor`: int
- `bedIds`: List<String>
- `isActive`: bool

---

### 5. **Bed**
**Attributes:**
- `_id`: String (auto-generated UUID)
- `_bedNumber`: int
- `_roomId`: String
- `_patientId`: String?
- `_status`: BedStatus (enum)
- `_isClean`: bool

**Getters:**
- `id`: String
- `bedNumber`: int
- `roomId`: String
- `patientId`: String?
- `status`: BedStatus
- `isClean`: bool

---

### 6. **Admission**
**Attributes:**
- `_id`: String (auto-generated UUID)
- `_patient`: Patient
- `_roomId`: String
- `_bedId`: String
- `_staffId`: String
- `_admissionDate`: DateTime
- `_checkoutDate`: DateTime?
- `_status`: AdmissionStatus (enum)
- `_chargeItems`: List<ChargeItem>
- `_transferHistory`: List<TransferRecord>
- `_roomType`: RoomType
- `_isShared`: bool

**Getters:**
- `id`: String
- `patient`: Patient
- `roomId`: String
- `bedId`: String
- `staffId`: String
- `admissionDate`: DateTime
- `checkoutDate`: DateTime?
- `status`: AdmissionStatus
- `chargeItems`: List<ChargeItem>
- `transferHistory`: List<TransferRecord>
- `roomType`: RoomType
- `isShared`: bool

---

### 7. **ChargeItem**
**Attributes:**
- `_description`: String
- `_amount`: double
- `_chargeDate`: DateTime

**Getters:**
- `description`: String
- `amount`: double
- `chargeDate`: DateTime

---

### 8. **TransferRecord**
**Attributes:**
- `_fromRoomId`: String
- `_fromBedId`: String
- `_toRoomId`: String
- `_toBedId`: String
- `_transferTime`: DateTime
- `_reason`: String
- `_transferredByStaffId`: String

**Getters:**
- `fromRoomId`: String
- `fromBedId`: String
- `toRoomId`: String
- `toBedId`: String
- `transferTime`: DateTime
- `reason`: String
- `transferredByStaffId`: String

---

### 9. **Hospital** (Management Class)
**Attributes:**
- `_id`: String (auto-generated UUID)
- `_name`: String
- `_address`: String
- `_rooms`: List<Room>
- `_patients`: List<Patient>
- `_beds`: List<Bed>
- `_admissions`: List<Admission>
- `_staff`: List<Staff>
- `_nextAdmissionId`: int

**Getters:**
- `id`: String
- `name`: String
- `address`: String
- `rooms`: List<Room>
- `patients`: List<Patient>
- `beds`: List<Bed>
- `admissions`: List<Admission>
- `staff`: List<Staff>
- `nextAdmissionId`: int

---

## Enums

### **WorkShift**
- morning
- afternoon
- evening
- night

### **RoomType** (with extensions)
- normal (8-12 beds)
- normal_semi (4-6 beds)
- vip_shared (2-4 beds)
- vip_private (2 beds)
- vip_single (1 bed)

Extensions provide:
- `displayName`: String
- `basePricePerNight`: double
- `maxBeds`: int

### **AdmissionStatus**
- admitted
- transferred
- pending_discharge
- discharged

### **BedStatus**
- available
- occupied
- cleaning
- maintenance

---

## File Structure
```
lib/Domain/
├── person.dart              (Abstract base class)
├── patient.dart             (Patient entity)
├── staff.dart               (Staff entity)
├── room.dart                (Room entity)
├── bed.dart                 (Bed entity)
├── admission.dart           (Admission entity)
├── charge_item.dart         (ChargeItem entity)
├── transfer_record.dart     (TransferRecord entity)
├── room_type.dart           (RoomType enum with extensions)
├── bed_status.dart          (BedStatus enum)
└── hospital.dart            (Hospital management class)
```

---

## Key Design Decisions

1. **Encapsulation**: All attributes are private (`_`) with public getters
2. **UUID Generation**: All entities get auto-generated unique IDs
3. **No Methods Yet**: Implementation contains only attributes and getters
4. **Admission-Focused**: Admission is the central entity tracking patient stays
5. **Flexible Room Types**: Support for various room types with different pricing
6. **Transfer Tracking**: Complete history of patient movements with reasons
7. **Itemized Billing**: ChargeItem list allows detailed invoice generation

---

## Next Steps

Once these classes are tested and stable:
1. Implement methods for Hospital class (add rooms, admit patients, etc.)
2. Implement methods for Admission class (add charges, record transfers, etc.)
3. Create data persistence layer
4. Build UI layer with console interface
5. Implement comprehensive unit tests
