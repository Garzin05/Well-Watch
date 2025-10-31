import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projetowell/theme.dart';
import 'package:provider/provider.dart';
import 'package:projetowell/services/auth_service.dart';
import 'package:projetowell/services/health_service.dart';
import 'package:projetowell/router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
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
      child: MaterialApp(
        title: 'Well Watch',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode
            .dark, // Use ThemeMode.system para seguir o tema do sistema
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.login,
        routes: appRoutes(),
      ),
    );
  }
}
