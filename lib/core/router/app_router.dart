import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/user_role.dart';
import '../../presentation/auth/auth_providers.dart';
import '../../presentation/auth/login_screen.dart';
import '../../presentation/auth/register_screen.dart';
import '../../presentation/auth/vehicle_setup_screen.dart';
import '../../presentation/auth/parking_setup_screen.dart';
import '../../presentation/home/home_screen.dart';
import '../../presentation/shared/placeholder_screens.dart';
import '../../presentation/shared/scaffold_with_nav_bar.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

class AppRouterNotifier extends ChangeNotifier {
  final Ref _ref;
  AppRouterNotifier(this._ref) {
    _ref.listen<UserRole>(currentUserRoleProvider, (_, _) {
      notifyListeners();
    });
  }
}

final routerNotifierProvider = Provider<AppRouterNotifier>((ref) {
  return AppRouterNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    refreshListenable: notifier,
    initialLocation: '/login',
    redirect: (context, state) {
      final role = ref.read(currentUserRoleProvider);

      final isAuthRoute = state.uri.path == '/login' || 
                          state.uri.path == '/register' || 
                          state.uri.path.startsWith('/register/');

      final isPublicBrowseRoute = state.uri.path == '/home' || 
                                  state.uri.path.startsWith('/parking-detail') || 
                                  state.uri.path.startsWith('/parking');

      // If guest, allow auth routes and public discovery routes (/home, parking detail)
      if (role == UserRole.guest) {
        if (!isAuthRoute && !isPublicBrowseRoute) return '/login';
        return null;
      }

      // If authenticated and visiting login, redirect to appropriate home
      if (state.uri.path == '/login') {
        if (role == UserRole.vehicleOwner) return '/home';
        if (role == UserRole.parkingOwner) return '/owner-summary';
        if (role == UserRole.admin) return '/admin';
      }

      // Basic role guards
      if (state.uri.path.startsWith('/admin') && role != UserRole.admin) return '/login';
      if (state.uri.path.startsWith('/owner-') && role != UserRole.parkingOwner) return '/login';
      if (state.uri.path.startsWith('/home') && role != UserRole.vehicleOwner && role != UserRole.guest) return '/login';

      return null;
    },
    routes: [
      // Auth routes (outside Shell)
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/register/vehicle-setup',
        builder: (context, state) => const VehicleSetupScreen(),
      ),
      GoRoute(
        path: '/register/parking-setup',
        builder: (context, state) => const ParkingSetupScreen(),
      ),

      // App Routes (inside Shell)
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => ScaffoldWithNavBar(child: child),
        routes: [
          // Common routes
          GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
          GoRoute(path: '/add', builder: (context, state) => const AddScreen()),
          GoRoute(path: '/payments', builder: (context, state) => const PaymentsScreen()),
          GoRoute(path: '/alerts', builder: (context, state) => const AlertsScreen()),

          // Vehicle Owner routes
          GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
          GoRoute(path: '/my-reservations', builder: (context, state) => const MyReservationsScreen()),
          GoRoute(path: '/vehicles', builder: (context, state) => const VehiclesScreen()),
          GoRoute(path: '/parking-detail/:id', builder: (context, state) => const ParkingDetailScreen()),
          GoRoute(path: '/parking/:id', builder: (context, state) => const ParkingDetailScreen()),
          GoRoute(path: '/reserve/:id', builder: (context, state) => const ReserveScreen()),
          GoRoute(path: '/confirmation', builder: (context, state) => const ConfirmationScreen()),

          // Parking Owner routes
          GoRoute(path: '/owner-summary', builder: (context, state) => const OwnerSummaryScreen()),
          GoRoute(path: '/owner-spaces', builder: (context, state) => const OwnerSpacesScreen()),
          GoRoute(path: '/owner-reservations', builder: (context, state) => const OwnerReservationsScreen()),

          // Admin routes
          GoRoute(path: '/admin', builder: (context, state) => const AdminPanelScreen()),
        ],
      ),
    ],
  );
});
