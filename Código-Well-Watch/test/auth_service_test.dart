import 'package:flutter_test/flutter_test.dart';
import 'package:projetowell/services/auth_service.dart';

void main() {
  group('AuthService', () {
    final service = AuthService();

    test('login returns true for admin/123456', () async {
      final ok = await service.login('admin', '123456');
      expect(ok, isTrue);
    });

    test('login returns false for wrong credentials', () async {
      final ok = await service.login('user', 'wrong');
      expect(ok, isFalse);
    });
  });
}
