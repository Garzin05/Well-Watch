import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projetowell/theme.dart';

class RegistrationSuccessScreen extends StatelessWidget {
  final String userType;
  final String userName;

  const RegistrationSuccessScreen({
    super.key,
    required this.userType,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1214), // Azul escuro padrão Well Watch
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ícone de sucesso animado
                Pulse(
                  infinite: true,
                  duration: const Duration(seconds: 2),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: LightModeColors.lightSecondary,
                    size: 120,
                  ),
                ),
                const SizedBox(height: 40),

                // Título principal
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  child: Text(
                    'Cadastro Concluído!',
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Saudação personalizada
                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  child: Text(
                    'Olá, $userName!',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Mensagem específica do tipo de usuário
                FadeInUp(
                  duration: const Duration(milliseconds: 900),
                  child: Text(
                    userType == 'patient'
                        ? 'Bem-vindo(a)! Agora você pode agendar consultas e acompanhar sua saúde com facilidade.'
                        : 'Parabéns! Seu perfil foi criado. Agora você pode gerenciar pacientes e oferecer seus cuidados.',
                    style: GoogleFonts.poppins(
                      color: Colors.white60,
                      fontSize: 16,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 60),

                // Botão principal: Ir para o Início
                FadeInUp(
                  duration: const Duration(milliseconds: 1100),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: LightModeColors.lightSecondary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 6,
                      ),
                      child: Text(
                        'Ir para o Início',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Botão secundário: Voltar para o Login
                FadeInUp(
                  duration: const Duration(milliseconds: 1200),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: Text(
                      'Voltar para o Login',
                      style: GoogleFonts.poppins(
                        color: LightModeColors.lightSecondary,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Pequena assinatura estética
                FadeInUp(
                  duration: const Duration(milliseconds: 1300),
                  child: Text(
                    'Well Watch • Cuidando de você',
                    style: GoogleFonts.poppins(
                      color: Colors.white38,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
