import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parking_app/domain/entities/domain_entities.dart';
import 'package:parking_app/presentation/shared/bottom_bar5.dart';
import 'package:parking_app/presentation/shared/space_tile.dart';
import 'package:parking_app/presentation/shared/two_tone_title.dart';

void main() {
  group('TwoToneTitle Widget Tests', () {
    testWidgets('renders full text with highlighted last word by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TwoToneTitle(text: 'Encuentra tu parqueadero'),
          ),
        ),
      );

      expect(find.byType(TwoToneTitle), findsOneWidget);
      expect(find.byType(RichText), findsOneWidget);
    });

    testWidgets('renders specific highlightText when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TwoToneTitle(
              text: 'Inicia ',
              highlightText: 'sesión',
            ),
          ),
        ),
      );

      expect(find.byType(TwoToneTitle), findsOneWidget);
      final richText = tester.widget<RichText>(find.byType(RichText));
      final textSpan = richText.text as TextSpan;
      expect(textSpan.children?.length, 2);
    });
  });

  group('SpaceTile Widget Tests', () {
    testWidgets('renders available space with space number and LIBRE label', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SpaceTile(
              spaceNumber: 'A01',
              vehicleType: 'car',
              status: ParkingSpaceStatus.available,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('A01'), findsOneWidget);
      expect(find.text('LIBRE'), findsOneWidget);

      await tester.tap(find.text('A01'));
      expect(tapped, isTrue);
    });

    testWidgets('renders maintenance space with wrench icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SpaceTile(
              spaceNumber: 'B04',
              vehicleType: 'car',
              status: ParkingSpaceStatus.maintenance,
            ),
          ),
        ),
      );

      expect(find.text('B04'), findsOneWidget);
      expect(find.byIcon(Icons.build_rounded), findsOneWidget);
    });
  });

  group('BottomBar5 Widget Tests', () {
    testWidgets('renders 5 items and triggers callbacks on tap', (tester) async {
      int selected = 0;
      bool plusTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomBar5(
              currentIndex: selected,
              onTap: (index) => selected = index,
              onCenterAction: () => plusTapped = true,
              items: const [
                BottomBarItemData(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Inicio',
                ),
                BottomBarItemData(
                  icon: Icons.calendar_today_outlined,
                  activeIcon: Icons.calendar_today,
                  label: 'Reservas',
                ),
                BottomBarItemData(
                  icon: Icons.add,
                  activeIcon: Icons.add,
                  label: '+',
                ),
                BottomBarItemData(
                  icon: Icons.wallet_outlined,
                  activeIcon: Icons.wallet,
                  label: 'Pagos',
                ),
                BottomBarItemData(
                  icon: Icons.notifications_none,
                  activeIcon: Icons.notifications,
                  label: 'Alertas',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(BottomBar5), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);

      // Tap center plus action
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();
      expect(plusTapped, isTrue);

      // Tap first item
      await tester.tap(find.byIcon(Icons.calendar_today_outlined));
      await tester.pumpAndSettle();
      expect(selected, 1);
    });
  });
}
