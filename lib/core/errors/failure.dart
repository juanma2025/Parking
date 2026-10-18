sealed class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String? message]) : super(message ?? 'Revisa tu conexión a internet.');
}

class AuthFailure extends Failure {
  const AuthFailure([String? message]) : super(message ?? 'Credenciales inválidas o sesión expirada.');
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure([String? message])
      : super(message ?? 'Correo o contraseña incorrectos. Verifica tus datos.');
}

class EmailAlreadyRegisteredFailure extends AuthFailure {
  const EmailAlreadyRegisteredFailure([String? message])
      : super(message ?? 'Este correo ya se encuentra registrado. Inicia sesión.');
}

class WeakPasswordFailure extends AuthFailure {
  const WeakPasswordFailure([String? message])
      : super(message ?? 'La contraseña debe tener al menos 8 caracteres.');
}

class EmailConfirmationPendingFailure extends AuthFailure {
  const EmailConfirmationPendingFailure([String? message])
      : super(message ?? 'No se inició sesión automáticamente. Verifica la configuración de confirmación de correo en Supabase.');
}

class ValidationFailure extends Failure {
  const ValidationFailure([String? message]) : super(message ?? 'Por favor, verifica la información ingresada.');
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([String? message]) : super(message ?? 'No se encontró el recurso solicitado.');
}

class ConflictFailure extends Failure {
  const ConflictFailure([String? message]) : super(message ?? 'Ya existe un registro con esta información.');
}

class UnknownFailure extends Failure {
  const UnknownFailure([String? message]) : super(message ?? 'Ocurrió un error inesperado. Inténtalo más tarde.');
}
