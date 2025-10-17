class AuthService {
  get username => null;

  Future<bool> login(String username, String password) async {
    // Simula um login: apenas se for admin/123456
    await Future.delayed(const Duration(seconds: 2));
    return username == 'admin' && password == '123456';
  }

  Future<void> socialLogin(String provider) async {
    // Simula um login social com atraso
    await Future.delayed(const Duration(seconds: 1));
    return;
  }
}
