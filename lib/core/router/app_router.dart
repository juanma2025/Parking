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
    _ref.listen<bool>(isAuthenticatedProvider, (_, _) {
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
    initialLocation: '/home',
    redirect: (context, state) {
      final isAuth = ref.read(isAuthenticatedProvider);
      final role = ref.read(currentUserRoleProvider);

      final isLoginRoute = state.uri.path == '/login';
      final isRegisterRoute = state.uri.path == '/register';

      final isSetupRoute = state.uri.path == '/register/vehicle-setup' ||
                           state.uri.path == '/register/parking-setup';

      final isPublicRoute = state.uri.path == '/home' || 
                            state.uri.path == '/profile' || 
                            state.uri.path.startsWith('/parking-detail') || 
                            state.uri.path.startsWith('/parking');

      // 1. If not authenticated:
      if (!isAuth) {
        // Freely allow auth entry screens, onboarding setup, and public exploration screens
        if (isLoginRoute || isRegisterRoute || isSetupRoute || isPublicRoute) {
          return null;
        }
        // Protected screens require login
        return '/login';
      }

      // 2. Allow onboarding setup routes and active register flow while authenticated
      if (isSetupRoute || isRegisterRoute) {
        return null;
      }

      // 3. If authenticated and visiting login screen, route to appropriate role home
      if (isLoginRoute) {
        if (role == UserRole.parkingOwner) return '/owner-summary';
        if (role == UserRole.admin) return '/admin';
        return '/home';
      }

      // 4. Role-based guards for authenticated users
      if (state.uri.path.startsWith('/admin') && role != UserRole.admin) return '/home';
      if (state.uri.path.startsWith('/owner-') && role != UserRole.parkingOwner) return '/home';

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
