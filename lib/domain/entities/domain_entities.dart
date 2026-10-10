// ignore_for_file: public_member_api_docs, sort_constructors_first

enum UserRole { vehicleOwner, parkingOwner, admin }

enum ParkingLotStatus { active, inactive, maintenance }

enum ParkingSpaceStatus { available, occupied, maintenance, inactive }

enum ReservationStatus { pending, confirmed, active, completed, cancelled }

enum PaymentStatus { pending, approved, rejected, refunded }

class Profile {
  final String id;
  final String? fullName;
  final String? phone;
  final UserRole role;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Profile({
    required this.id,
    this.fullName,
    this.phone,
    required this.role,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
  });
}

class Vehicle {
  final String id;
  final String userId;
  final String plate;
  final String vehicleType;
  final String? brand;
  final String? model;
  final String? color;
  final DateTime? createdAt;

  const Vehicle({
    required this.id,
    required this.userId,
    required this.plate,
    required this.vehicleType,
    this.brand,
    this.model,
    this.color,
    this.createdAt,
  });
}

class ParkingLot {
  final String id;
  final String ownerId;
  final String name;
  final String? description;
  final String address;
  final double latitude;
  final double longitude;
  final double pricePerHour;
  final String? openingTime;
  final String? closingTime;
  final ParkingLotStatus? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ParkingLot({
    required this.id,
    required this.ownerId,
    required this.name,
    this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.pricePerHour,
    this.openingTime,
    this.closingTime,
    this.status,
    this.createdAt,
    this.updatedAt,
  });
}

class ParkingSpace {
  final String id;
  final String parkingLotId;
  final String spaceNumber;
  final String? vehicleType;
  final ParkingSpaceStatus status;

  const ParkingSpace({
    required this.id,
    required this.parkingLotId,
    required this.spaceNumber,
    this.vehicleType,
    this.status = ParkingSpaceStatus.available,
  });
}

class ParkingSchedule {
  final String id;
  final String parkingLotId;
  final int? dayOfWeek; // 0-6
  final String? openingTime;
  final String? closingTime;
  final bool isOpen;

  const ParkingSchedule({
    required this.id,
    required this.parkingLotId,
    this.dayOfWeek,
    this.openingTime,
    this.closingTime,
    this.isOpen = true,
  });
}

class Reservation {
  final String id;
  final String userId;
  final String parkingLotId;
  final String parkingSpaceId;
  final String vehicleId;
  final DateTime startTime;
  final DateTime endTime;
  final ReservationStatus status;
  final double totalPrice;
  final DateTime? createdAt;

  const Reservation({
    required this.id,
    required this.userId,
    required this.parkingLotId,
    required this.parkingSpaceId,
    required this.vehicleId,
    required this.startTime,
    required this.endTime,
    this.status = ReservationStatus.pending,
    required this.totalPrice,
    this.createdAt,
  });
}
