import '../entities/domain_entities.dart';
import '../repositories/domain_repositories.dart';

class GetProfileUseCase {
  final ProfileRepository repository;
  GetProfileUseCase(this.repository);

  Future<Profile> execute(String id) => repository.getProfile(id);
}

class GetVehiclesUseCase {
  final VehicleRepository repository;
  GetVehiclesUseCase(this.repository);

  Future<List<Vehicle>> execute(String profileId) {
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

class GetSpacesUseCase {
  final ParkingSpaceRepository repository;
  GetSpacesUseCase(this.repository);

  Future<List<ParkingSpace>> execute(String parkingLotId) {
    throw UnimplementedError();
  }
}

class GetSchedulesUseCase {
  final ParkingScheduleRepository repository;
  GetSchedulesUseCase(this.repository);

  Future<List<ParkingSchedule>> execute(String parkingLotId) {
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
