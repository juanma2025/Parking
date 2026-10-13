enum UserRole {
  vehicleOwner,
  parkingOwner,
  admin;

  static UserRole fromString(String? role) {
    switch (role) {
      case 'parking_owner':
        return UserRole.parkingOwner;
      case 'admin':
        return UserRole.admin;
      case 'vehicle_owner':
      default:
        return UserRole.vehicleOwner;
    }
  }

  String toDbValue() {
    switch (this) {
      case UserRole.parkingOwner:
        return 'parking_owner';
      case UserRole.admin:
        return 'admin';
      case UserRole.vehicleOwner:
        return 'vehicle_owner';
    }
  }
}

enum ParkingSpaceStatus {
  available,
  occupied,
  maintenance,
  inactive;

  static ParkingSpaceStatus fromString(String? status) {
    switch (status) {
      case 'occupied':
        return ParkingSpaceStatus.occupied;
      case 'maintenance':
        return ParkingSpaceStatus.maintenance;
      case 'inactive':
        return ParkingSpaceStatus.inactive;
      case 'available':
      default:
        return ParkingSpaceStatus.available;
    }
  }
}

enum ReservationStatus {
  pending,
  confirmed,
  active,
  completed,
  cancelled;

  static ReservationStatus fromString(String? status) {
    switch (status) {
      case 'confirmed':
        return ReservationStatus.confirmed;
      case 'active':
        return ReservationStatus.active;
      case 'completed':
        return ReservationStatus.completed;
      case 'cancelled':
        return ReservationStatus.cancelled;
      case 'pending':
      default:
        return ReservationStatus.pending;
    }
  }
}

enum PaymentStatus {
  pending,
  approved,
  rejected,
  refunded;

  static PaymentStatus fromString(String? status) {
    switch (status) {
      case 'approved':
        return PaymentStatus.approved;
      case 'rejected':
        return PaymentStatus.rejected;
      case 'refunded':
        return PaymentStatus.refunded;
      case 'pending':
      default:
        return PaymentStatus.pending;
    }
  }
}

class Profile {
  final String id;
  final String? fullName;
  final String? phone;
  final UserRole role;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Compatibility getter
  String get name => fullName ?? '';
  String get email => '';

  const Profile({
    required this.id,
    this.fullName,
    this.phone,
    this.role = UserRole.vehicleOwner,
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

  // Compatibility getter
  String get profileId => userId;
  String get type => vehicleType;

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
  final String status;
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
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
  });
}

class ParkingSpace {
  final String id;
  final String parkingLotId;
  final String spaceNumber;
  final String vehicleType;
  final ParkingSpaceStatus status;

  // Compatibility getter
  String get type => vehicleType;
  double get pricePerHour => 0.0;

  const ParkingSpace({
    required this.id,
    required this.parkingLotId,
    required this.spaceNumber,
    required this.vehicleType,
    this.status = ParkingSpaceStatus.available,
  });
}

typedef Space = ParkingSpace;

class ParkingSchedule {
  final String id;
  final String parkingLotId;
  final int dayOfWeek;
  final String openingTime;
  final String closingTime;
  final bool isOpen;

  // Compatibility getters
  String get openTime => openingTime;
  String get closeTime => closingTime;

  const ParkingSchedule({
    required this.id,
    required this.parkingLotId,
    required this.dayOfWeek,
    required this.openingTime,
    required this.closingTime,
    this.isOpen = true,
  });
}

typedef Schedule = ParkingSchedule;

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

  // Compatibility getters
  String get spaceId => parkingSpaceId;
  double get totalAmount => totalPrice;

  const Reservation({
    required this.id,
    required this.userId,
    required this.parkingLotId,
    required this.parkingSpaceId,
    required this.vehicleId,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.totalPrice,
    this.createdAt,
  });
}

class Payment {
  final String id;
  final String reservationId;
  final double amount;
  final String? paymentMethod;
  final String? transactionId;
  final PaymentStatus status;
  final DateTime? paidAt;

  const Payment({
    required this.id,
    required this.reservationId,
    required this.amount,
    this.paymentMethod,
    this.transactionId,
    this.status = PaymentStatus.pending,
    this.paidAt,
  });
}

class Review {
  final String id;
  final String userId;
  final String parkingLotId;
  final String reservationId;
  final int rating;
  final String? comment;
  final DateTime? createdAt;

  const Review({
    required this.id,
    required this.userId,
    required this.parkingLotId,
    required this.reservationId,
    required this.rating,
    this.comment,
    this.createdAt,
  });
}

class Favorite {
  final String id;
  final String userId;
  final String parkingLotId;
  final DateTime? createdAt;

  const Favorite({
    required this.id,
    required this.userId,
    required this.parkingLotId,
    this.createdAt,
  });
}

class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String? type;
  final bool isRead;
  final DateTime? createdAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    this.type,
    this.isRead = false,
    this.createdAt,
  });
}

class AiConversation {
  final String id;
  final String userId;
  final String? title;
  final DateTime? createdAt;

  const AiConversation({
    required this.id,
    required this.userId,
    this.title,
    this.createdAt,
  });
}

class AiMessage {
  final String id;
  final String conversationId;
  final String sender;
  final String message;
  final DateTime? createdAt;

  const AiMessage({
    required this.id,
    required this.conversationId,
    required this.sender,
    required this.message,
    this.createdAt,
  });
}
