import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/user_role.dart';
import '../auth/auth_providers.dart';
import 'bottom_bar5.dart';

class ScaffoldWithNavBar extends ConsumerWidget {
  final Widget child;
  const ScaffoldWithNavBar({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentUserRoleProvider);
    final isAuth = ref.watch(isAuthenticatedProvider);

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: isAuth ? _buildBottomBar(context, role) : null,
    );
  }

  Widget _buildBottomBar(BuildContext context, UserRole role) {
    if (role == UserRole.admin) {
      return BottomBar5(
        currentIndex: _calculateSelectedIndexAdmin(context),
        onTap: (index) => _onItemTappedAdmin(index, context),
        hasCenterAction: false,
        items: const [
          BottomBarItemData(
            icon: Icons.admin_panel_settings_outlined,
            activeIcon: Icons.admin_panel_settings_rounded,
            label: 'Panel',
          ),
          BottomBarItemData(
            icon: Icons.account_balance_wallet_outlined,
            activeIcon: Icons.account_balance_wallet_rounded,
            label: 'Pagos',
          ),
          BottomBarItemData(
            icon: Icons.notifications_none_rounded,
            activeIcon: Icons.notifications_rounded,
            label: 'Alertas',
          ),
        ],
      );
    }

    if (role == UserRole.parkingOwner) {
      return BottomBar5(
        currentIndex: _calculateSelectedIndexParkingOwner(context),
        onTap: (index) => _onItemTappedParkingOwner(index, context),
        onCenterAction: () => context.go('/add'),
        items: const [
          BottomBarItemData(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard_rounded,
            label: 'Resumen',
          ),
          BottomBarItemData(
            icon: Icons.local_parking_outlined,
            activeIcon: Icons.local_parking_rounded,
            label: 'Espacios',
          ),
          BottomBarItemData(
            icon: Icons.add_rounded,
            activeIcon: Icons.add_rounded,
            label: '+',
          ),
          BottomBarItemData(
            icon: Icons.calendar_today_outlined,
            activeIcon: Icons.calendar_today_rounded,
            label: 'Reservas',
          ),
          BottomBarItemData(
            icon: Icons.notifications_none_rounded,
            activeIcon: Icons.notifications_rounded,
            label: 'Alertas',
          ),
        ],
      );
    }

    // Default to Vehicle Owner
    return BottomBar5(
      currentIndex: _calculateSelectedIndexVehicleOwner(context),
      onTap: (index) => _onItemTappedVehicleOwner(index, context),
      onCenterAction: () => context.go('/add'),
      items: const [
        BottomBarItemData(
          icon: Icons.home_outlined,
          activeIcon: Icons.home_rounded,
          label: 'Inicio',
        ),
        BottomBarItemData(
          icon: Icons.calendar_today_outlined,
          activeIcon: Icons.calendar_today_rounded,
          label: 'Reservas',
        ),
        BottomBarItemData(
          icon: Icons.add_rounded,
          activeIcon: Icons.add_rounded,
          label: '+',
        ),
        BottomBarItemData(
          icon: Icons.account_balance_wallet_outlined,
          activeIcon: Icons.account_balance_wallet_rounded,
          label: 'Pagos',
        ),
        BottomBarItemData(
          icon: Icons.notifications_none_rounded,
          activeIcon: Icons.notifications_rounded,
          label: 'Alertas',
        ),
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
