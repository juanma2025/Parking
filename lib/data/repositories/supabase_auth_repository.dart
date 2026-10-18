import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/failure.dart';
import '../../domain/entities/domain_entities.dart';
import '../../domain/repositories/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient? _customClient;

  SupabaseAuthRepository([SupabaseClient? client]) : _customClient = client;

  SupabaseClient? get _clientOrNull {
    if (_customClient != null) return _customClient;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  SupabaseClient get _client {
    final client = _clientOrNull;
    if (client == null) {
      throw const NetworkFailure('Servicio de Supabase no disponible o no inicializado.');
    }
    return client;
  }

  @override
  User? get currentUser => _clientOrNull?.auth.currentUser;

  @override
  Session? get currentSession => _clientOrNull?.auth.currentSession;

  @override
  Stream<AuthState> get authStateChanges =>
      _clientOrNull?.auth.onAuthStateChange ?? const Stream.empty();

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

    try {
      final res = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
          'role': role.toDbValue(),
        },
      );

      // Verify immediate session
      if (res.session == null) {
        throw const EmailConfirmationPendingFailure(
          'No se inició sesión automáticamente. La opción "Confirm email" debe estar desactivada en Supabase.',
        );
      }

      return res;
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('already registered') || msg.contains('user already exists')) {
        throw const EmailAlreadyRegisteredFailure('Este correo ya se encuentra registrado. Inicia sesión.');
      } else if (msg.contains('weak') || msg.contains('password')) {
        throw const WeakPasswordFailure('La contraseña es demasiado débil o tiene menos de 8 caracteres.');
      } else {
        throw AuthFailure(e.message);
      }
    } on SocketException catch (_) {
      throw const NetworkFailure('Error de conexión. Revisa tu acceso a internet.');
    } catch (e) {
      if (e is Failure) rethrow;
      throw UnknownFailure('Ocurrió un error al registrar la cuenta: $e');
    }
  }

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      try {
        await logSecurityEvent(
          eventType: 'login',
          deviceInfo: 'Parking App Client',
        );
      } catch (_) {
        // Security audit failure should not prevent legitimate login
      }

      return res;
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('invalid login credentials') || msg.contains('invalid credentials')) {
        throw const InvalidCredentialsFailure('Correo o contraseña incorrectos. Verifica tus datos.');
      } else if (msg.contains('email not confirmed')) {
        throw const EmailConfirmationPendingFailure('El correo no ha sido confirmado.');
      } else {
        throw AuthFailure(e.message);
      }
    } on SocketException catch (_) {
      throw const NetworkFailure('Error de conexión. Revisa tu acceso a internet.');
    } catch (e) {
      if (e is Failure) rethrow;
      throw UnknownFailure('Ocurrió un error al iniciar sesión: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await logSecurityEvent(
        eventType: 'logout',
        deviceInfo: 'Parking App Client',
      );
    } catch (_) {}

    await _client.auth.signOut();
  }

  @override
  Future<Profile?> getProfile(String userId) async {
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data == null) return null;

      return Profile(
        id: data['id'] as String,
        fullName: data['full_name'] as String?,
        phone: data['phone'] as String?,
        role: UserRole.fromString(data['role'] as String?),
        avatarUrl: data['avatar_url'] as String?,
        createdAt: data['created_at'] != null ? DateTime.tryParse(data['created_at'] as String) : null,
        updatedAt: data['updated_at'] != null ? DateTime.tryParse(data['updated_at'] as String) : null,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<UserRole> fetchUserRole(String userId) async {
    try {
      final data = await _client
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .maybeSingle();

      if (data == null) return UserRole.guest;
      return UserRole.fromString(data['role'] as String?);
    } catch (_) {
      return UserRole.guest;
    }
  }

  @override
  Future<void> logSecurityEvent({
    required String eventType,
    String? deviceInfo,
  }) async {
    await _client.rpc(
      'log_security_event',
      params: {
        'event_type': eventType,
        'device_info': ?deviceInfo,
      },
    );
  }
}
