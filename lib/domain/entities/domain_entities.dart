enum ReservationStatus { pending, active, completed, cancelled }

class Profile {
  final String id;
  final String name;
  final String email;
  final String? phone;

  const Profile({required this.id, required this.name, required this.email, this.phone});
}

class Vehicle {
  final String id;
  final String profileId;
  final String plate;
  final String color;
  final String type;

  const Vehicle({required this.id, required this.profileId, required this.plate, required this.color, required this.type});
}

class ParkingLot {
  final String id;
  final String ownerId;
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  const ParkingLot({required this.id, required this.ownerId, required this.name, required this.address, required this.latitude, required this.longitude});
}

class Space {
  final String id;
  final String parkingLotId;
  final String type;
  final double pricePerHour;

  const Space({required this.id, required this.parkingLotId, required this.type, required this.pricePerHour});
}

class Schedule {
  final String id;
  final String parkingLotId;
  final int dayOfWeek;
  final String openTime;
  final String closeTime;

  const Schedule({required this.id, required this.parkingLotId, required this.dayOfWeek, required this.openTime, required this.closeTime});
}

class Reservation {
  final String id;
  final String spaceId;
  final String vehicleId;
  final DateTime startTime;
  final DateTime endTime;
  final double totalAmount;
  final ReservationStatus status;

  const Reservation({required this.id, required this.spaceId, required this.vehicleId, required this.startTime, required this.endTime, required this.totalAmount, required this.status});
}
