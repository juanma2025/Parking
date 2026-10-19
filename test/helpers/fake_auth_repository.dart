import 'dart:async';
import 'package:parking_app/core/errors/failure.dart';
import 'package:parking_app/domain/entities/domain_entities.dart';
import 'package:parking_app/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeAuthRepository implements AuthRepository {
  User? _currentUser;
  Session? _currentSession;
  UserRole _userRole = UserRole.vehicleOwner;
  final StreamController<AuthState> _authStateController = StreamController<AuthState>.broadcast();

  bool shouldFailSignIn = false;
  bool shouldReturnNullSessionOnSignUp = false;
  String? lastLoggedEvent;
  String? lastLoggedDeviceInfo;

  void setCurrentUser(User? user, {UserRole role = UserRole.vehicleOwner}) {
    _currentUser = user;
    _userRole = role;
    if (user != null) {
      _currentSession = Session(
        accessToken: 'fake-token',
        tokenType: 'bearer',
        user: user,
      );
      _authStateController.add(AuthState(AuthChangeEvent.signedIn, _currentSession));
    } else {
      _currentSession = null;
      _authStateController.add(const AuthState(AuthChangeEvent.signedOut, null));
    }
  }

  @override
  User? get currentUser => _currentUser;

  @override
  Session? get currentSession => _currentSession;

  @override
  Stream<AuthState> get authStateChanges => _authStateController.stream;

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    required UserRole role,
  }) async {
    if (password.length < 8) {
      throw const WeakPasswordFailure('La contraseña debe tener al menos 8 caracteres.');
    }

    if (shouldReturnNullSessionOnSignUp) {
      throw const EmailConfirmationPendingFailure(
        'No se inició sesión automáticamente. La opción "Confirm email" debe estar desactivada en Supabase.',
      );
    }

    final user = User(
      id: 'test-user-id',
      appMetadata: {},
      userMetadata: {'full_name': fullName, 'role': role.toDbValue()},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
    );

    final session = Session(
      accessToken: 'fake-token',
      tokenType: 'bearer',
      user: user,
    );

    _currentUser = user;
    _currentSession = session;
    _userRole = role;
    _authStateController.add(AuthState(AuthChangeEvent.signedIn, session));

    return AuthResponse(session: session, user: user);
  }

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    if (shouldFailSignIn) {
      throw const InvalidCredentialsFailure('Correo o contraseña incorrectos. Verifica tus datos.');
    }

    final user = User(
      id: 'test-user-id',
      appMetadata: {},
      userMetadata: {'full_name': 'Test User'},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
    );

    final session = Session(
      accessToken: 'fake-token',
      tokenType: 'bearer',
      user: user,
    );

    _currentUser = user;
    _currentSession = session;
    _authStateController.add(AuthState(AuthChangeEvent.signedIn, session));

    await logSecurityEvent(eventType: 'login', deviceInfo: 'Test Device');

    return AuthResponse(session: session, user: user);
  }

  @override
  Future<void> signOut() async {
    await logSecurityEvent(eventType: 'logout', deviceInfo: 'Test Device');
    _currentUser = null;
    _currentSession = null;
    _userRole = UserRole.guest;
    _authStateController.add(const AuthState(AuthChangeEvent.signedOut, null));
  }

  @override
  Future<Profile?> getProfile(String userId) async {
    if (_currentUser == null) return null;
    return Profile(
      id: userId,
      fullName: 'Test User',
      role: _userRole,
    );
  }

  @override
  Future<UserRole> fetchUserRole(String userId) async {
    return _userRole;
  }

  @override
  Future<void> logSecurityEvent({
    required String eventType,
    String? deviceInfo,
  }) async {
    lastLoggedEvent = eventType;
    lastLoggedDeviceInfo = deviceInfo;
  }
}
