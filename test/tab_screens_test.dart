import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parking_app/presentation/alerts/alerts_screen.dart';
import 'package:parking_app/presentation/payments/payments_screen.dart';
import 'package:parking_app/presentation/reservations/my_reservations_screen.dart';
import 'package:parking_app/presentation/shared/app_drawer.dart';
import 'package:parking_app/presentation/vehicles/vehicles_screen.dart';

void main() {
  group('Tab Informative Cards Tests', () {
    testWidgets('MyReservationsScreen renders active reservation cards', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MyReservationsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Mis Reservas'), findsOneWidget);
      expect(find.text('Parqueadero San José'), findsOneWidget);
      expect(find.text('Clínica del Country - Garaje B'), findsOneWidget);
      expect(find.text('EN CURSO • 42 MIN'), findsOneWidget);
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

    testWidgets('PaymentsScreen renders balance and transaction cards', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PaymentsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Billetera y Pagos'), findsOneWidget);
      expect(find.text('\$48.500 COP'), findsOneWidget);
      expect(find.text('+ Recargar saldo'), findsOneWidget);
      expect(find.text('VISA'), findsOneWidget);
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
      expect(find.text('Reserva asegurada en Clínica del Country'), findsOneWidget);
    });

    testWidgets('AppDrawer renders navigation options and role switcher', (tester) async {
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

      expect(find.text('CAMBIAR MODO DE VISTA'), findsOneWidget);
      expect(find.text('Conductor'), findsOneWidget);
      expect(find.text('Anfitrión'), findsOneWidget);
      expect(find.text('Admin'), findsOneWidget);
      expect(find.text('Mis Reservas'), findsOneWidget);
      expect(find.text('Mis Vehículos'), findsOneWidget);
      expect(find.text('Pagos y Billetera'), findsOneWidget);
      expect(find.text('Alertas y Mensajes'), findsOneWidget);
      expect(find.text('Iniciar sesión'), findsOneWidget);
      expect(find.text('Registrarse'), findsOneWidget);
    });
  });
}
