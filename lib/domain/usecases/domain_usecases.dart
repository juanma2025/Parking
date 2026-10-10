import '../entities/domain_entities.dart';
import '../repositories/domain_repositories.dart';

class GetProfileUseCase {
  final ProfileRepository repository;
  GetProfileUseCase(this.repository);

  Future<Profile> execute(String id) {
    throw UnimplementedError();
  }
}

class GetVehiclesUseCase {
  final VehicleRepository repository;
  GetVehiclesUseCase(this.repository);

  Future<List<Vehicle>> execute(String userId) {
    throw UnimplementedError();
  }
}

class GetParkingLotsUseCase {
  final ParkingLotRepository repository;
  GetParkingLotsUseCase(this.repository);

  Future<List<ParkingLot>> execute() {
    throw UnimplementedError();
  }
}

class CreateReservationUseCase {
  final ReservationRepository repository;
  CreateReservationUseCase(this.repository);

  Future<void> execute(Reservation reservation) {
    throw UnimplementedError();
  }
}

class GetReservationsUseCase {
  final ReservationRepository repository;
  GetReservationsUseCase(this.repository);

  Future<List<Reservation>> execute(String userId) {
    throw UnimplementedError();
  }
}

class GetParkingLotDetailsUseCase {
  final ParkingLotRepository lotRepository;
  final ParkingSpaceRepository spaceRepository;
  final ParkingScheduleRepository scheduleRepository;

  GetParkingLotDetailsUseCase(this.lotRepository, this.spaceRepository, this.scheduleRepository);

  Future<Map<String, dynamic>> execute(String parkingLotId) {
    // This would fetch lot, spaces and schedules and return them combined
    throw UnimplementedError();
  }
}
