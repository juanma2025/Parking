import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:parking_app/core/router/app_router.dart';
import 'package:parking_app/domain/entities/user_role.dart';
import 'package:parking_app/presentation/auth/auth_providers.dart';
import 'package:parking_app/presentation/auth/login_screen.dart';
import 'package:parking_app/presentation/home/home_screen.dart';

void main() {
  testWidgets('Router redirects guest to login', (WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        currentUserRoleProvider.overrideWithValue(UserRole.guest),
      ],
    );
    
    final router = container.read(routerProvider);
    
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );
    
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });
  
  testWidgets('Router redirects vehicleOwner to home', (WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        currentUserRoleProvider.overrideWithValue(UserRole.vehicleOwner),
      ],
    );
    
    final router = container.read(routerProvider);
    
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );
    
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('User can exit login mode and navigate to home', (WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        currentUserRoleProvider.overrideWithValue(UserRole.guest),
      ],
    );

    final router = container.read(routerProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);

    // Tap the exit / back button to leave login mode
    final exitBtn = find.byTooltip('Volver a explorar');
    expect(exitBtn, findsOneWidget);
    await tester.tap(exitBtn);
    await tester.pumpAndSettle();

    // Verify user exited to HomeScreen
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('User can exit register mode and navigate to home', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final container = ProviderContainer(
      overrides: [
        currentUserRoleProvider.overrideWithValue(UserRole.guest),
      ],
    );

    final router = container.read(routerProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);

    // Navigate to register screen
    final registerLink = find.text('Crear cuenta');
    expect(registerLink, findsOneWidget);
    await tester.tap(registerLink);
    await tester.pumpAndSettle();
    expect(find.text('Register Account'), findsOneWidget);

    // Tap exit / back button to leave register mode
    final backBtn = find.byTooltip('Volver o salir a inicio');
    expect(backBtn, findsOneWidget);
    await tester.tap(backBtn);
    await tester.pumpAndSettle();

    // Verify user successfully exited
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
