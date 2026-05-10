// lib/widgets/home/custom_bottom_navbar.dart
import 'package:flutter/material.dart';

class CustomBottomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryDark = Color(0xFF00235B);
    const Color greyText = Color(0xFF9CA3AF);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: primaryDark,
        unselectedItemColor: greyText,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 0,
        items: [
          _buildNavItem(Icons.home_filled, Icons.home_outlined, "Accueil", 0),
          _buildNavItem(Icons.assignment, Icons.assignment_outlined, "Missions", 1),
          _buildNavItem(Icons.chat_bubble, Icons.chat_bubble_outline, "Messages", 2),
          _buildNavItem(Icons.person, Icons.person_outline, "Profil", 3),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
      IconData activeIcon, IconData inactiveIcon, String label, int index) {
    return BottomNavigationBarItem(
      icon: Icon(currentIndex == index ? activeIcon : inactiveIcon),
      label: label,
    );
  }
}