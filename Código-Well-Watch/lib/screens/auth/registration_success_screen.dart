import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projetowell/services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';

class RegistrationSuccessScreen extends StatefulWidget {
  final String userType;   // patient ou doctor
  final String userName;
  final String email;
  final String password;

  const RegistrationSuccessScreen({
    super.key,
    required this.userType,
    required this.userName,
    required this.email,
    required this.password,
  });

  @override
  State<RegistrationSuccessScreen> createState() =>
      _RegistrationSuccessScreenState();
}

class _RegistrationSuccessScreenState extends State<RegistrationSuccessScreen> {
  bool _isLoggingIn = false;

  Future<void> _autoLogin() async {
    setState(() => _isLoggingIn = true);

    final auth = Provider.of<AuthService>(context, listen: false);
    final success = await auth.login(
      widget.email,
      widget.password,
      role: widget.userType,
    );

    setState(() => _isLoggingIn = false);

    if (success) {
      Navigator.pushReplacementNamed(
        context,
        widget.userType == "doctor" ? "/doctor_menu" : "/home",
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erro ao entrar automaticamente. Faça login manual."),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1214),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.greenAccent, size: 120),

                const SizedBox(height: 20),

                Text(
                  "Cadastro Concluído!",
                  style: GoogleFonts.poppins(
                      fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Text(
                  "Olá, ${widget.userName}",
                  style: GoogleFonts.poppins(fontSize: 20, color: Colors.white70),
                ),

                const SizedBox(height: 40),

                // BOTÃO INICIAR LOGIN
                ElevatedButton(
                  onPressed: _isLoggingIn ? null : _autoLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 80),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isLoggingIn
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Iniciar Login",
                          style: TextStyle(color: Colors.black, fontSize: 18),
                        ),
                ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, "/login");
                  },
                  child: const Text(
                    "Voltar ao Login",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
