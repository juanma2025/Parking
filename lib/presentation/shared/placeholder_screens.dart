import 'package:flutter/material.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('Pantalla: $title')),
    );
  }
}

class LoginScreen extends StatelessWidget { const LoginScreen({super.key}); @override Widget build(BuildContext context) => const PlaceholderScreen(title: 'Login'); }
class RegisterScreen extends StatelessWidget { const RegisterScreen({super.key}); @override Widget build(BuildContext context) => const PlaceholderScreen(title: 'Registro'); }
class ForgotPasswordScreen extends StatelessWidget { const ForgotPasswordScreen({super.key}); @override Widget build(BuildContext context) => const PlaceholderScreen(title: 'Recuperar Contraseña'); }
class HomeScreen extends StatelessWidget { const HomeScreen({super.key}); @override Widget build(BuildContext context) => const PlaceholderScreen(title: 'Inicio'); }
class ParkingDetailScreen extends StatelessWidget { const ParkingDetailScreen({super.key}); @override Widget build(BuildContext context) => const PlaceholderScreen(title: 'Detalle de Parqueadero'); }
class ReserveScreen extends StatelessWidget { const ReserveScreen({super.key}); @override Widget build(BuildContext context) => const PlaceholderScreen(title: 'Reservar'); }
class ConfirmationScreen extends StatelessWidget { const ConfirmationScreen({super.key}); @override Widget build(BuildContext context) => const PlaceholderScreen(title: 'Confirmación'); }
class MyReservationsScreen extends StatelessWidget { const MyReservationsScreen({super.key}); @override Widget build(BuildContext context) => const PlaceholderScreen(title: 'Mis Reservas'); }
class ProfileScreen extends StatelessWidget { const ProfileScreen({super.key}); @override Widget build(BuildContext context) => const PlaceholderScreen(title: 'Perfil'); }
class VehiclesScreen extends StatelessWidget { const VehiclesScreen({super.key}); @override Widget build(BuildContext context) => const PlaceholderScreen(title: 'Vehículos'); }
class OwnerSummaryScreen extends StatelessWidget { const OwnerSummaryScreen({super.key}); @override Widget build(BuildContext context) => const PlaceholderScreen(title: 'Resumen (Propietario)'); }
class OwnerSpacesScreen extends StatelessWidget { const OwnerSpacesScreen({super.key}); @override Widget build(BuildContext context) => const PlaceholderScreen(title: 'Espacios (Propietario)'); }
class OwnerReservationsScreen extends StatelessWidget { const OwnerReservationsScreen({super.key}); @override Widget build(BuildContext context) => const PlaceholderScreen(title: 'Reservas (Propietario)'); }
class AdminPanelScreen extends StatelessWidget { const AdminPanelScreen({super.key}); @override Widget build(BuildContext context) => const PlaceholderScreen(title: 'Panel de Admin'); }
class PaymentsScreen extends StatelessWidget { const PaymentsScreen({super.key}); @override Widget build(BuildContext context) => const PlaceholderScreen(title: 'Pagos (Próximamente)'); }
class AlertsScreen extends StatelessWidget { const AlertsScreen({super.key}); @override Widget build(BuildContext context) => const PlaceholderScreen(title: 'Alertas (Próximamente)'); }
class AddScreen extends StatelessWidget { const AddScreen({super.key}); @override Widget build(BuildContext context) => const PlaceholderScreen(title: 'Agregar (+)'); }
