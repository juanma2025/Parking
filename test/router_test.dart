import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:parking_app/core/router/app_router.dart';
import 'package:parking_app/domain/entities/user_role.dart';
import 'package:parking_app/presentation/auth/auth_providers.dart';

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
    expect(find.text('Pantalla: Login'), findsOneWidget);
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
    expect(find.text('Pantalla: Inicio'), findsOneWidget);
  });
}
