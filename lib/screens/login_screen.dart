import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'package:app_mali_services_pro/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // --- CONTRÔLEURS ---
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  
  // --- ÉTAT DE LA PAGE ---
  bool _isLoading = false;
  bool _obscurePassword = true;

  // --- DESIGN ---
  final Color _primaryColor = const Color(0xFF00235B); 
  final Color _greyColor = const Color(0xFF6B7280);

  // --- GESTION DE LA CONNEXION ---
  void _handleLogin() async {
    // 1. Validation locale
    if (_phoneController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      _showSnackBar("Veuillez remplir tous les champs", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    // Affichage du loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 2. Appel à l'API
      final response = await _apiService.login(
        _phoneController.text.trim(),
        _passwordController.text.trim(), // Ajout du trim ici aussi pour le mot de passe
      );

      if (!mounted) return;
      Navigator.pop(context); // Fermer le loader

      // 3. ANALYSE DE LA RÉPONSE (Synchronisée avec ton ApiService)
      // Ton ApiService renvoie {"status": "success", "data": ...}
      if (response != null && response['status'] == 'success') {
        
        // On récupère le contenu réel renvoyé par Laravel (qui est dans 'data')
        final apiData = response['data'];
        final userData = apiData['user']; 

        // 4. SAUVEGARDE LOCALE
        final prefs = await SharedPreferences.getInstance();
        
        // Sauvegarde du nom (C'est ici qu'on règle le problème de l'affichage "Artisan")
        String proName = userData['name'] ?? 'Prestataire';
        await prefs.setString('user_name', proName);
        
        // Sauvegarde du token (récupéré dans apiData)
        await prefs.setString('auth_token', apiData['access_token']);

        _showSnackBar("Bienvenue, $proName !", Colors.green);

        // 5. REDIRECTION
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      } else {
        // Erreur renvoyée par l'ApiService (ex: Identifiants incorrects)
        String errorMsg = response?['message'] ?? "Numéro ou mot de passe incorrect";
        _showSnackBar(errorMsg, Colors.red);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      print("ERREUR API : $e");
      _showSnackBar("Impossible de joindre le serveur. Vérifiez la connexion.", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, duration: const Duration(seconds: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // LOGO
              Image.asset(
                'assets/logo.png', 
                height: 100,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.handyman, size: 80, color: _primaryColor),
              ),
              const SizedBox(height: 20),
              
              Text(
                "MaliServices Pro",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _primaryColor),
              ),
              const SizedBox(height: 10),
              Text(
                "Connectez-vous pour accéder à vos demandes.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: _greyColor),
              ),
              const SizedBox(height: 40),

              _buildCustomField(
                controller: _phoneController,
                label: "Numéro de téléphone",
                icon: Icons.phone_android,
                isPhone: true,
              ),
              const SizedBox(height: 20),

              _buildCustomField(
                controller: _passwordController,
                label: "Mot de passe",
                icon: Icons.lock_outline,
                obscure: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: _primaryColor),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Se connecter",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Nouveau partenaire ? "),
                  GestureDetector(
                    onTap: () {
                      // Navigator.push... vers RegisterScreen
                    },
                    child: Text(
                      "Créer un compte",
                      style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    bool isPhone = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: _primaryColor),
        suffixIcon: suffixIcon,
        labelText: label,
        labelStyle: TextStyle(color: _greyColor),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryColor, width: 2),
        ),
      ),
    );
  }
}