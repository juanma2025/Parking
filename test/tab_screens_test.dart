import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parking_app/presentation/alerts/alerts_screen.dart';
import 'package:parking_app/presentation/payments/payments_screen.dart';
import 'package:parking_app/presentation/reservations/my_reservations_screen.dart';
import 'package:parking_app/presentation/reservations/reservations_provider.dart';
import 'package:parking_app/domain/entities/user_role.dart';
import 'package:parking_app/presentation/auth/auth_providers.dart';
import 'package:parking_app/presentation/shared/app_drawer.dart';
import 'package:parking_app/presentation/vehicles/vehicles_screen.dart';

void main() {
  group('Tab Informative Cards Tests', () {
    testWidgets('MyReservationsScreen renders active reservation cards or empty state', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MyReservationsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Mis Reservas'), findsOneWidget);
      expect(find.text('Sin reservas activas'), findsOneWidget);
      expect(find.text('Explorar parqueaderos en Pasto'), findsOneWidget);
    });

    testWidgets('VehiclesScreen renders vehicle informative cards', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: VehiclesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Mis Vehículos'), findsOneWidget);
      expect(find.text('ABC · 123'), findsOneWidget);
      expect(find.text('Mazda 3 Touring 2022'), findsOneWidget);
      expect(find.text('Renault Duster Iconic 2023'), findsOneWidget);
      expect(find.text('Yamaha MT-03 2024'), findsOneWidget);
    });

    testWidgets('PaymentsScreen renders QR payment info, updates with reservations, and hides taquilla for drivers', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: PaymentsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Pases y Pagos'), findsOneWidget);
      expect(find.text('Pago Presencial con QR'), findsOneWidget);
      expect(find.text('¿CÓMO FUNCIONA EL PAGO EN PASTO?'), findsOneWidget);
      expect(find.text('Buscar parqueadero en Pasto'), findsOneWidget);
      // Desk income / taquilla registration MUST NOT be shown to driver
      expect(find.text('REGISTRAR COBRO EN TAQUILLA'), findsNothing);

      // Add a reservation dynamically
      container.read(userReservationsProvider.notifier).addReservation(
            parkingLotName: 'Parqueadero Unicentro Pasto',
            address: 'Cra 34 # 18-45',
            hours: 2,
            formattedTotal: '\$5.600 COP',
            vehiclePlate: 'ABC-123',
            vehicleName: 'Mazda 3 Touring',
          );

      await tester.pumpAndSettle();

      // Dynamic QR card should now be rendered automatically
      expect(find.text('Parqueadero Unicentro Pasto'), findsOneWidget);
      expect(find.text('LISTO PARA ESCANEAR'), findsOneWidget);
      expect(find.textContaining('QR-PAS-'), findsOneWidget);
      expect(find.text('Mazda 3 Touring (ABC-123)'), findsOneWidget);
    });

    testWidgets('AlertsScreen renders notification cards', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AlertsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Notificaciones'), findsOneWidget);
      expect(find.text('¡Tiempo de reserva por vencer!'), findsOneWidget);
      expect(find.text('Reserva asegurada en Parqueadero Unicentro Plaza'), findsOneWidget);
    });

    testWidgets('AppDrawer renders Apple style navigation in guest mode', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              drawer: AppDrawer(),
              body: Center(child: Text('Home Body')),
            ),
          ),
        ),
      );

      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      // Verify role switcher was removed and role is default guest
      expect(find.text('CAMBIAR MODO DE VISTA'), findsNothing);
      expect(find.text('INVITADO'), findsOneWidget);
      expect(find.text('SERVICIOS'), findsOneWidget);
      expect(find.text('Explorar Parqueaderos'), findsOneWidget);
      expect(find.text('Mis Reservas'), findsOneWidget);
      expect(find.text('Mis Vehículos'), findsOneWidget);
      expect(find.text('Pagos y Billetera'), findsOneWidget);
      expect(find.text('Alertas y Mensajes'), findsOneWidget);
      expect(find.text('Iniciar sesión'), findsOneWidget);
      expect(find.text('Registrarse'), findsOneWidget);
    });

    testWidgets('AppDrawer renders conductor badge when role is vehicleOwner', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserRoleProvider.overrideWithValue(UserRole.vehicleOwner),
          ],
          child: const MaterialApp(
            home: Scaffold(
              drawer: AppDrawer(),
              body: Center(child: Text('Home Body')),
            ),
          ),
        ),
      );

      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(find.text('CONDUCTOR'), findsOneWidget);
    });
  });
}
