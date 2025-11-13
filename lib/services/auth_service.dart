class AuthService {
  /// Mock login - replace with real API call later.
  Future<bool> login(String username, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    // simple mock: accept any non-empty credentials for demo
    return username.isNotEmpty && password.isNotEmpty;
  }
}
