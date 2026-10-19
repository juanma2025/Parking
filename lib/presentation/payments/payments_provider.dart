import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisteredPaymentItem {
  final String id;
  final double amount;
  final String method; // 'efectivo', 'nequi', 'transferencia'
  final String? plate;
  final String? spaceNumber;
  final String? referenceNumber;
  final String? bankName;
  final double? receivedAmount;
  final double? changeAmount;
  final String? driverName;
  final DateTime timestamp;
  final String status;

  const RegisteredPaymentItem({
    required this.id,
    required this.amount,
    required this.method,
    this.plate,
    this.spaceNumber,
    this.referenceNumber,
    this.bankName,
    this.receivedAmount,
    this.changeAmount,
    this.driverName,
    required this.timestamp,
    this.status = 'Completado',
  });

  String get formattedAmount {
    final integer = amount.toInt();
    return '\$${_formatThousands(integer)} COP';
  }

  static String _formatThousands(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}

class RegisteredPaymentsNotifier extends Notifier<List<RegisteredPaymentItem>> {
  @override
  List<RegisteredPaymentItem> build() => _initialPayments;

  static final List<RegisteredPaymentItem> _initialPayments = [
    RegisteredPaymentItem(
      id: 'PAY-1001',
      amount: 5600,
      method: 'efectivo',
      plate: 'ABC-123',
      spaceNumber: 'A-01',
      receivedAmount: 10000,
      changeAmount: 4400,
      driverName: 'Juan Pérez',
      timestamp: DateTime.now().subtract(const Duration(minutes: 195)),
    ),
    RegisteredPaymentItem(
      id: 'PAY-1002',
      amount: 28000,
      method: 'nequi',
      plate: 'KDF-901',
      spaceNumber: 'A-02',
      referenceNumber: 'M-491023',
      driverName: 'Paola Narváez',
      timestamp: DateTime.now().subtract(const Duration(minutes: 160)),
    ),
    RegisteredPaymentItem(
      id: 'PAY-1003',
      amount: 6000,
      method: 'efectivo',
      plate: 'XYZ-789',
      spaceNumber: 'A-03',
      receivedAmount: 10000,
      changeAmount: 4000,
      driverName: 'María Gómez',
      timestamp: DateTime.now().subtract(const Duration(minutes: 125)),
    ),
    RegisteredPaymentItem(
      id: 'PAY-1004',
      amount: 18000,
      method: 'transferencia',
      plate: 'HRP-312',
      spaceNumber: 'B-03',
      bankName: 'Bancolombia',
      referenceNumber: 'TRF-781920',
      driverName: 'Andrés López',
      timestamp: DateTime.now().subtract(const Duration(minutes: 90)),
    ),
    RegisteredPaymentItem(
      id: 'PAY-1005',
      amount: 2800,
      method: 'efectivo',
      plate: 'MOT-44C',
      spaceNumber: 'B-01',
      receivedAmount: 5000,
      changeAmount: 2200,
      driverName: 'Carlos Rodríguez',
      timestamp: DateTime.now().subtract(const Duration(minutes: 70)),
    ),
    RegisteredPaymentItem(
      id: 'PAY-1006',
      amount: 34000,
      method: 'nequi',
      plate: 'PST-092',
      spaceNumber: 'A-04',
      referenceNumber: 'M-829104',
      driverName: 'Esteban Benavides',
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    RegisteredPaymentItem(
      id: 'PAY-1007',
      amount: 15000,
      method: 'efectivo',
      plate: 'TXA-551',
      spaceNumber: 'A-05',
      receivedAmount: 20000,
      changeAmount: 5000,
      driverName: 'Lucía Santacruz',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    RegisteredPaymentItem(
      id: 'PAY-1008',
      amount: 10000,
      method: 'transferencia',
      plate: 'BVC-882',
      spaceNumber: 'B-02',
      bankName: 'Daviplata',
      referenceNumber: 'DP-912401',
      driverName: 'Felipe Coral',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    RegisteredPaymentItem(
      id: 'PAY-1009',
      amount: 65600,
      method: 'efectivo',
      plate: 'LMN-331',
      spaceNumber: 'A-06',
      receivedAmount: 70000,
      changeAmount: 4400,
      driverName: 'Consorcio Nariño',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  void addPayment({
    required double amount,
    required String method,
    String? plate,
    String? spaceNumber,
    String? referenceNumber,
    String? bankName,
    double? receivedAmount,
    double? changeAmount,
    String? driverName,
  }) {
    final newPayment = RegisteredPaymentItem(
      id: 'PAY-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      amount: amount,
      method: method,
      plate: plate?.toUpperCase().trim(),
      spaceNumber: spaceNumber,
      referenceNumber: referenceNumber?.trim(),
      bankName: bankName,
      receivedAmount: receivedAmount,
      changeAmount: changeAmount,
      driverName: driverName?.trim(),
      timestamp: DateTime.now(),
      status: 'Completado',
    );

    state = [newPayment, ...state];
  }
}

final registeredPaymentsProvider =
    NotifierProvider<RegisteredPaymentsNotifier, List<RegisteredPaymentItem>>(
  RegisteredPaymentsNotifier.new,
);

final totalRevenueTodayProvider = Provider<double>((ref) {
  final payments = ref.watch(registeredPaymentsProvider);
  return payments.fold<double>(0.0, (sum, item) => sum + item.amount);
});

final cashRevenueTodayProvider = Provider<double>((ref) {
  final payments = ref.watch(registeredPaymentsProvider);
  return payments
      .where((p) => p.method.toLowerCase() == 'efectivo')
      .fold<double>(0.0, (sum, item) => sum + item.amount);
});

final nequiRevenueTodayProvider = Provider<double>((ref) {
  final payments = ref.watch(registeredPaymentsProvider);
  return payments
      .where((p) => p.method.toLowerCase() == 'nequi')
      .fold<double>(0.0, (sum, item) => sum + item.amount);
});

final transferRevenueTodayProvider = Provider<double>((ref) {
  final payments = ref.watch(registeredPaymentsProvider);
  return payments
      .where((p) => p.method.toLowerCase() == 'transferencia')
      .fold<double>(0.0, (sum, item) => sum + item.amount);
});
