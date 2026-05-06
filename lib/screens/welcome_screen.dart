import 'package:flutter/material.dart';
import 'register_pro_screen.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF00235B);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 50),
                      // Affichage du logo
                      Image.asset(
                        'assets/logo.png', 
                        height: 100,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.handyman, size: 100, color: primaryColor),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "MaliServices Pro",
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryColor),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "Trouvez. Réservez. C’est réglé.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: primaryColor),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // BOUTONS EN BAS
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterProScreen())),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Créer un compte", style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Vous avez déjà un compte ? "),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                        child: const Text(
                          "Se connecter",
                          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}