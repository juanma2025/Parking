import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parking_app/presentation/owner/owner_screens.dart';
import 'package:parking_app/presentation/payments/payments_screen.dart';

void main() {
  group('Owner and Payments Feature Tests', () {
    testWidgets('OwnerSpacesScreen allows owner to free an occupied space', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OwnerSpacesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check initial space A-01 is rendered
      expect(find.text('A-01'), findsOneWidget);

      // Tap on occupied space A-01
      await tester.tap(find.text('A-01'));
      await tester.pumpAndSettle();

      // Modal bottom sheet should appear with "Habilitar espacio (Marcar como LIBRE)"
      expect(find.text('✓ Habilitar espacio (Marcar como LIBRE)'), findsOneWidget);

      // Tap to free the space
      await tester.tap(find.text('✓ Habilitar espacio (Marcar como LIBRE)'));
      await tester.pumpAndSettle();

      // Modal closed and SnackBar confirmation displayed
      expect(find.text('✓ Cupo A-01 habilitado como LIBRE. Registro actualizado.'), findsOneWidget);
    });

    testWidgets('OwnerSummaryScreen cards have interactive modals on tap', (tester) async {
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

      // Verify KPI cards are present
      expect(find.text('OCUPACIÓN'), findsOneWidget);
      expect(find.text('INGRESOS HOY'), findsOneWidget);

      // Tap on Occupancy card
      await tester.tap(find.text('OCUPACIÓN'));
      await tester.pumpAndSettle();

      // Modal opens with breakdown
      expect(find.text('CUPOS LIBRES'), findsOneWidget);
      expect(find.text('CUPOS OCUPADOS'), findsOneWidget);
    });

    testWidgets('OwnerReservationsScreen renders calendar days and check-in actions', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OwnerReservationsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check header and calendar days
      expect(find.text('Agenda y Calendario'), findsOneWidget);
      expect(find.text('Hoy'), findsOneWidget);
      expect(find.text('Mañ'), findsOneWidget);

      // Check reservation item presence
      expect(find.text('Juan Pérez'), findsOneWidget);
      expect(find.text('Dar Salida y Registrar Pago'), findsWidgets);
    });

    testWidgets('PaymentsScreen allows cash, nequi, and transfer registration', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
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
