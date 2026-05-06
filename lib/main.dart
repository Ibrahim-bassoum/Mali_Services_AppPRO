import 'package:flutter/material.dart';
import 'package:app_mali_services_pro/screens/welcome_screen.dart'; // Assure-toi que le nom du fichier est correct
// import 'register_pro_screen.dart'; // Utile si tu veux tester l'inscription direct

void main() {
  // On s'assure que les services Flutter sont bien initialisés
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Enlève la petite bannière "Debug" en haut à droite
      debugShowCheckedModeBanner: false,
      
      title: 'MaliServices Pro',
      
      // Thème global de l'application
      theme: ThemeData(
        useMaterial3: true,
        // On définit le bleu foncé de ton design comme couleur principale
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00235B),
          primary: const Color(0xFF00235B),
        ),
        // Style par défaut des champs de texte
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00235B), width: 2),
          ),
        ),
      ),

      // L'écran de démarrage de l'application
      home: const WelcomeScreen(), 
    );
  }
}