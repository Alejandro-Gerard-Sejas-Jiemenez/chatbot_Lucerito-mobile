

import 'package:shared_preferences/shared_preferences.dart';
import '../data/mock_data.dart';

class AuthService {
  // Simula login usando el usuario de mock_data.dart
  Future<bool> login(String username, String password) async {
    if (username == currentUser.username && password == currentUser.password) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', 'mock_token');
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }
}
