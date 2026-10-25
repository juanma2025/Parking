import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parking_app/domain/entities/domain_entities.dart';
import 'package:parking_app/presentation/profile/profile_screen.dart';
import 'package:parking_app/presentation/reservations/my_reservations_screen.dart';
import 'package:parking_app/presentation/reservations/reservations_provider.dart';
import 'package:parking_app/presentation/vehicles/vehicles_provider.dart';
import 'package:parking_app/presentation/vehicles/vehicles_screen.dart';

void main() {
  group('Driver Reservation Cancellation and Vehicle Management Tests', () {
    test('UserReservationsNotifier allows adding, extending, and cancelling reservations', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(userReservationsProvider), isEmpty);

      // Add a reservation for vehicle ABC-123
      container.read(userReservationsProvider.notifier).addReservation(
            parkingLotName: 'Parqueadero Unicentro Plaza',
            address: 'Av. Panamericana # 22-10, Pasto',
            hours: 2,
            formattedTotal: '\$5.600 COP',
            vehiclePlate: 'ABC · 123',
            vehicleName: 'Mazda 3 Touring',
          );

      var reservations = container.read(userReservationsProvider);
      expect(reservations.length, 1);
      final resId = reservations.first.id;
      expect(reservations.first.parkingLotName, 'Parqueadero Unicentro Plaza');
      expect(reservations.first.status, ReservationStatus.active);

      // Verify plate matching
      expect(
        container
            .read(userReservationsProvider.notifier)
            .hasActiveReservationForPlate('ABC · 123'),
        isTrue,
      );
      expect(
        container
            .read(userReservationsProvider.notifier)
            .hasActiveReservationForPlate('XYZ-789'),
        isFalse,
      );

      // Cancel reservation
      container.read(userReservationsProvider.notifier).cancelReservation(resId);
      expect(container.read(userReservationsProvider), isEmpty);
      expect(
        container
            .read(userReservationsProvider.notifier)
            .hasActiveReservationForPlate('ABC · 123'),
        isFalse,
      );
    });

    test('UserVehiclesNotifier enforces restriction: cannot delete vehicle with active/confirmed reservations', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final vehicles = container.read(userVehiclesProvider);
      expect(vehicles.length, 3);
      final mazda = vehicles.firstWhere((v) => v.cleanPlate == 'ABC123');

      // Create an active reservation for ABC-123
      final activeRes = ActiveReservationItem(
        id: 'RES-001',
        parkingLotName: 'Parqueadero Pasaje Nova',
        address: 'Calle 19 # 25-22, Pasto',
        statusText: 'EN CURSO • ACTIVA',
        spotNumber: '#P-14',
        entryTime: '10:00 AM',
        formattedTotal: '\$5.600 COP',
        hours: 2,
        qrCode: 'QR-RES-001',
        vehiclePlate: 'ABC · 123',
        status: ReservationStatus.active,
      );

      // Attempt to delete Mazda with active reservation -> should be blocked!
      final blockedResult = container
          .read(userVehiclesProvider.notifier)
          .deleteVehicle(mazda.id, [activeRes]);

      expect(blockedResult.success, isFalse);
      expect(blockedResult.errorMessage, contains('No se puede eliminar'));
      expect(container.read(userVehiclesProvider).length, 3);

      // Attempt to delete Yamaha MT-03 (plate KLP-45F) without reservation -> should succeed!
      final yamaha = vehicles.firstWhere((v) => v.cleanPlate == 'KLP45F');
      final allowedResult = container
          .read(userVehiclesProvider.notifier)
          .deleteVehicle(yamaha.id, [activeRes]);

      expect(allowedResult.success, isTrue);
      expect(container.read(userVehiclesProvider).length, 2);

      // Now cancel the reservation for Mazda
      final cancelledResult = container
          .read(userVehiclesProvider.notifier)
          .deleteVehicle(mazda.id, []); // No active reservations

      expect(cancelledResult.success, isTrue);
      expect(container.read(userVehiclesProvider).length, 1);
    });

    test('UserVehiclesNotifier allows updating vehicle information', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final vehicles = container.read(userVehiclesProvider);
      final renault = vehicles.firstWhere((v) => v.cleanPlate == 'XYZ789');

      final updatedRenault = renault.copyWith(
        model: 'Duster Iconic 4x4',
        color: 'Rojo Fuego Metálico',
        isPrimary: true,
      );

      container.read(userVehiclesProvider.notifier).updateVehicle(updatedRenault);

      final updatedList = container.read(userVehiclesProvider);
      final reloaded = updatedList.firstWhere((v) => v.id == renault.id);
      expect(reloaded.model, 'Duster Iconic 4x4');
      expect(reloaded.color, 'Rojo Fuego Metálico');
      expect(reloaded.isPrimary, isTrue);
    });

    testWidgets('VehiclesScreen displays edit and delete actions and blocks deletion if vehicle has active reservation', (tester) async {
      final activeReservation = ActiveReservationItem(
        id: 'RES-TEST-1',
        parkingLotName: 'Parqueadero Unicentro Plaza',
        address: 'Av. Panamericana, Pasto',
        statusText: 'EN CURSO • ACTIVA',
        spotNumber: '#P-15',
        entryTime: '11:00 AM',
        formattedTotal: '\$6.000 COP',
        hours: 2,
        qrCode: 'QR-TEST',
        vehiclePlate: 'ABC · 123',
        status: ReservationStatus.active,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userReservationsProvider.overrideWith(
              () => _TestUserReservationsNotifier([activeReservation]),
            ),
          ],
          child: const MaterialApp(
            home: VehiclesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Mis Vehículos'), findsOneWidget);
      expect(find.text('ABC · 123'), findsOneWidget);

      // Verify Edit and Delete buttons exist for vehicles
      expect(find.byKey(const Key('delete_vehicle_veh-001')), findsOneWidget);
      expect(find.byKey(const Key('edit_vehicle_veh-001')), findsOneWidget);

      // Tap Delete on vehicle with active reservation
      await tester.tap(find.byKey(const Key('delete_vehicle_veh-001')));
      await tester.pumpAndSettle();

      // Warning dialog should appear stating vehicle has active reservation
      expect(find.text('Vehículo con reserva activa'), findsOneWidget);
      expect(find.text('Entendido'), findsOneWidget);
      expect(find.text('Ver mis reservas'), findsOneWidget);

      // Close dialog
      await tester.tap(find.text('Entendido'));
      await tester.pumpAndSettle();

      // Vehicle is still present
      expect(find.text('ABC · 123'), findsOneWidget);
    });

    testWidgets('ProfileScreen shows active reservation card and allows cancellation', (tester) async {
      final activeReservation = ActiveReservationItem(
        id: 'RES-PROFILE-1',
        parkingLotName: 'Parqueadero Nova Centro',
        address: 'Calle 19 # 25-22, Pasto',
        statusText: 'EN CURSO • ACTIVA',
        spotNumber: '#P-20',
        entryTime: '2:30 PM',
        formattedTotal: '\$4.200 COP',
        hours: 1,
        qrCode: 'QR-NOVA-20',
        vehiclePlate: 'ABC · 123',
        status: ReservationStatus.active,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userReservationsProvider.overrideWith(
              () => _TestUserReservationsNotifier([activeReservation]),
            ),
          ],
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify active reservation appears on ProfileScreen
      expect(find.text('ESTANCIAS Y RESERVAS ACTIVAS'), findsOneWidget);
      expect(find.text('Parqueadero Nova Centro'), findsOneWidget);
      expect(find.text('#P-20'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);

      // Tap Cancelar
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      // Modal confirmation should appear
      expect(find.text('¿Cancelar reserva?'), findsOneWidget);
      expect(find.text('Sí, cancelar'), findsOneWidget);

      // Confirm cancellation
      await tester.tap(find.text('Sí, cancelar'));
      await tester.pumpAndSettle();

      // Active reservation should be cancelled and empty state displayed
      expect(find.text('Sin reservas activas'), findsOneWidget);
    });

    testWidgets('MyReservationsScreen allows cancelling active reservation', (tester) async {
      final activeReservation = ActiveReservationItem(
        id: 'RES-ACTIVE-99',
        parkingLotName: 'Parqueadero Sebastian Belalcazar',
        address: 'Cra 26, Pasto',
        statusText: 'EN CURSO • ACTIVA',
        spotNumber: '#P-08',
        entryTime: '3:00 PM',
        formattedTotal: '\$5.000 COP',
        hours: 2,
        qrCode: 'QR-SEB-08',
        vehiclePlate: 'ABC · 123',
        status: ReservationStatus.active,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userReservationsProvider.overrideWith(
              () => _TestUserReservationsNotifier([activeReservation]),
            ),
          ],
          child: const MaterialApp(
            home: MyReservationsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Parqueadero Sebastian Belalcazar'), findsOneWidget);
      expect(find.text('Cancelar reserva'), findsOneWidget);

      // Tap Cancelar reserva
      await tester.tap(find.text('Cancelar reserva'));
      await tester.pumpAndSettle();

      expect(find.text('¿Cancelar reserva?'), findsOneWidget);
      await tester.tap(find.text('Sí, cancelar'));
      await tester.pumpAndSettle();

      // State is now empty
      expect(find.text('Sin reservas activas'), findsOneWidget);
    });
  });
}

class _TestUserReservationsNotifier extends UserReservationsNotifier {
  final List<ActiveReservationItem> initial;
  _TestUserReservationsNotifier(this.initial);

  @override
  List<ActiveReservationItem> build() => initial;
}
