import 'package:flutter_test/flutter_test.dart';
import 'package:projetowell/services/auth_service.dart';

void main() {
  group('AuthService', () {
    late AuthService service;

    setUp(() {
      service = AuthService();
    });

    test('login com role correta retorna false (sem API)', () async {
      final ok = await service.login(
        'email@fake.com',
        'senhaqualquer',
        role: 'patient',
      );
      expect(ok, isFalse); // Sem backend → sempre false
    });

    test('não autentica usuário inexistente', () async {
      final ok = await service.login(
        'naoexiste@test.com',
        'senha',
        role: 'doctor',
      );
      expect(ok, isFalse);
    });
  });
}
