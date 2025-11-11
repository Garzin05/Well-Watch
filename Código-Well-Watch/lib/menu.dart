import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:projetowell/theme.dart';
import 'package:projetowell/services/auth_service.dart';
import 'package:projetowell/services/health_service.dart';
import 'package:projetowell/router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<HealthService>(create: (_) => HealthService()),
      ],
      child: FutureBuilder<ThemeData>(
        future: loadTheme(),  // Carrega o tema de forma assíncrona
        builder: (context, snapshot) {
          // Enquanto o tema está carregando
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar o tema: ${snapshot.error}'));
          }

          final themeData = snapshot.data ?? ThemeData.light();  // Tema padrão caso haja erro

          return MaterialApp(
            title: 'Well Watch',
            theme: themeData,
            darkTheme: darkTheme.copyWith(
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: {
                  TargetPlatform.android: CupertinoPageTransitionsBuilder(),
                  TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                },
              ),
            ),
            themeMode: ThemeMode.dark, // Mantém o tema escuro
            debugShowCheckedModeBanner: false,
            initialRoute: AppRoutes.login,
            routes: {
              ...appRoutes(),  // Carrega suas rotas definidas
            },
          );
        },
      ),
    );
  }

  // Função que retorna um Future<ThemeData>
  Future<ThemeData> loadTheme() async {
    await Future.delayed(const Duration(seconds: 1));  // Simulando um atraso no carregamento do tema
    return ThemeData.dark();  // Retorna o tema desejado (aqui está com o tema escuro)
  }
}

extension on Future<ThemeData> {
}
