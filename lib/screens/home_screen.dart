import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_mali_services_pro/widgets/home/header_Profile_widget.dart';
import 'package:app_mali_services_pro/widgets/home/quick_stats_widget.dart';
import 'package:app_mali_services_pro/widgets/home/pending_demands_widgets.dart';
import 'package:app_mali_services_pro/widgets/home/custom_bottom_navbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  // Initialisation à vide pour éviter le texte "Chargement..." trop long
  String _currentProName = ""; 

  final Map<String, String> _proData = {
    'revenue': '150 000',
    'missions': '45',
  };

  final List<Map<String, String>> _mockDemands = [
    {
      'id': '1',
      'serviceType': 'Dépannage plomberie',
      'location': 'Sébénikoro',
      'timeAgo': '15 min',
      'description': 'Fuite d\'eau importante dans la salle de bain.',
    },
    {
      'id': '2',
      'serviceType': 'Réparation Électricité',
      'location': 'Baco-Djikoroni',
      'timeAgo': '30 min',
      'description': 'Disjoncteur qui saute, besoin d\'un diagnostic.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadProData();
  }

  // MÉTHODE AMÉLIORÉE
  Future<void> _loadProData() async {
    final prefs = await SharedPreferences.getInstance();
    // On récupère le nom sauvegardé au Login ou au Register
    String? savedName = prefs.getString('user_name');
    
    // On vérifie si le widget est toujours affiché avant de faire setState
    if (mounted) {
      setState(() {
        _currentProName = savedName ?? "Prestataire";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      
      bottomNavigationBar: CustomBottomNavbar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),

      // Petit plus : RefreshIndicator permet de glisser vers le bas 
      // pour rafraîchir le nom ou les stats si besoin
      body: RefreshIndicator(
        onRefresh: _loadProData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), // Important pour le RefreshIndicator
          child: Column(
            children: [
              HeaderProfileWidget(
                // Si le nom est vide (pendant le chargement), on met un espace
                proName: _currentProName.isEmpty ? "..." : _currentProName, 
                initialOnlineStatus: true,
                onStatusChanged: (isOnline) {
                  print("Statut API à mettre à jour : $isOnline");
                },
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    QuickStatsWidget(
                      revenue: _proData['revenue']!,
                      missions: _proData['missions']!,
                    ),

                    const SizedBox(height: 25),

                    PendingDemandsWidget(
                      demandsList: _mockDemands,
                      onDemandPressed: (id) {
                        print("Détails de la demande : $id");
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}