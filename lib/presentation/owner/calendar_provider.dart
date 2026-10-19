import 'package:flutter_riverpod/flutter_riverpod.dart';

enum OwnerReservationState {
  porLlegar,
  enGaraje,
  finalizada,
}

class OwnerCalendarItem {
  final String id;
  final String plate;
  final String driver;
  final String spot;
  final String timeRange;
  final OwnerReservationState status;
  final double amount;
  final String vehicleType;
  final DateTime date;
  final String? phone;

  const OwnerCalendarItem({
    required this.id,
    required this.plate,
    required this.driver,
    required this.spot,
    required this.timeRange,
    required this.status,
    required this.amount,
    required this.vehicleType,
    required this.date,
    this.phone,
  });

  bool get isOccupied => status == OwnerReservationState.enGaraje;

  String get statusLabel {
    switch (status) {
      case OwnerReservationState.porLlegar:
        return 'POR LLEGAR';
      case OwnerReservationState.enGaraje:
        return 'EN GARAJE';
      case OwnerReservationState.finalizada:
        return 'FINALIZADA';
    }
  }

  String get formattedAmount {
    return '\$${amount.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )} COP';
  }

  OwnerCalendarItem copyWith({
    String? id,
    String? plate,
    String? driver,
    String? spot,
    String? timeRange,
    OwnerReservationState? status,
    double? amount,
    String? vehicleType,
    DateTime? date,
    String? phone,
  }) {
    return OwnerCalendarItem(
      id: id ?? this.id,
      plate: plate ?? this.plate,
      driver: driver ?? this.driver,
      spot: spot ?? this.spot,
      timeRange: timeRange ?? this.timeRange,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      vehicleType: vehicleType ?? this.vehicleType,
      date: date ?? this.date,
      phone: phone ?? this.phone,
    );
  }
}

class OwnerCalendarNotifier extends Notifier<List<OwnerCalendarItem>> {
  @override
  List<OwnerCalendarItem> build() => _initialCalendar;

  static final DateTime _today = DateTime.now();

  static final List<OwnerCalendarItem> _initialCalendar = [
    OwnerCalendarItem(
      id: 'RES-01',
      plate: 'ABC-123',
      driver: 'Juan Pérez',
      spot: 'Cupo A-01',
      timeRange: '10:30 AM - 12:30 PM',
      status: OwnerReservationState.enGaraje,
      amount: 5600.0,
      vehicleType: 'Sedán',
      date: _today,
      phone: '315 889 1234',
    ),
    OwnerCalendarItem(
      id: 'RES-02',
      plate: 'XYZ-789',
      driver: 'María Gómez',
      spot: 'Cupo A-03',
      timeRange: '11:00 AM - 1:00 PM',
      status: OwnerReservationState.enGaraje,
      amount: 6000.0,
      vehicleType: 'Camioneta',
      date: _today,
      phone: '312 445 6789',
    ),
    OwnerCalendarItem(
      id: 'RES-03',
      plate: 'MNP-45C',
      driver: 'Carlos Rodríguez',
      spot: 'Cupo B-01',
      timeRange: '11:45 AM - 1:45 PM',
      status: OwnerReservationState.enGaraje,
      amount: 2800.0,
      vehicleType: 'Moto',
      date: _today,
      phone: '317 223 9011',
    ),
    OwnerCalendarItem(
      id: 'RES-04',
      plate: 'DKL-502',
      driver: 'Ana Santacruz',
      spot: 'Cupo A-02',
      timeRange: '2:30 PM - 4:30 PM',
      status: OwnerReservationState.porLlegar,
      amount: 5600.0,
      vehicleType: 'Sedán',
      date: _today,
      phone: '310 998 7766',
    ),
    OwnerCalendarItem(
      id: 'RES-05',
      plate: 'QWE-331',
      driver: 'Andrés López',
      spot: 'Cupo A-04',
      timeRange: '5:00 PM - 7:00 PM',
      status: OwnerReservationState.porLlegar,
      amount: 5600.0,
      vehicleType: 'Sedán',
      date: _today,
      phone: '316 554 1122',
    ),
    OwnerCalendarItem(
      id: 'RES-06',
      plate: 'PAZ-110',
      driver: 'Rodrigo Rosero',
      spot: 'Cupo B-02',
      timeRange: '08:00 AM - 10:00 AM',
      status: OwnerReservationState.finalizada,
      amount: 5600.0,
      vehicleType: 'Sedán',
      date: _today,
      phone: '318 333 4455',
    ),
  ];

  /// Dar Entrada / Check-in
  void checkIn(String id) {
    state = [
      for (final item in state)
        if (item.id == id)
          item.copyWith(status: OwnerReservationState.enGaraje)
        else
          item,
    ];
  }

  /// Dar Salida y Finalizar
  void checkOut(String id) {
    state = [
      for (final item in state)
        if (item.id == id)
          item.copyWith(status: OwnerReservationState.finalizada)
        else
          item,
    ];
  }

  /// Agregar nueva reserva agendada
  void addReservation({
    required String plate,
    required String driver,
    required String spot,
    required String timeRange,
    required double amount,
    required String vehicleType,
    required DateTime date,
    String? phone,
  }) {
    final newItem = OwnerCalendarItem(
      id: 'RES-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      plate: plate.toUpperCase().trim(),
      driver: driver.trim(),
      spot: spot,
      timeRange: timeRange,
      status: OwnerReservationState.porLlegar,
      amount: amount,
      vehicleType: vehicleType,
      date: date,
      phone: phone,
    );

    state = [newItem, ...state];
  }
}

final ownerCalendarProvider =
    NotifierProvider<OwnerCalendarNotifier, List<OwnerCalendarItem>>(
  OwnerCalendarNotifier.new,
);

class SelectedCalendarDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void setDate(DateTime date) => state = date;
}

final selectedCalendarDateProvider =
    NotifierProvider<SelectedCalendarDateNotifier, DateTime>(
  SelectedCalendarDateNotifier.new,
);
