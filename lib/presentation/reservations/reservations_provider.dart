import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  });

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
}

final userReservationsProvider =
    NotifierProvider<UserReservationsNotifier, List<ActiveReservationItem>>(
  UserReservationsNotifier.new,
);

