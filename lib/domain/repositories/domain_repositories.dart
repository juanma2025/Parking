import '../entities/domain_entities.dart';

abstract class ProfileRepository {
  Future<Profile> getProfile(String id);
  Future<void> updateProfile(Profile profile);
}

abstract class VehicleRepository {
  Future<List<Vehicle>> getVehicles(String profileId);
  Future<void> addVehicle(Vehicle vehicle);
}

abstract class ParkingLotRepository {
  Future<List<ParkingLot>> getParkingLots();
  Future<ParkingLot> getParkingLotDetails(String id);
}

abstract class ParkingSpaceRepository {
  Future<List<ParkingSpace>> getSpaces(String parkingLotId);
  Future<void> addSpace(ParkingSpace space);
}

abstract class ParkingScheduleRepository {
  Future<List<ParkingSchedule>> getSchedules(String parkingLotId);
  Future<void> saveSchedule(ParkingSchedule schedule);
}

abstract class ReservationRepository {
  Future<List<Reservation>> getReservations(String profileId);
  Future<void> createReservation(Reservation reservation);
}
