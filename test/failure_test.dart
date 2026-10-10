import 'package:flutter_test/flutter_test.dart';
import 'package:parking_app/core/errors/failure.dart';

void main() {
  group('Failure tests', () {
    test('NetworkFailure has correct default message', () {
      const failure = NetworkFailure();
      expect(failure.message, 'Revisa tu conexión a internet.');
    });

    test('AuthFailure has correct default message', () {
      const failure = AuthFailure();
      expect(failure.message, 'Credenciales inválidas o sesión expirada.');
    });

    test('Custom message overrides default', () {
      const failure = ValidationFailure('Error específico');
      expect(failure.message, 'Error específico');
    });
  });
}
