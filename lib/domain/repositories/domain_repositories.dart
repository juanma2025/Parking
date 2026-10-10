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

abstract class ReservationRepository {
  Future<List<Reservation>> getReservations(String profileId);
  Future<void> createReservation(Reservation reservation);
}
