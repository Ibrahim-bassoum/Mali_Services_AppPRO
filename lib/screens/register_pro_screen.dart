import 'package:flutter/material.dart';
import 'package:app_mali_services_pro/services/api_service.dart';
import 'home_screen.dart'; // Assure-toi que l'import de ton écran d'accueil est correct

class RegisterProScreen extends StatefulWidget {
  const RegisterProScreen({super.key});

  @override
  State<RegisterProScreen> createState() => _RegisterProScreenState();
}

class _RegisterProScreenState extends State<RegisterProScreen> {
  // Étape actuelle du formulaire (1: Informations, 2: Sécurité, 3: Profil Pro)
  int _currentStep = 1;
  bool _isLoading = false; // Permet de suivre l'état de soumission
  final ApiService _apiService = ApiService();

  // Contrôleurs de saisie
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _dateNaissanceController = TextEditingController();
  
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _experienceController = TextEditingController();
  String? _selectedCategory;
  String? _selectedZone;

  // États pour afficher/masquer le mot de passe
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Couleurs de la charte graphique MaliServices
  final Color _primaryDark = const Color(0xFF00235B); // Bleu foncé
  final Color _accentBlue = const Color(0xFF2F66F6);  // Bleu actif
  final Color _greyText = const Color(0xFF6B7280);    // Gris secondaire
  final Color _bgLight = const Color(0xFFF8F9FA);     // Fond très clair

  // --- LOGIQUE D'APPEL DE L'API ---
  Future<void> _registerPro() async {
    // Petites validations de sécurité avant d'appeler l'API
    if (_phoneController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar("Veuillez remplir votre numéro et mot de passe.", Colors.red);
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar("Les mots de passe ne correspondent pas.", Colors.red);
      return;
    }

    setState(() {
      _isLoading = true; // Lance le chargement visuel sur le bouton
    });

    try {
      // Appel de l'API avec les paramètres nommés exacts
      final response = await _apiService.register(
        name: _nomController.text.trim(),
        firstname: _prenomController.text.trim(),
        birthDate: _dateNaissanceController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
        role: 'pro', // On passe 'pro' pour que le backend valide la catégorie, l'expérience et la zone
        categoryId: _selectedCategory,
        experienceYears: _experienceController.text.trim(),
        interventionZone: _selectedZone,
        specialty: null, // Non utilisé pour l'instant
      );

      if (response['status'] == 'success') {
        // Enregistre le token si ton API le renvoie dans response['data']['token']
        if (response['data'] != null && response['data']['token'] != null) {
          await _apiService.saveToken(response['data']['token']);
        }

        _showSnackBar("Compte créé avec succès !", Colors.green);

        // Navigation vers la page Home en nettoyant l'historique
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        }
      } else {
        // Affiche l'erreur renvoyée par le serveur (ex: numéro déjà pris, etc.)
        _showSnackBar(response['message'] ?? "Erreur lors de l'inscription.", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Impossible de joindre le serveur. Vérifie ta connexion.", Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Arrête le chargement pour permettre de réessayer si besoin
        });
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Action du bouton de validation d'étape
  void _handleNextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      // Étape 3 atteinte : Soumission finale vers l'API
      _registerPro();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      appBar: AppBar(
        backgroundColor: _bgLight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _primaryDark),
          onPressed: _isLoading 
              ? null // Désactive le bouton retour pendant le chargement
              : () {
                  if (_currentStep > 1) {
                    setState(() => _currentStep--);
                  } else {
                    Navigator.pop(context);
                  }
                },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. BARRE DE PROGRESSION DES ÉTAPES
            _buildStepIndicator(),
            
            // 2. FORMULAIRE DYNAMIQUE DÉFILANT (Évite l'overflow du clavier)
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_currentStep == 1) _buildStepOne(),
                    if (_currentStep == 2) _buildStepTwo(),
                    if (_currentStep == 3) _buildStepThree(),
                    
                    const SizedBox(height: 40),
                    
