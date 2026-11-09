import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/pasto_landmarks_data.dart';
import '../../domain/entities/domain_entities.dart';

class OwnerParkingConfig {
  final String id;
  final String name;
  final String address;
  final String openTime;
  final String closeTime;
  final int carSpaces;
  final int motoSpaces;
  final double carHourlyRate;
  final double motoHourlyRate;
  final double latitude;
  final double longitude;

  const OwnerParkingConfig({
    required this.id,
    required this.name,
    required this.address,
    this.openTime = '06:00 AM',
    this.closeTime = '10:00 PM',
    required this.carSpaces,
    required this.motoSpaces,
    this.carHourlyRate = 2800.0,
    this.motoHourlyRate = 1400.0,
    required this.latitude,
    required this.longitude,
  });

  int get totalSpaces => carSpaces + motoSpaces;
  String get openingHours => '$openTime - $closeTime';

  OwnerParkingConfig copyWith({
    String? id,
    String? name,
    String? address,
    String? openTime,
    String? closeTime,
    int? carSpaces,
    int? motoSpaces,
    double? carHourlyRate,
    double? motoHourlyRate,
    double? latitude,
    double? longitude,
  }) {
    return OwnerParkingConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      carSpaces: carSpaces ?? this.carSpaces,
      motoSpaces: motoSpaces ?? this.motoSpaces,
      carHourlyRate: carHourlyRate ?? this.carHourlyRate,
      motoHourlyRate: motoHourlyRate ?? this.motoHourlyRate,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

class OwnerParkingConfigNotifier extends Notifier<OwnerParkingConfig> {
  @override
  OwnerParkingConfig build() {
    return const OwnerParkingConfig(
      id: 'owner-parking-pasto',
      name: 'Mi Parqueadero Pasto',
      address: 'Centro, San Juan de Pasto',
      openTime: '06:00 AM',
      closeTime: '10:00 PM',
      carSpaces: 4,
      motoSpaces: 2,
      carHourlyRate: 2800.0,
      motoHourlyRate: 1400.0,
      latitude: 1.2158,
      longitude: -77.2792,
    );
  }

  void configureParkingLot({
    required String name,
    required String address,
    required String openTime,
    required String closeTime,
    required int carSpaces,
    required int motoSpaces,
    double? carHourlyRate,
    double? motoHourlyRate,
  }) {
    final coords = PastoDataService.inferCoordinatesForAddress(name, address);
    final updated = state.copyWith(
      id: 'custom-pasto-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      address: address.trim(),
      openTime: openTime.trim(),
      closeTime: closeTime.trim(),
      carSpaces: carSpaces,
      motoSpaces: motoSpaces,
      carHourlyRate: carHourlyRate ?? state.carHourlyRate,
      motoHourlyRate: motoHourlyRate ?? state.motoHourlyRate,
      latitude: coords.lat,
      longitude: coords.lng,
    );
    state = updated;

    // Generar dinámicamente la cantidad exacta de espacios todos libres
    ref.read(parkingSpacesProvider.notifier).configureSpaces(
          carSpaces: carSpaces,
          motoSpaces: motoSpaces,
          carRate: updated.carHourlyRate,
          motoRate: updated.motoHourlyRate,
        );

    // Registrar en el catálogo global para que aparezca de inmediato en Mapa y Sugerencias del Conductor
    PastoDataService.registerCustomParkingLot(
      PastoParkingLot(
        id: updated.id,
        name: updated.name,
        address: updated.address,
        latitude: updated.latitude,
        longitude: updated.longitude,
        pricePerHour: updated.carHourlyRate,
        carSpaces: updated.carSpaces,
        motoSpaces: updated.motoSpaces,
        distanceMeters: 50,
        rating: 5.0,
        openingHours: updated.openingHours,
        isCovered: true,
        hasSecurity: true,
        hasCharging: false,
        landmarkId: 'novacentro',
      ),
    );
  }

  void updateDetails({
    required String name,
    required String address,
    double? carHourlyRate,
    double? motoHourlyRate,
    int? carSpaces,
    int? motoSpaces,
  }) {
    final newCars = carSpaces ?? state.carSpaces;
    final newMotos = motoSpaces ?? state.motoSpaces;
    final newCarRate = carHourlyRate ?? state.carHourlyRate;
    final newMotoRate = motoHourlyRate ?? state.motoHourlyRate;
    final coords = PastoDataService.inferCoordinatesForAddress(name, address);

    final updated = state.copyWith(
      name: name.trim(),
      address: address.trim(),
      carSpaces: newCars,
      motoSpaces: newMotos,
      carHourlyRate: newCarRate,
      motoHourlyRate: newMotoRate,
      latitude: coords.lat,
      longitude: coords.lng,
    );
    state = updated;

    if (carSpaces != null || motoSpaces != null) {
      ref.read(parkingSpacesProvider.notifier).configureSpaces(
            carSpaces: newCars,
            motoSpaces: newMotos,
            carRate: newCarRate,
            motoRate: newMotoRate,
          );
    } else if (carHourlyRate != null || motoHourlyRate != null) {
      ref.read(parkingSpacesProvider.notifier).updateRates(
            carRate: newCarRate,
            motoRate: newMotoRate,
          );
    }

    PastoDataService.registerCustomParkingLot(
      PastoParkingLot(
        id: updated.id,
        name: updated.name,
        address: updated.address,
        latitude: updated.latitude,
        longitude: updated.longitude,
        pricePerHour: updated.carHourlyRate,
        carSpaces: updated.carSpaces,
        motoSpaces: updated.motoSpaces,
        distanceMeters: 50,
        rating: 5.0,
        openingHours: updated.openingHours,
        isCovered: true,
        hasSecurity: true,
        hasCharging: false,
        landmarkId: 'novacentro',
      ),
    );
  }
}

final ownerParkingConfigProvider =
    NotifierProvider<OwnerParkingConfigNotifier, OwnerParkingConfig>(
  OwnerParkingConfigNotifier.new,
);

/// Catálogo reactivo de todos los parqueaderos disponibles para el Conductor (Mapa y Sugerencias)
final driverParkingLotsCatalogProvider = Provider<List<PastoParkingLot>>((ref) {
  // Observar cambios en la configuración del propietario y espacios para refrescar automáticamente
  ref.watch(ownerParkingConfigProvider);
  ref.watch(parkingSpacesProvider);
  return PastoDataService.getAllParkingLots();
});

class OwnerSpaceItem {
  final String id;
  final String spaceNumber;
  final String vehicleType;
  final ParkingSpaceStatus status;
  final String? plate;
  final String? driverName;
  final String? entryTime;
  final double hourlyRate;

  const OwnerSpaceItem({
    required this.id,
    required this.spaceNumber,
    required this.vehicleType,
    required this.status,
    this.plate,
    this.driverName,
    this.entryTime,
    this.hourlyRate = 2800.0,
  });

  bool get isOccupied => status == ParkingSpaceStatus.occupied;
  bool get isAvailable => status == ParkingSpaceStatus.available;

  OwnerSpaceItem copyWith({
    String? id,
    String? spaceNumber,
    String? vehicleType,
    ParkingSpaceStatus? status,
    String? plate,
    String? driverName,
    String? entryTime,
    double? hourlyRate,
    bool clearVehicle = false,
  }) {
    return OwnerSpaceItem(
      id: id ?? this.id,
      spaceNumber: spaceNumber ?? this.spaceNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      status: status ?? this.status,
      plate: clearVehicle ? null : (plate ?? this.plate),
      driverName: clearVehicle ? null : (driverName ?? this.driverName),
      entryTime: clearVehicle ? null : (entryTime ?? this.entryTime),
      hourlyRate: hourlyRate ?? this.hourlyRate,
    );
  }
}

class ParkingSpacesNotifier extends Notifier<List<OwnerSpaceItem>> {
  @override
  List<OwnerSpaceItem> build() => _generateSpaces(carSpaces: 4, motoSpaces: 2);

  static List<OwnerSpaceItem> _generateSpaces({
    required int carSpaces,
    required int motoSpaces,
    double carRate = 2800.0,
    double motoRate = 1400.0,
  }) {
    final List<OwnerSpaceItem> generated = [];
    for (int i = 1; i <= carSpaces; i++) {
      final code = 'A-${i.toString().padLeft(2, '0')}';
      generated.add(
        OwnerSpaceItem(
          id: code,
          spaceNumber: code,
          vehicleType: 'Carro',
          status: ParkingSpaceStatus.available,
          hourlyRate: carRate,
        ),
      );
    }
    for (int j = 1; j <= motoSpaces; j++) {
      final code = 'B-${j.toString().padLeft(2, '0')}';
      generated.add(
        OwnerSpaceItem(
          id: code,
          spaceNumber: code,
          vehicleType: 'Moto',
          status: ParkingSpaceStatus.available,
          hourlyRate: motoRate,
        ),
      );
    }
    return generated;
  }

  /// Genera dinámicamente la cantidad exacta de espacios configurada por el propietario, todos LIBRES
  void configureSpaces({
    required int carSpaces,
    required int motoSpaces,
    double carRate = 2800.0,
    double motoRate = 1400.0,
  }) {
    state = _generateSpaces(
      carSpaces: carSpaces < 0 ? 0 : carSpaces,
      motoSpaces: motoSpaces < 0 ? 0 : motoSpaces,
      carRate: carRate,
      motoRate: motoRate,
    );
  }

  /// Actualiza las tarifas por hora de los espacios
  void updateRates({
    required double carRate,
    required double motoRate,
  }) {
    state = [
      for (final s in state)
        s.copyWith(
          hourlyRate: s.vehicleType.toLowerCase().contains('moto') ? motoRate : carRate,
        ),
    ];
  }

  /// Agrega una nueva bahía individualmente
  void addSpace({
    required String spaceNumber,
    required String vehicleType,
    required double hourlyRate,
  }) {
    final code = spaceNumber.trim().toUpperCase();
    if (code.isEmpty) return;
    if (state.any((s) => s.spaceNumber.toUpperCase() == code)) return;
    state = [
      ...state,
      OwnerSpaceItem(
        id: code,
        spaceNumber: code,
        vehicleType: vehicleType,
        status: ParkingSpaceStatus.available,
        hourlyRate: hourlyRate,
      ),
    ];
  }

  /// Habilita/Libera un espacio que estaba ocupado
  void freeSpace(String spaceNumber) {
    state = [
      for (final s in state)
        if (s.spaceNumber == spaceNumber)
          s.copyWith(
            status: ParkingSpaceStatus.available,
            clearVehicle: true,
          )
        else
          s,
    ];
  }

  /// Ocupa un espacio asignando un vehículo
  void occupySpace(
    String spaceNumber, {
    required String plate,
    required String vehicleType,
    String? driverName,
  }) {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final minuteStr = now.minute.toString().padLeft(2, '0');
    final formattedTime = '$hour:$minuteStr $period';

    state = [
      for (final s in state)
        if (s.spaceNumber == spaceNumber)
          s.copyWith(
            status: ParkingSpaceStatus.occupied,
            plate: plate.toUpperCase().trim(),
            vehicleType: vehicleType,
            driverName: driverName ?? 'Conductor presencial',
            entryTime: formattedTime,
          )
        else
          s,
    ];
  }

  /// Pone el espacio en mantenimiento
  void setMaintenance(String spaceNumber) {
    state = [
      for (final s in state)
        if (s.spaceNumber == spaceNumber)
          s.copyWith(
            status: ParkingSpaceStatus.maintenance,
            clearVehicle: true,
          )
        else
          s,
    ];
  }
}

final parkingSpacesProvider =
    NotifierProvider<ParkingSpacesNotifier, List<OwnerSpaceItem>>(
  ParkingSpacesNotifier.new,
);

/// Selector de porcentaje de ocupación
final occupancyPercentageProvider = Provider<int>((ref) {
  final spaces = ref.watch(parkingSpacesProvider);
  if (spaces.isEmpty) return 0;
  final occupied = spaces.where((s) => s.isOccupied).length;
  return ((occupied / spaces.length) * 100).round();
});

/// Selector de cupos disponibles
final availableSpacesCountProvider = Provider<int>((ref) {
  final spaces = ref.watch(parkingSpacesProvider);
  return spaces.where((s) => s.isAvailable).length;
});

/// Selector de cupos ocupados
final occupiedSpacesCountProvider = Provider<int>((ref) {
  final spaces = ref.watch(parkingSpacesProvider);
  return spaces.where((s) => s.isOccupied).length;
});
