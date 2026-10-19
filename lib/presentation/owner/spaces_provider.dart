import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/domain_entities.dart';

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
  List<OwnerSpaceItem> build() => _initialSpaces;

  static const List<OwnerSpaceItem> _initialSpaces = [
    OwnerSpaceItem(
      id: 'A-01',
      spaceNumber: 'A-01',
      vehicleType: 'Sedán',
      status: ParkingSpaceStatus.occupied,
      plate: 'ABC-123',
      driverName: 'Juan Pérez',
      entryTime: '10:30 AM',
      hourlyRate: 2800.0,
    ),
    OwnerSpaceItem(
      id: 'A-02',
      spaceNumber: 'A-02',
      vehicleType: 'Cualquiera',
      status: ParkingSpaceStatus.available,
      hourlyRate: 2800.0,
    ),
    OwnerSpaceItem(
      id: 'A-03',
      spaceNumber: 'A-03',
      vehicleType: 'Camioneta',
      status: ParkingSpaceStatus.occupied,
      plate: 'XYZ-789',
      driverName: 'María Gómez',
      entryTime: '11:00 AM',
      hourlyRate: 3500.0,
    ),
    OwnerSpaceItem(
      id: 'A-04',
      spaceNumber: 'A-04',
      vehicleType: 'Cualquiera',
      status: ParkingSpaceStatus.available,
      hourlyRate: 2800.0,
    ),
    OwnerSpaceItem(
      id: 'B-01',
      spaceNumber: 'B-01',
      vehicleType: 'Moto',
      status: ParkingSpaceStatus.occupied,
      plate: 'MNP-45C',
      driverName: 'Carlos Rodríguez',
      entryTime: '11:45 AM',
      hourlyRate: 1400.0,
    ),
    OwnerSpaceItem(
      id: 'B-02',
      spaceNumber: 'B-02',
      vehicleType: 'Cualquiera',
      status: ParkingSpaceStatus.available,
      hourlyRate: 2800.0,
    ),
  ];

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