                    // BOUTON PRINCIPAL (Avec indicateur de chargement circulaire si en cours)
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleNextStep, // Désactive le clic si chargement
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryDark,
                          disabledBackgroundColor: _primaryDark.withOpacity(0.6), // Rendu discret au chargement
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading && _currentStep == 3
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                _currentStep == 3 ? "Créer mon compte" : "Continuer",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // LIEN CONNEXION
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Vous avez déjà un compte ? ", style: TextStyle(color: _greyText)),
                          GestureDetector(
                            onTap: _isLoading 
                                ? null // Empêche de revenir en arrière pendant la requête
                                : () => Navigator.pop(context),
                            child: Text(
                              "Se connecter",
                              style: TextStyle(
                                color: _isLoading ? _greyText : _accentBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- ÉTAPE 1 : INFORMATIONS PERSONNELLES ---
  Widget _buildStepOne() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Informations personnelles",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _primaryDark),
        ),
        const SizedBox(height: 8),
        Text(
          "Commençons par vos informations de base.",
          style: TextStyle(fontSize: 14, color: _greyText),
        ),
        const SizedBox(height: 30),
        
        _buildLabel("Nom"),
        _buildTextField(
          controller: _nomController,
          hint: "Entrez votre nom",
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 20),
        
        _buildLabel("Prénom"),
        _buildTextField(
          controller: _prenomController,
          hint: "Entrez votre prénom",
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 20),
        
        _buildLabel("Date de naissance"),
        _buildTextField(
          controller: _dateNaissanceController,
          hint: "JJ / MM / AAAA",
          icon: Icons.calendar_today_outlined,
          readOnly: true,
          onTap: () => _selectDate(context),
        ),
      ],
    );
  }

  // --- ÉTAPE 2 : SÉCURITÉ DU COMPTE ---
  Widget _buildStepTwo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Sécurité du compte",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _primaryDark),
        ),
        const SizedBox(height: 8),
        Text(
          "Protégez votre compte avec un mot de passe sécurisé.",
          style: TextStyle(fontSize: 14, color: _greyText),
        ),
        const SizedBox(height: 30),
        
        _buildLabel("Numéro de téléphone"),
        _buildTextField(
          controller: _phoneController,
          hint: "70 12 34 56",
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          prefix: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 12),
              const Text("🇲🇱", style: TextStyle(fontSize: 20)),
              const SizedBox(width: 6),
              Text("+223", style: TextStyle(fontWeight: FontWeight.bold, color: _primaryDark)),
              const SizedBox(width: 10),
              Container(width: 1, height: 20, color: Colors.grey.shade300),
              const SizedBox(width: 10),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        _buildLabel("Créer un mot de passe"),
        _buildTextField(
          controller: _passwordController,
          hint: "••••••••",
          icon: Icons.lock_outline,
          obscureText: _obscurePassword,
          suffix: IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: _primaryDark),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        const SizedBox(height: 20),
        
        _buildLabel("Confirmer le mot de passe"),
        _buildTextField(
          controller: _confirmPasswordController,
          hint: "••••••••",
          icon: Icons.lock_outline,
          obscureText: _obscureConfirmPassword,
          suffix: IconButton(
            icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: _primaryDark),
            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
          ),
        ),
      ],
    );
  }

  // --- ÉTAPE 3 : PROFIL PROFESSIONNEL ---
  Widget _buildStepThree() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Profil professionnel",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _primaryDark),
        ),
        const SizedBox(height: 8),
        Text(
          "Parlez-nous de votre métier et de votre expérience.",
          style: TextStyle(fontSize: 14, color: _greyText),
        ),
        const SizedBox(height: 30),
        
        _buildLabel("Catégorie de métier"),
        _buildDropdownField(
          value: _selectedCategory,
          hint: "Sélectionnez votre catégorie",
          icon: Icons.work_outline,
          items: ["Plomberie", "Électricité", "Maçonnerie", "Peinture", "Menuiserie"],
          onChanged: (value) => setState(() => _selectedCategory = value),
        ),
        const SizedBox(height: 20),
        
        _buildLabel("Années d'expérience"),
        _buildTextField(
          controller: _experienceController,
          hint: "Ex: 5",
          icon: Icons.trending_up_outlined,
          keyboardType: TextInputType.number,
          suffix: Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 15.0),
            child: Text("ans", style: TextStyle(color: _greyText, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 20),
        
        _buildLabel("Zone d'intervention"),
        _buildDropdownField(
          value: _selectedZone,
          hint: "Sélectionnez vos zones",
          icon: Icons.location_on_outlined,
          items: ["Sébénikoro", "Baco-Djikoroni", "Hamdallaye", "Kalaban Coura", "Badalabougou"],
          onChanged: (value) => setState(() => _selectedZone = value),
        ),
      ],
    );
  }

  // --- COMPOSANTS DE CONCEPTION GRAPHIQUE ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _primaryDark),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? prefix,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        enabled: !_isLoading, // Bloque la saisie pendant la requête
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: prefix ?? Icon(icon, color: _primaryDark),
          suffixIcon: suffix,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _accentBlue, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String hint,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        hint: Text(hint, style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
        icon: Icon(Icons.expand_more, color: _primaryDark),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: _primaryDark),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        items: _isLoading 
            ? null // Désactive le menu déroulant au chargement
            : items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: TextStyle(color: _primaryDark)),
                );
              }).toList(),
        onChanged: _isLoading ? null : onChanged,
      ),
    );
  }

  // --- WIDGET : BARRE D'ÉTAPE DYNAMIQUE (1 -> 2 -> 3) ---
  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 30.0),
      color: _bgLight,
      child: Row(
        children: [
          _buildStepCircle(1, "Infos"),
          _buildStepLine(1),
          _buildStepCircle(2, "Sécurité"),
          _buildStepLine(2),
          _buildStepCircle(3, "Profil"),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int step, String label) {
    bool isCompleted = _currentStep > step;
    bool isActive = _currentStep == step;

    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? _primaryDark
                : (isActive ? _accentBlue : Colors.white),
            border: Border.all(
              color: isCompleted || isActive ? Colors.transparent : Colors.grey.shade300,
              width: 2,
            ),
            boxShadow: isActive
                ? [BoxShadow(color: _accentBlue.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
                : [],
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Text(
                    "$step",
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int afterStep) {
    bool isPassed = _currentStep > afterStep;
    return Expanded(
      child: Container(
        height: 3,
        color: isPassed ? _primaryDark : Colors.grey.shade200,
      ),
    );
  }

  // Sélectionneur de date
  Future<void> _selectDate(BuildContext context) async {
    if (_isLoading) return; // Bloque le calendrier en plein chargement
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        String year = picked.year.toString();
        String month = picked.month.toString().padLeft(2,'0');
        String day = picked.day.toString().padLeft(2, '0');
        _dateNaissanceController.text = "$year-$month-$day";
      });
    
    
    }
  }
}