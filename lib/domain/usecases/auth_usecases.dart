import 'package:supabase_flutter/supabase_flutter.dart';
import '../entities/user_role.dart';
import '../entities/domain_entities.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;
  SignUpUseCase(this.repository);

  Future<AuthResponse> execute({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    required UserRole role,
  }) {
    return repository.signUp(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
      role: role,
    );
  }
}

class SignInUseCase {
  final AuthRepository repository;
  SignInUseCase(this.repository);

  Future<AuthResponse> execute({
    required String email,
    required String password,
  }) {
    return repository.signIn(email: email, password: password);
  }
}

class SignOutUseCase {
  final AuthRepository repository;
  SignOutUseCase(this.repository);

  Future<void> execute() {
    return repository.signOut();
  }
}

class WatchAuthStateUseCase {
  final AuthRepository repository;
  WatchAuthStateUseCase(this.repository);

  Stream<AuthState> execute() {
    return repository.authStateChanges;
  }
}

class GetCurrentUserRoleUseCase {
  final AuthRepository repository;
  GetCurrentUserRoleUseCase(this.repository);

  Future<UserRole> execute(String userId) {
    return repository.fetchUserRole(userId);
  }
}

class LogSecurityEventUseCase {
  final AuthRepository repository;
  LogSecurityEventUseCase(this.repository);

  Future<void> execute({
    required String eventType,
    String? deviceInfo,
  }) {
    return repository.logSecurityEvent(
      eventType: eventType,
      deviceInfo: deviceInfo,
    );
  }
}
