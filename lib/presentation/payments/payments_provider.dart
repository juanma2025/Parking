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
  List<RegisteredPaymentItem> build() => [];

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
