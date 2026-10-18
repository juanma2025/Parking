import 'package:supabase_flutter/supabase_flutter.dart';
import '../entities/domain_entities.dart';

abstract class AuthRepository {
  User? get currentUser;
  Session? get currentSession;
  Stream<AuthState> get authStateChanges;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    required UserRole role,
  });

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<Profile?> getProfile(String userId);

  Future<UserRole> fetchUserRole(String userId);

  Future<void> logSecurityEvent({
    required String eventType,
    String? deviceInfo,
  });
}
