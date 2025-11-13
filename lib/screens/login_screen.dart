import 'package:flutter/material.dart';
import '../styles/app_colors.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import '../services/auth_service.dart';
import 'menu_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final AuthService _auth = AuthService();
  bool _loading = false;

  Future<void> _doLogin() async {
    setState(() => _loading = true);
    try {
      final success = await _auth.login(_userController.text.trim(), _passController.text);
      if (!mounted) return;
      setState(() => _loading = false);
      final snack = SnackBar(content: Text(success ? 'Inicio de sesión correcto' : 'Usuario o contraseña inválidos'));
      ScaffoldMessenger.of(context).showSnackBar(snack);
      if (success) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MenuScreen()),
          (route) => false,
        );
      }
    } catch (e, st) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      // ignore: avoid_print
      print('Login error: $e\n$st');
    }
  }

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top banner
              Container(
                width: double.infinity,
                height: 150,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                ),
                child: const Center(
                  child: Text('LOGIN', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
              ),

              const SizedBox(height: 20),

              // Form area
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 18),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 6),
                    CustomTextField(label: 'Usuario', controller: _userController),
                    const SizedBox(height: 16),
                    CustomTextField(label: 'Contraseña', controller: _passController, obscure: true),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: width * 0.6,
                      child: PrimaryButton(
                        text: _loading ? 'Cargando...' : 'Iniciar Sesión',
                        onPressed: _loading ? () {} : _doLogin,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
