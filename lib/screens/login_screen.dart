import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:app_mali_services_pro/screens/home_screen.dart'; // Supposons que ton Dashboard s'appelle HomeScreen

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // CONTRÔLEURS
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  
  // ÉTAT DE LA PAGE
  bool _isLoading = false;
  bool _obscurePassword = true;

  // COULEURS DU DESIGN
  final Color _primaryColor = const Color(0xFF00235B); // Ton bleu foncé fétiche
  final Color _greyColor = const Color(0xFF6B7280);

  // --- GESTION DE LA CONNEXION ---
  void _handleLogin() async {
    // Validation locale rapide
    if (_phoneController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      _showSnackBar("Veuillez remplir tous les champs", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    // Dialogue de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Appel à l'API
    final response = await _apiService.login(
      _phoneController.text.trim(),
      _passwordController.text,
    );

    Navigator.pop(context); // Fermer le chargement
    setState(() => _isLoading = false);

    if (response['status'] == 'success') {
      _showSnackBar("Connexion réussie !", Colors.green);
      
      // Redirection vers le Dashboard en nettoyant la pile de navigation
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false, // Efface toutes les pages précédentes
      );
    } else {
      // Afficher l'erreur renvoyée par Laravel (ex: Identifiants incorrects)
      _showSnackBar(response['message'], Colors.red);
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
            crossAxisAlignment: CrossAxisAlignment.center, // Centrer le contenu
            children: [
              const SizedBox(height: 30),
              
              // --- TON LOGO ICI ---
              Image.asset(
                'assets/logo.png', // Chemin exact de ton logo
                height: 100,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.handyman, size: 80, color: _primaryColor),
              ),
              const SizedBox(height: 25),
              
              // TITRE ET SOUS-TITRE
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
              const SizedBox(height: 50),

              // --- CHAMPS DE SAISIE (DESIGN MALI) ---
              
              // Champ Téléphone
              _buildCustomField(
                controller: _phoneController,
                label: "Numéro de téléphone",
                icon: Icons.phone,
                isPhone: true,
              ),
              const SizedBox(height: 20),

              // Champ Mot de passe
              _buildCustomField(
                controller: _passwordController,
                label: "Mot de passe",
                icon: Icons.lock,
                obscure: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: _primaryColor),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              
              // Lien mot de passe oublié (Optionnel)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () { /* Action mot de passe oublié */ },
                  child: Text("Mot de passe oublié ?", style: TextStyle(color: _primaryColor, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 40),

              // --- BOUTON SE CONNECTER ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    "Se connecter",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              
              // LIEN INSCRIPTION
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Nouveau partenaire ? "),
                  GestureDetector(
                    onTap: () { /* Redirection vers RegisterProScreen */ },
                    child: Text(
                      "Créer un compte",
                      style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET UTILITAIRE POUR LES CHAMPS (Réutilisable) ---
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
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryColor, width: 2),
        ),
      ),
    );
  }
}