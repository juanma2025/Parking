import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/domain_entities.dart';

class ActiveReservationItem {
  final String id;
  final String parkingLotName;
  final String address;
  final String statusText;
  final String spotNumber;
  final String entryTime;
  final String formattedTotal;
  final int hours;
  final String qrCode;
  final bool isRecent;
  final String vehiclePlate;
  final String vehicleName;
  final ReservationStatus status;

  const ActiveReservationItem({
    required this.id,
    required this.parkingLotName,
    required this.address,
    required this.statusText,
    required this.spotNumber,
    required this.entryTime,
    required this.formattedTotal,
    required this.hours,
    required this.qrCode,
    this.isRecent = false,
    this.vehiclePlate = 'ABC-123',
    this.vehicleName = 'Mazda 3 Touring',
    this.status = ReservationStatus.active,
  });

  String get cleanPlate =>
      vehiclePlate.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();

  bool get isActiveOrConfirmed =>
      status == ReservationStatus.active ||
      status == ReservationStatus.confirmed ||
      status == ReservationStatus.pending;

  ActiveReservationItem copyWith({
    String? id,
    String? parkingLotName,
    String? address,
    String? statusText,
    String? spotNumber,
    String? entryTime,
    String? formattedTotal,
    int? hours,
    String? qrCode,
    bool? isRecent,
    String? vehiclePlate,
    String? vehicleName,
    ReservationStatus? status,
  }) {
    return ActiveReservationItem(
      id: id ?? this.id,
      parkingLotName: parkingLotName ?? this.parkingLotName,
      address: address ?? this.address,
      statusText: statusText ?? this.statusText,
      spotNumber: spotNumber ?? this.spotNumber,
      entryTime: entryTime ?? this.entryTime,
      formattedTotal: formattedTotal ?? this.formattedTotal,
      hours: hours ?? this.hours,
      qrCode: qrCode ?? this.qrCode,
      isRecent: isRecent ?? this.isRecent,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      vehicleName: vehicleName ?? this.vehicleName,
      status: status ?? this.status,
    );
  }
}

class UserReservationsNotifier extends Notifier<List<ActiveReservationItem>> {
  @override
  List<ActiveReservationItem> build() => [];

  void addReservation({
    required String parkingLotName,
    required String address,
    required int hours,
    required String formattedTotal,
    String vehiclePlate = 'ABC-123',
    String vehicleName = 'Mazda 3 Touring',
  }) {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final minute = now.minute.toString().padLeft(2, '0');
    final timeStr = '$hour:$minute $period';

    final newItem = ActiveReservationItem(
      id: 'PAS-${now.millisecondsSinceEpoch.toString().substring(7)}',
      parkingLotName: parkingLotName,
      address: address,
      statusText: 'EN CURSO • ACTIVA',
      spotNumber: '#P-${12 + (now.millisecond % 35)}',
      entryTime: timeStr,
      formattedTotal: formattedTotal,
      hours: hours,
      qrCode: 'QR-PAS-${now.millisecondsSinceEpoch.toString().substring(7)}',
      isRecent: true,
      vehiclePlate: vehiclePlate,
      vehicleName: vehicleName,
      status: ReservationStatus.active,
    );

    // Prepend to active list so user sees it right at the top
    state = [newItem, ...state];
  }

  void extendReservation(String id) {
    state = state.map((item) {
      if (item.id == id) {
        final newHours = item.hours + 1;
        return item.copyWith(
          hours: newHours,
          statusText: 'EN CURSO • EXTENDIDO (+1h)',
        );
      }
      return item;
    }).toList();
  }

  /// Cancela la reserva de un conductor: libera el cupo y cambia el estado
  void cancelReservation(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  /// Determina si hay una reserva activa o confirmada para una placa dada
  bool hasActiveReservationForPlate(String plate) {
    final clean = plate.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
    return state.any((item) =>
        item.cleanPlate == clean && item.isActiveOrConfirmed);
  }
}

final userReservationsProvider =
    NotifierProvider<UserReservationsNotifier, List<ActiveReservationItem>>(
  UserReservationsNotifier.new,
);


