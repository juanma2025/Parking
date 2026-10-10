import '../entities/domain_entities.dart';

abstract class ProfileRepository {
  Future<Profile> getProfile(String id);
  Future<void> updateProfile(Profile profile);
}

abstract class VehicleRepository {
  Future<List<Vehicle>> getVehiclesByUserId(String userId);
  Future<Vehicle> getVehicle(String id);
  Future<void> addVehicle(Vehicle vehicle);
  Future<void> updateVehicle(Vehicle vehicle);
  Future<void> deleteVehicle(String id);
}

abstract class ParkingLotRepository {
  Future<List<ParkingLot>> getParkingLots();
  Future<List<ParkingLot>> getParkingLotsByOwnerId(String ownerId);
  Future<ParkingLot> getParkingLotDetails(String id);
  Future<void> createParkingLot(ParkingLot parkingLot);
  Future<void> updateParkingLot(ParkingLot parkingLot);
}

abstract class ParkingSpaceRepository {
  Future<List<ParkingSpace>> getSpacesByParkingLotId(String parkingLotId);
  Future<void> createSpace(ParkingSpace space);
  Future<void> updateSpace(ParkingSpace space);
  Future<void> deleteSpace(String id);
}

abstract class ParkingScheduleRepository {
  Future<List<ParkingSchedule>> getSchedulesByParkingLotId(String parkingLotId);
  Future<void> saveSchedule(ParkingSchedule schedule);
}

abstract class ReservationRepository {
  Future<List<Reservation>> getReservationsByUserId(String userId);
  Future<List<Reservation>> getReservationsByParkingLotId(String parkingLotId);
  Future<Reservation> getReservation(String id);
  Future<void> createReservation(Reservation reservation);
  Future<void> updateReservationStatus(String id, ReservationStatus status);
}
