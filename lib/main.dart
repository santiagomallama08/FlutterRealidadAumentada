import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 👈 para leer tu .env
import 'package:ai_preview_studio/core/config/app_initializer.dart';
import 'package:ai_preview_studio/core/config/app_theme.dart';
import 'package:ai_preview_studio/presentation/pages/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Carga las variables del archivo .env (incluye la clave de Gemini)
  await dotenv.load();

  // 🔹 Inicializa Supabase y SQLite
  await AppInitializer.init();

  // 🔹 Arranca la app con Riverpod
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Preview Studio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const LoginPage(),
    );
  }
}
