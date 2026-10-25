import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../reservations/reservations_provider.dart';

class UserVehicleItem {
  final String id;
  final String plate;
  final String vehicleType;
  final String brand;
  final String model;
  final String year;
  final String color;
  final bool isPrimary;
  final List<String> badges;

  const UserVehicleItem({
    required this.id,
    required this.plate,
    required this.vehicleType,
    required this.brand,
    required this.model,
    required this.year,
    required this.color,
    this.isPrimary = false,
    this.badges = const [],
  });

  String get displayName => '$brand $model $year'.trim();

  String get cleanPlate =>
      plate.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();

  UserVehicleItem copyWith({
    String? id,
    String? plate,
    String? vehicleType,
    String? brand,
    String? model,
    String? year,
    String? color,
    bool? isPrimary,
    List<String>? badges,
  }) {
    return UserVehicleItem(
      id: id ?? this.id,
      plate: plate ?? this.plate,
      vehicleType: vehicleType ?? this.vehicleType,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      color: color ?? this.color,
      isPrimary: isPrimary ?? this.isPrimary,
      badges: badges ?? this.badges,
    );
  }
}

class DeleteVehicleResult {
  final bool success;
  final String? errorMessage;

  const DeleteVehicleResult({
    required this.success,
    this.errorMessage,
  });
}

class UserVehiclesNotifier extends Notifier<List<UserVehicleItem>> {
  @override
  List<UserVehicleItem> build() => _initialVehicles;

  static const List<UserVehicleItem> _initialVehicles = [
    UserVehicleItem(
      id: 'veh-001',
      plate: 'ABC · 123',
      vehicleType: 'Sedán',
      brand: 'Mazda',
      model: '3 Touring',
      year: '2022',
      color: 'Gris Titanio Metálico',
      isPrimary: true,
      badges: ['SOAT al día', 'Tag RFID Activo'],
    ),
    UserVehicleItem(
      id: 'veh-002',
      plate: 'XYZ · 789',
      vehicleType: 'Camioneta SUV',
      brand: 'Renault',
      model: 'Duster Iconic',
      year: '2023',
      color: 'Blanco Glaciar',
      isPrimary: false,
      badges: ['SOAT al día', 'Cupo Grande'],
    ),
    UserVehicleItem(
      id: 'veh-003',
      plate: 'KLP · 45F',
      vehicleType: 'Motocicleta',
      brand: 'Yamaha',
      model: 'MT-03',
      year: '2024',
      color: 'Negro Mate',
      isPrimary: false,
      badges: ['SOAT al día', 'Tarifa 40% OFF'],
    ),
  ];

  /// Agrega un nuevo vehículo al garaje del conductor
  void addVehicle(UserVehicleItem vehicle) {
    if (vehicle.isPrimary) {
      state = [
        ...state.map((v) => v.copyWith(isPrimary: false)),
        vehicle,
      ];
    } else {
      state = [...state, vehicle];
    }
  }

  /// Edita y actualiza los datos de un vehículo existente
  void updateVehicle(UserVehicleItem updated) {
    state = state.map((v) {
      if (v.id == updated.id) {
        return updated;
      }
      if (updated.isPrimary && v.isPrimary) {
        return v.copyWith(isPrimary: false);
      }
      return v;
    }).toList();
  }

  /// Marca un vehículo como el principal para reservas rápidas
  void setPrimary(String id) {
    state = state.map((v) {
      return v.copyWith(isPrimary: v.id == id);
    }).toList();
  }

  /// Criterio de Aceptación:
  /// No se permite eliminar un vehículo con reservas pendientes, confirmadas o activas.
  DeleteVehicleResult deleteVehicle(
    String id,
    List<ActiveReservationItem> activeReservations,
  ) {
    final vehicleIndex = state.indexWhere((v) => v.id == id);
    if (vehicleIndex == -1) {
      return const DeleteVehicleResult(
        success: false,
        errorMessage: 'El vehículo no fue encontrado.',
      );
    }

    final targetVehicle = state[vehicleIndex];

    // Verificar si existe alguna reserva activa, confirmada o pendiente asociada a la placa
    final activeReservation = activeReservations.cast<ActiveReservationItem?>().firstWhere(
          (res) =>
              res != null &&
              res.isActiveOrConfirmed &&
              res.cleanPlate == targetVehicle.cleanPlate,
          orElse: () => null,
        );

    if (activeReservation != null) {
      return DeleteVehicleResult(
        success: false,
        errorMessage:
            'No se puede eliminar ${targetVehicle.displayName} (${targetVehicle.plate}) porque cuenta con una reserva activa o confirmada (${activeReservation.spotNumber} en ${activeReservation.parkingLotName}). Primero debes cancelar o finalizar la estancia.',
      );
    }

    final wasPrimary = targetVehicle.isPrimary;
    final remaining = state.where((v) => v.id != id).toList();

    // Si eliminó el vehículo principal y quedan vehículos, asignar el primero como principal
    if (wasPrimary && remaining.isNotEmpty) {
      remaining[0] = remaining[0].copyWith(isPrimary: true);
    }

    state = remaining;
    return const DeleteVehicleResult(success: true);
  }
}

final userVehiclesProvider =
    NotifierProvider<UserVehiclesNotifier, List<UserVehicleItem>>(
  UserVehiclesNotifier.new,
);
