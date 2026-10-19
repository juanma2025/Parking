import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:parking_app/core/router/app_router.dart';
import 'package:parking_app/domain/entities/user_role.dart';
import 'package:parking_app/presentation/auth/auth_providers.dart';
import 'package:parking_app/presentation/auth/login_screen.dart';
import 'package:parking_app/presentation/auth/register_screen.dart';
import 'package:parking_app/presentation/home/home_screen.dart';
import 'package:parking_app/presentation/shared/animated_auth_actions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'helpers/fake_auth_repository.dart';

void main() {
  testWidgets('Router opens HomeScreen by default and redirects guest when accessing protected route', (WidgetTester tester) async {
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
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('¿QUÉ OPCIONES TIENES?'), findsOneWidget);

    // Protected route redirect
    router.go('/my-reservations');
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });
  
  testWidgets('Authenticated vehicleOwner is redirected to home and sees hamburger menu', (WidgetTester tester) async {
    final fakeRepo = FakeAuthRepository();
    final testUser = User(
      id: 'driver-123',
      appMetadata: {},
      userMetadata: {'full_name': 'Carlos Gomez', 'role': 'conductor'},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
    );
    fakeRepo.setCurrentUser(testUser, role: UserRole.vehicleOwner);

    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(fakeRepo),
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

    // Verify hamburger menu button is present when authenticated!
    expect(find.byIcon(Icons.menu_rounded), findsOneWidget);
  });

  testWidgets('Unauthenticated user on HomeScreen sees animated auth actions, no bottom bar, no map, and no hamburger menu', (WidgetTester tester) async {
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
    expect(find.byType(HomeScreen), findsOneWidget);

    // Verify hamburger menu button is NOT present when unauthenticated!
    expect(find.byIcon(Icons.menu_rounded), findsNothing);

    // Verify AnimatedAuthActions is present with 'Iniciar sesión' and 'Registro'
    expect(find.byType(AnimatedAuthActions), findsOneWidget);
    final registroBtn = find.text('Registro');
    expect(registroBtn, findsOneWidget);

    // Tap Registro button and verify it navigates to RegisterScreen
    await tester.tap(registroBtn);
    await tester.pumpAndSettle();
    expect(find.byType(RegisterScreen), findsOneWidget);
    expect(find.text('Conductor'), findsOneWidget);
    expect(find.text('Parqueadero'), findsOneWidget);
  });

  testWidgets('Unauthenticated user on HomeScreen can tap Iniciar sesión to navigate to LoginScreen', (WidgetTester tester) async {
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
    expect(find.byType(HomeScreen), findsOneWidget);

    // Tap Iniciar sesión in AnimatedAuthActions
    final loginBtn = find.text('Iniciar sesión');
    expect(loginBtn, findsOneWidget);
    await tester.tap(loginBtn);
    await tester.pumpAndSettle();

    // Verify successfully routed to LoginScreen!
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('CORREO'), findsOneWidget);
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
    router.go('/login');
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
    router.go('/register');
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

  testWidgets('User advances to vehicle setup after registering as driver', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final container = ProviderContainer(
      overrides: [
        currentUserRoleProvider.overrideWithValue(UserRole.guest),
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
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
    router.go('/register');
    await tester.pumpAndSettle();

    // Enter registration fields
    final textFields = find.byType(TextField);
    await tester.enterText(textFields.at(0), 'Carlos Gómez');
    await tester.enterText(textFields.at(1), 'carlos@ejemplo.com');
    await tester.enterText(textFields.at(2), 'Password123');
    await tester.pumpAndSettle();

    // Verify password strength indicator displays
    expect(find.text('Seguridad alta'), findsOneWidget);

    // Tap Continuar
    await tester.tap(find.text('Continuar  →'));
    await tester.pumpAndSettle();

    // Verify VehicleSetupScreen is displayed
    expect(find.text('Registro de Vehículo'), findsOneWidget);
    expect(find.text('NÚMERO DE PLACA'), findsOneWidget);
    expect(find.text('Carro'), findsOneWidget);
    expect(find.text('Moto'), findsOneWidget);

    // Complete vehicle setup
    final plateField = find.byType(TextField).first;
    await tester.enterText(plateField, 'ABC-123');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continuar al inicio  →'));
    await tester.pumpAndSettle();

    // Verify landed on HomeScreen
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('User advances to parking setup after registering as parking owner', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
      ],
    );
    container.read(userRoleStateProvider.notifier).setRole(UserRole.guest);

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
    router.go('/register');
    await tester.pumpAndSettle();

    // Select "Tengo parqueadero"
    await tester.tap(find.text('Tengo parqueadero'));
    await tester.pumpAndSettle();

    // Enter registration fields
    final textFields = find.byType(TextField);
    await tester.enterText(textFields.at(0), 'María Restrepo');
    await tester.enterText(textFields.at(1), 'maria@ejemplo.com');
    await tester.enterText(textFields.at(2), 'Password123');
    await tester.pumpAndSettle();

    // Tap Continuar
    await tester.tap(find.text('Continuar  →'));
    await tester.pumpAndSettle();

    // Verify ParkingSetupScreen is displayed
    expect(find.text('Registro de Parqueadero'), findsOneWidget);
    expect(find.text('NOMBRE DEL PARQUEADERO'), findsOneWidget);
    expect(find.text('UBICACIÓN'), findsOneWidget);
    expect(find.text('HORA DE APERTURA'), findsOneWidget);
    expect(find.text('HORA DE CIERRE'), findsOneWidget);
    expect(find.text('ESPACIOS CARROS'), findsOneWidget);
    expect(find.text('ESPACIOS MOTOS'), findsOneWidget);

    // Complete parking setup
    final nameField = find.byType(TextField).at(0);
    final addressField = find.byType(TextField).at(1);
    await tester.enterText(nameField, 'Parqueadero El Sol');
    await tester.enterText(addressField, 'Carrera 7 # 45-20');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Publicar y Gestionar  →'));
    await tester.pumpAndSettle();

    // Verify user role was updated to parkingOwner
    expect(container.read(currentUserRoleProvider), UserRole.parkingOwner);
  });
}
