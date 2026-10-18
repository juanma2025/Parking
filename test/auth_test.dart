import 'package:flutter_test/flutter_test.dart';
import 'package:parking_app/core/errors/failure.dart';
import 'package:parking_app/domain/entities/domain_entities.dart';
import 'package:parking_app/domain/usecases/auth_usecases.dart';
import 'helpers/fake_auth_repository.dart';

void main() {
  group('Auth Layer Tests', () {
    late FakeAuthRepository fakeRepo;
    late SignUpUseCase signUpUseCase;
    late SignInUseCase signInUseCase;
    late SignOutUseCase signOutUseCase;
    late LogSecurityEventUseCase logSecurityEventUseCase;

    setUp(() {
      fakeRepo = FakeAuthRepository();
      signUpUseCase = SignUpUseCase(fakeRepo);
      signInUseCase = SignInUseCase(fakeRepo);
      signOutUseCase = SignOutUseCase(fakeRepo);
      logSecurityEventUseCase = LogSecurityEventUseCase(fakeRepo);
    });

    test('SignUp succeeds with immediate session and stores role in metadata', () async {
      final res = await signUpUseCase.execute(
        email: 'juan@test.com',
        password: 'Password123!',
        fullName: 'Juan Manuel',
        phone: '3001234567',
        role: UserRole.vehicleOwner,
      );

      expect(res.session, isNotNull);
      expect(res.user?.userMetadata?['full_name'], 'Juan Manuel');
      expect(res.user?.userMetadata?['role'], 'vehicle_owner');
      expect(fakeRepo.currentUser, isNotNull);
    });

    test('SignUp fails when password has fewer than 8 characters', () async {
      expect(
        () => signUpUseCase.execute(
          email: 'short@test.com',
          password: 'short',
          fullName: 'Short Pass',
          role: UserRole.vehicleOwner,
        ),
        throwsA(isA<WeakPasswordFailure>()),
      );
    });

    test('SignUp throws EmailConfirmationPendingFailure if session is null', () async {
      fakeRepo.shouldReturnNullSessionOnSignUp = true;

      expect(
        () => signUpUseCase.execute(
          email: 'confirm@test.com',
          password: 'Password123!',
          fullName: 'No Session',
          role: UserRole.parkingOwner,
        ),
        throwsA(isA<EmailConfirmationPendingFailure>()),
      );
    });

    test('SignIn logs security event and sets current session', () async {
      final res = await signInUseCase.execute(
        email: 'juan@test.com',
        password: 'Password123!',
      );

      expect(res.session, isNotNull);
      expect(fakeRepo.currentUser, isNotNull);
      expect(fakeRepo.lastLoggedEvent, 'login');
    });

    test('SignIn throws InvalidCredentialsFailure on wrong password', () async {
      fakeRepo.shouldFailSignIn = true;

      expect(
        () => signInUseCase.execute(
          email: 'wrong@test.com',
          password: 'BadPassword123',
        ),
        throwsA(isA<InvalidCredentialsFailure>()),
      );
    });

    test('SignOut logs logout event and clears current user and session', () async {
      await signInUseCase.execute(email: 'test@test.com', password: 'Password123');
      expect(fakeRepo.currentUser, isNotNull);

      await signOutUseCase.execute();
      expect(fakeRepo.currentUser, isNull);
      expect(fakeRepo.lastLoggedEvent, 'logout');
    });

    test('LogSecurityEventUseCase delegates to repository', () async {
      await logSecurityEventUseCase.execute(
        eventType: 'role_checked',
        deviceInfo: 'Android 14',
      );

      expect(fakeRepo.lastLoggedEvent, 'role_checked');
      expect(fakeRepo.lastLoggedDeviceInfo, 'Android 14');
    });
  });
}
