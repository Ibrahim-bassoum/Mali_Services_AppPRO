import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isOnline = true;
  int _currentIndex = 0;

  // Couleurs de la charte graphique de MaliServices
  final Color _primaryDark = const Color(0xFF00235B); // Bleu foncé
  final Color _accentGreen = const Color(0xFF4CD964); // Vert pour le statut actif
  final Color _bgLight = const Color(0xFFF8F9FA);     // Fond gris très clair

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      body: SafeArea(
        top: false, // Permet au header bleu de s'étendre sous la barre d'état
        child: Column(
          children: [
            // 1. EN-TÊTE BLEU FONCÉ (Profil, Salutations et Statut)
            _buildHeader(),

            // 2. ZONE DE CONTENU DÉFILANT
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statistiques statiques
                    _buildStatsSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Titre "Demandes à proximité"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Demandes à proximité",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _primaryDark,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Row(
                            children: [
                              Text("Voir plus", style: TextStyle(color: _primaryDark)),
                              Icon(Icons.chevron_right, size: 16, color: _primaryDark),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // LISTE DES CARTES DE DEMANDES STATIQUES
                    _buildDemandCard(
                      location: "Sébénikoro",
                      distance: "À 1.2 km",
                      timeAgo: "15 min",
                      title: "Dépannage plomberie",
                      description: "Fuite d'eau importante dans la salle de bain, besoin d'un professionnel d'urgence.",
                    ),
                    const SizedBox(height: 12),
                    _buildDemandCard(
                      location: "Baco-Djikoroni",
                      distance: "À 2.5 km",
                      timeAgo: "25 min",
                      title: "Installation chauffe-eau",
                      description: "Installation d'un chauffe-eau électrique de 50L dans un nouvel appartement.",
                    ),
                    const SizedBox(height: 12),
                    _buildDemandCard(
                      location: "Hamdallaye ACI 2000",
                      distance: "À 3.1 km",
                      timeAgo: "40 min",
                      title: "Réparation de robinet",
                      description: "Robinet de cuisine cassé qui ne se ferme plus. Remplacement nécessaire.",
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      
      // 3. BARRE DE NAVIGATION INFÉRIEURE
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: _primaryDark,
        unselectedItemColor: Colors.grey.shade400,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: "Accueil",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business_center),
            label: "Missions",
          ),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text("3"),
              child: Icon(Icons.chat_bubble_outline),
            ),
            label: "Messages",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profil",
          ),
        ],
      ),
    );
  }

  // --- WIDGET : EN-TÊTE BLEU FONCÉ ---
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 24),
      decoration: BoxDecoration(
        color: _primaryDark,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Avatar utilisateur avec bordure blanche
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage('assets/logo.png'), // Charge ton logo
                ),
              ),
              // Icône Notification
              IconButton(
                icon: const Icon(Icons.notifications_none_outlined, color: Colors.white, size: 28),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Bonjour,",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const Text(
            "Bourama ! 👋",
            style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Switch d'activation d'état
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _isOnline ? _accentGreen : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isOnline ? "En ligne" : "Hors ligne",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Switch(
                value: _isOnline,
                activeColor: _accentGreen,
                activeTrackColor: _accentGreen.withAlpha(102),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey.shade600,
                onChanged: (value) {
                  setState(() {
                    _isOnline = value;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- WIDGET : SECTIONS STATS ---
  Widget _buildStatsSection() {
    return Row(
      children: [
        // Carte Revenus
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.account_balance_wallet_outlined, color: _primaryDark),
                    const SizedBox(width: 8),
                    const Text("Revenus", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "150 000",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                Text(
                  "FCFA",
                  style: TextStyle(color: _accentGreen, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Carte Missions
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.business_center_outlined, color: _primaryDark),
                    const SizedBox(width: 8),
                    const Text("Missions", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "45",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                Text(
                  "En cours",
                  style: TextStyle(color: _accentGreen, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- WIDGET : CARTE DE DEMANDE ---
  Widget _buildDemandCard({
    required String location,
    required String distance,
    required String timeAgo,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, color: _accentGreen, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _primaryDark),
                    ),
                    Text(
                      distance,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(Icons.access_time, color: _accentGreen, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    timeAgo,
                    style: TextStyle(color: _accentGreen, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.3),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("Refuser", style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  child: const Text("Accepter", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}