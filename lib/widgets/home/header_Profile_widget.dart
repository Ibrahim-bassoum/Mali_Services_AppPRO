// lib/widgets/home/header_profile_widget.dart
import 'package:flutter/material.dart';

class HeaderProfileWidget extends StatefulWidget {
  final String proName; // Reçoit le nom depuis l'API ou le state parent
  final bool initialOnlineStatus;
  final ValueChanged<bool> onStatusChanged;

  const HeaderProfileWidget({
    super.key,
    required this.proName,
    required this.initialOnlineStatus,
    required this.onStatusChanged,
  });

  @override
  State<HeaderProfileWidget> createState() => _HeaderProfileWidgetState();
}

class _HeaderProfileWidgetState extends State<HeaderProfileWidget> {
  late bool _isOnline;

  @override
  void initState() {
    super.initState();
    _isOnline = widget.initialOnlineStatus;
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryDark = Color(0xFF00235B);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
      decoration: const BoxDecoration(
        color: primaryDark,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo ou Initiales et Notifications
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "MS",
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Affichage du Nom et du Statut
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Bonjour,",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    Text(
                      "${widget.proName} ! 👋", // Affichage dynamique du nom
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis, // Évite que le nom ne dépasse
                      ),
                    ),
                  ],
                ),
              ),
              
              // Widget de statut interactif
              Column(
                children: [
                  Switch(
                    value: _isOnline,
                    activeColor: Colors.green,
                    inactiveThumbColor: Colors.grey,
                    onChanged: (value) {
                      setState(() => _isOnline = value);
                      widget.onStatusChanged(value); // Envoie l'info au parent (HomeScreen)
                    },
                  ),
                  Text(
                    _isOnline ? "En ligne" : "Hors-ligne",
                    style: TextStyle(
                      color: _isOnline ? Colors.green : Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}