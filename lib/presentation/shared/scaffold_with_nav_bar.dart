import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/user_role.dart';
import '../auth/auth_providers.dart';

class ScaffoldWithNavBar extends ConsumerWidget {
  final Widget child;
  const ScaffoldWithNavBar({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentUserRoleProvider);

    return Scaffold(
      body: child,
      bottomNavigationBar: _buildBottomBar(context, role),
    );
  }

  Widget _buildBottomBar(BuildContext context, UserRole role) {
    if (role == UserRole.admin) {
      return NavigationBar(
        selectedIndex: _calculateSelectedIndexAdmin(context),
        onDestinationSelected: (index) => _onItemTappedAdmin(index, context),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.admin_panel_settings), label: 'Panel'),
          NavigationDestination(icon: Icon(Icons.payment), label: 'Pagos'),
          NavigationDestination(icon: Icon(Icons.notifications), label: 'Alertas'),
        ],
      );
    }

    if (role == UserRole.parkingOwner) {
      return NavigationBar(
        selectedIndex: _calculateSelectedIndexParkingOwner(context),
        onDestinationSelected: (index) => _onItemTappedParkingOwner(index, context),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Resumen'),
          NavigationDestination(icon: Icon(Icons.local_parking), label: 'Espacios'),
          NavigationDestination(icon: Icon(Icons.add_circle), label: '+'),
          NavigationDestination(icon: Icon(Icons.book_online), label: 'Reservas'),
          NavigationDestination(icon: Icon(Icons.notifications), label: 'Alertas'),
        ],
      );
    }

    // Default to Vehicle Owner
    return NavigationBar(
      selectedIndex: _calculateSelectedIndexVehicleOwner(context),
      onDestinationSelected: (index) => _onItemTappedVehicleOwner(index, context),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home), label: 'Inicio'),
        NavigationDestination(icon: Icon(Icons.book), label: 'Reservas'),
        NavigationDestination(icon: Icon(Icons.add_circle), label: '+'),
        NavigationDestination(icon: Icon(Icons.payment), label: 'Pagos'),
        NavigationDestination(icon: Icon(Icons.notifications), label: 'Alertas'),
      ],
    );
  }

  int _calculateSelectedIndexAdmin(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/admin')) return 0;
    if (location.startsWith('/payments')) return 1;
    if (location.startsWith('/alerts')) return 2;
    return 0;
  }

  void _onItemTappedAdmin(int index, BuildContext context) {
    switch (index) {
      case 0: context.go('/admin'); break;
      case 1: context.go('/payments'); break;
      case 2: context.go('/alerts'); break;
    }
  }

  int _calculateSelectedIndexParkingOwner(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/owner-summary')) return 0;
    if (location.startsWith('/owner-spaces')) return 1;
    if (location.startsWith('/add')) return 2;
    if (location.startsWith('/owner-reservations')) return 3;
    if (location.startsWith('/alerts')) return 4;
    return 0;
  }

  void _onItemTappedParkingOwner(int index, BuildContext context) {
    switch (index) {
      case 0: context.go('/owner-summary'); break;
      case 1: context.go('/owner-spaces'); break;
      case 2: context.go('/add'); break;
      case 3: context.go('/owner-reservations'); break;
      case 4: context.go('/alerts'); break;
    }
  }

  int _calculateSelectedIndexVehicleOwner(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/my-reservations')) return 1;
    if (location.startsWith('/add')) return 2;
    if (location.startsWith('/payments')) return 3;
    if (location.startsWith('/alerts')) return 4;
    return 0;
  }

  void _onItemTappedVehicleOwner(int index, BuildContext context) {
    switch (index) {
      case 0: context.go('/home'); break;
      case 1: context.go('/my-reservations'); break;
      case 2: context.go('/add'); break;
      case 3: context.go('/payments'); break;
      case 4: context.go('/alerts'); break;
    }
  }
}
