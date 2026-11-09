import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parking_app/data/datasources/pasto_landmarks_data.dart';
import 'package:parking_app/domain/entities/user_role.dart';
import 'package:parking_app/presentation/auth/auth_providers.dart';
import 'package:parking_app/presentation/owner/calendar_provider.dart';
import 'package:parking_app/presentation/owner/owner_screens.dart';
import 'package:parking_app/presentation/owner/spaces_provider.dart';
import 'package:parking_app/presentation/payments/payments_screen.dart';
import 'package:parking_app/presentation/profile/profile_screen.dart';

void main() {
  group('Owner and Payments Feature Tests', () {
    testWidgets(
      'OwnerSpacesScreen initializes all spaces as available (LIBRE), supports custom space count, and allows occupying/freeing',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final container = ProviderContainer();
        addTearDown(container.dispose);

        // Configure 8 car spaces + 4 moto spaces = 12 spaces
        container.read(ownerParkingConfigProvider.notifier).configureParkingLot(
              name: 'Parqueadero Test Pasto',
              address: 'Calle 18 # 24-10, Pasto',
              openTime: '06:00 AM',
              closeTime: '10:00 PM',
              carSpaces: 8,
              motoSpaces: 4,
              carHourlyRate: 3000,
              motoHourlyRate: 1500,
            );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: OwnerSpacesScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify all 12 configured spaces are initialized as available (0 occupied)
        final spaces = container.read(parkingSpacesProvider);
        expect(spaces.length, 12);
        expect(spaces.every((s) => !s.isOccupied), isTrue);
        expect(find.text('12 LIBRES • 0 OCUPADOS'), findsOneWidget);

        // Check initial space A-01 is rendered as LIBRE
        expect(find.text('A-01'), findsOneWidget);

        // Tap on available space A-01 to occupy it
        await tester.tap(find.text('A-01'));
        await tester.pumpAndSettle();

        expect(find.text('✓ Confirmar Ingreso y Ocupar Cupo'), findsOneWidget);
        await tester.tap(find.text('✓ Confirmar Ingreso y Ocupar Cupo'));
        await tester.pumpAndSettle();

        // Now tap on occupied space A-01 to free it
        await tester.tap(find.text('A-01'));
        await tester.pumpAndSettle();

        expect(
          find.text('✓ Habilitar espacio (Marcar como LIBRE)'),
          findsOneWidget,
        );
        await tester.tap(find.text('✓ Habilitar espacio (Marcar como LIBRE)'));
        await tester.pumpAndSettle();

        expect(
          find.text(
            '✓ Cupo A-01 habilitado como LIBRE. Registro actualizado.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'OwnerSummaryScreen starts with 0 revenue, shows theme toggle button, and opens interactive modals',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: OwnerSummaryScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify KPI cards start at 0% occupancy and $0 revenue (no fictional income)
        expect(find.text('OCUPACIÓN'), findsOneWidget);
        expect(find.text('0%'), findsOneWidget);
        expect(find.text('INGRESOS HOY'), findsOneWidget);
        expect(find.text('\$0'), findsOneWidget);
        expect(find.text('\$0 COP'), findsOneWidget);

        // Verify Dark/Light mode toggle button is visible in the header
        expect(
          find.byKey(const Key('owner_theme_toggle_button')),
          findsOneWidget,
        );

        // Tap on Occupancy card
        await tester.tap(find.text('OCUPACIÓN'));
        await tester.pumpAndSettle();

        // Modal opens with breakdown
        expect(find.text('CUPOS LIBRES'), findsOneWidget);
        expect(find.text('CUPOS OCUPADOS'), findsOneWidget);
      },
    );

    testWidgets(
      'OwnerReservationsScreen shows empty state by default and lists only real reservations',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final container = ProviderContainer();
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: OwnerReservationsScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Check header and calendar days
        expect(find.text('Agenda y Calendario'), findsOneWidget);
        expect(find.text('Hoy'), findsOneWidget);
        expect(find.text('Mañ'), findsOneWidget);

        // Verify no fictional reservations exist and empty state is displayed
        expect(find.text('Juan Pérez'), findsNothing);
        expect(find.text('Aún no tienes reservas'), findsOneWidget);

        // Add a real reservation and verify it appears
        container.read(ownerCalendarProvider.notifier).addReservation(
              driver: 'Carlos Real',
              plate: 'NAR-999',
              vehicleType: 'Sedán',
              spot: 'A-01',
              timeRange: '10:00 AM - 12:00 PM',
              amount: 6000,
              date: DateTime.now(),
            );

        await tester.pumpAndSettle();

        expect(find.text('Carlos Real'), findsOneWidget);
        expect(
          find.text('✓ Registrar Entrada al Garaje (Check-in)'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'ProfileScreen differentiates Owner role panel from Driver role panel',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currentUserRoleProvider.overrideWithValue(UserRole.parkingOwner),
            ],
            child: const MaterialApp(
              home: ProfileScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('PROPIETARIO DE PARQUEADERO'), findsOneWidget);
        expect(find.text('MI PARQUEADERO Y OPERACIÓN'), findsOneWidget);
        expect(find.text('GESTIÓN DE PARQUEADERO Y CUENTA'), findsOneWidget);
        expect(find.text('Configurar Parqueadero y Cupos'), findsOneWidget);
        expect(find.text('Administrar Cupos en Tiempo Real'), findsOneWidget);
        expect(find.text('Mis Vehículos'), findsNothing);
      },
    );

    testWidgets(
      'Newly created parking lot is registered in PastoDataService for Driver map and suggestions',
      (tester) async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        container.read(ownerParkingConfigProvider.notifier).configureParkingLot(
              name: 'Parqueadero Nuevo Galeras',
              address: 'Cra 27 # 19-30, Centro, Pasto',
              openTime: '06:00 AM',
              closeTime: '10:00 PM',
              carSpaces: 15,
              motoSpaces: 10,
              carHourlyRate: 2800,
              motoHourlyRate: 1400,
            );

        final allLots = PastoDataService.getAllParkingLots();
        expect(
          allLots.any((lot) => lot.name == 'Parqueadero Nuevo Galeras'),
          isTrue,
        );
        final createdLot = allLots.firstWhere(
          (lot) => lot.name == 'Parqueadero Nuevo Galeras',
        );
        expect(createdLot.carSpaces, 15);
        expect(createdLot.motoSpaces, 10);
        expect(createdLot.totalSpaces, 25);
      },
    );

    testWidgets('PaymentsScreen allows cash, nequi, and transfer registration', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserRoleProvider.overrideWithValue(UserRole.parkingOwner),
          ],
          child: const MaterialApp(
            home: PaymentsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify payment methods exist
      expect(find.text('Efectivo'), findsOneWidget);
      expect(find.text('Nequi'), findsOneWidget);
      expect(find.text('Transferencia'), findsOneWidget);

      // Tap on Nequi
      await tester.tap(find.text('Nequi'));
      await tester.pumpAndSettle();

      expect(find.text('Celular Nequi del Conductor (ej: 312 456 7890)'), findsOneWidget);

      // Tap on Transferencia
      await tester.tap(find.text('Transferencia'));
      await tester.pumpAndSettle();

      expect(find.text('Entidad Bancaria'), findsOneWidget);
      expect(find.text('Bancolombia (A la mano / QR)'), findsOneWidget);

      // Switch back to Efectivo and verify change calculation
      await tester.tap(find.text('Efectivo'));
      await tester.pumpAndSettle();

      expect(find.text('VUELTAS / CAMBIO:'), findsOneWidget);

      // Tap register button
      await tester.tap(find.text('✓ Confirmar y Registrar Pago en Taquilla'));
      await tester.pumpAndSettle();

      // Receipt modal should appear
      expect(find.text('¡Pago Registrado con Éxito!'), findsOneWidget);
    });
  });
}
