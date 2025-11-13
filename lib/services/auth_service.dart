class AuthService {
  /// Mock login - replace with real API call later.
  /// Simple demo: accept any non-empty username and password.
  Future<bool> login(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return username=="alejandro" && password=="1234";
  }
}
