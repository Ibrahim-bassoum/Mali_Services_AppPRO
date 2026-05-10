import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import ajouté
import 'package:app_mali_services_pro/services/api_service.dart';
import 'home_screen.dart';
import 'package:intl/intl.dart'; 
import 'package:app_mali_services_pro/models/Category.dart'; // Importation de ta classe Category

class RegisterProScreen extends StatefulWidget {
  const RegisterProScreen({super.key});

  @override
  State<RegisterProScreen> createState() => _RegisterProScreenState();
}

class _RegisterProScreenState extends State<RegisterProScreen> {
  // Étape actuelle du formulaire (1: Informations, 2: Sécurité, 3: Profil Pro)
  int _currentStep = 1;
  bool _isLoading = false; // Permet de suivre l'état de soumission
  bool _isLoadingCategories = true; // État de chargement des catégories depuis l'API
  final ApiService _apiService = ApiService();

  // Liste dynamique des catégories récupérées du serveur
  List<Category> _categories = [];

  // Contrôleurs de saisie
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _dateNaissanceController = TextEditingController();
  String _formattedDateForApi = "";
  
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _experienceController = TextEditingController();
  String? _selectedZone;
  int? _selectedCategoryId; // L'ID numérique envoyé à Laravel

  // États pour afficher/masquer le mot de passe
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Couleurs de la charte graphique MaliServices
  final Color _primaryDark = const Color(0xFF00235B); // Bleu foncé
  final Color _accentBlue = const Color(0xFF2F66F6);  // Bleu actif
  final Color _greyText = const Color(0xFF6B7280);    // Gris secondaire
  final Color _bgLight = const Color(0xFFF8F9FA);     // Fond très clair

  @override
  void initState() {
    super.initState();
    _loadCategories(); // Charge les catégories dès l'ouverture de l'écran
  }

  // --- CHARGEMENT DES CATÉGORIES DEPUIS L'API ---
  Future<void> _loadCategories() async {
    try {
      final List<Category> categories = await _apiService.getCategories();
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
      });
    } catch (e) {
      // En cas d'erreur de connexion, on charge des catégories par défaut pour que l'écran reste fonctionnel
      setState(() {
        _categories = [
          Category(id: 1, name: "Plomberie", icon: ""),
          Category(id: 2, name: "Électricité", icon: ""),
          Category(id: 3, name: "Maçonnerie", icon: ""),
          Category(id: 4, name: "Peinture", icon: ""),
          Category(id: 5, name: "Menuiserie", icon: ""),
        ];
        _isLoadingCategories = false;
      });
      _showSnackBar("Connexion au serveur impossible. Chargement des métiers par défaut.", Colors.orange);
    }
  }

  // --- MÉTHODE SNACKBAR ---
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // --- LOGIQUE D'APPEL DE L'API POUR INSCRIPTION ---
  Future<void> _registerPro() async {
    if (_phoneController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar("Veuillez remplir votre numéro et mot de passe.", Colors.red);
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar("Les mots de passe ne correspondent pas.", Colors.red);
      return;
    }

    if (_selectedCategoryId == null) {
      _showSnackBar("Veuillez choisir une catégorie professionnelle.", Colors.red);
      return;
    }

    setState(() {
      _isLoading = true; // Lance le chargement visuel
    });

    try {
      // Appel de l'API avec l'ID numérique de la catégorie
      final response = await _apiService.register(
        name: _nomController.text.trim(),
        firstname: _prenomController.text.trim(),
        birthDate: _formattedDateForApi,
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
        role: 'pro',
        categoryId: _selectedCategoryId.toString(), // Envoi de l'ID à la place du texte
        experienceYears: _experienceController.text.trim(),
        interventionZone: _selectedZone,
        specialty: null, 
      );

      if (response['status'] == 'success') {
        // --- MODIFICATION ICI : SAUVEGARDE DU NOM POUR LE HEADER ---
        final apiData = response['data'];
        final userData = apiData['user']; 

        final prefs = await SharedPreferences.getInstance();
        
        // Sauvegarde du nom (ex: Sali) pour écraser l'ancien (ex: Hadi)
        String proName = userData?['name'] ?? _nomController.text.trim();
        await prefs.setString('user_name', proName);

        // Sauvegarde du token
        if (apiData != null && apiData['access_token'] != null) {
          await prefs.setString('auth_token', apiData['access_token']);
        }
        // --- FIN MODIFICATION ---

        _showSnackBar("Compte créé avec succès !", Colors.green);

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        }
      } else {
        _showSnackBar(response['message'] ?? "Erreur lors de l'inscription.", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Impossible de joindre le serveur. Vérifie ta connexion.", Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Action du bouton de validation d'étape
  void _handleNextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
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
              ? null 
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
            _buildStepIndicator(),
            
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
                    
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleNextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryDark,
                          disabledBackgroundColor: _primaryDark.withOpacity(0.6),
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
                    
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Vous avez déjà un compte ? ", style: TextStyle(color: _greyText)),
                          GestureDetector(
                            onTap: _isLoading ? null : () => Navigator.pop(context),
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
        _isLoadingCategories
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: CircularProgressIndicator(),
                ),
              )
            : Row(
                children: [
                  Expanded(
                    child: _buildCategoryDropdownField(
                      value: _selectedCategoryId,
                      hint: "Sélectionnez votre catégorie",
                      icon: Icons.work_outline,
                      items: _categories,
                      onChanged: (int? value) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                      },
                    ),
                  ),
                  // Si on est en mode secours (pas d'API), on affiche un bouton pour retenter le coup
                  if (_categories.length <= 5 && _categories.any((c) => c.icon.isEmpty))
                    IconButton(
                      icon: Icon(Icons.sync, color: _accentBlue),
                      tooltip: "Recharger depuis le serveur",
                      onPressed: () {
                        setState(() {
                          _isLoadingCategories = true;
                        });
                        _loadCategories();
                      },
                    ),
                ],
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
        _buildZoneDropdownField(
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
        enabled: !_isLoading,
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

  // Dropdown pour les catégories dynamiques
  Widget _buildCategoryDropdownField({
    required int? value,
    required String hint,
    required IconData icon,
    required List<Category> items,
    required ValueChanged<int?> onChanged,
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
      child: DropdownButtonFormField<int>(
        value: value,
        hint: Text(hint, style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
        icon: Icon(Icons.expand_more, color: _primaryDark),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: _primaryDark),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        items: _isLoading 
            ? null 
            : items.map((Category cat) {
                return DropdownMenuItem<int>(
                  value: cat.id, // L'ID (ex: 1) est transmis
                  child: Text(cat.name, style: TextStyle(color: _primaryDark)), // Le nom est affiché
                );
              }).toList(),
        onChanged: _isLoading ? null : onChanged,
      ),
    );
  }

  // Dropdown pour les zones (statiques)
  Widget _buildZoneDropdownField({
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
            ? null 
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
    if (_isLoading) return; 
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        String year = picked.year.toString();
        String month = picked.month.toString().padLeft(2, '0');
        String day = picked.day.toString().padLeft(2, '0');
        
        // 1. Ce que l'utilisateur voit à l'écran (ex: 08/08/1995)
        _dateNaissanceController.text = "$day/$month/$year";
        
        // 2. Ce qu'on sauvegarde en arrière-plan pour l'API Laravel (ex: 1995-08-08)
        _formattedDateForApi = "$year-$month-$day";
      });
    }
  }
}