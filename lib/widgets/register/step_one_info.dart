import 'package:flutter/material.dart';

class StepOneInfo extends StatelessWidget {
  final TextEditingController nomController;
  final TextEditingController prenomController;
  final TextEditingController dateNaissanceController;
  final VoidCallback onTapDate;
  final bool isLoading;

  const StepOneInfo({
    super.key,
    required this.nomController,
    required this.prenomController,
    required this.dateNaissanceController,
    required this.onTapDate,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryDark = const Color(0xFF00235B);
    final Color greyText = const Color(0xFF6B7280);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Informations personnelles",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryDark),
        ),
        const SizedBox(height: 8),
        Text(
          "Commençons par vos informations de base.",
          style: TextStyle(fontSize: 14, color: greyText),
        ),
        const SizedBox(height: 30),
        
        _buildLabel("Nom", primaryDark),
        _buildTextField(
          controller: nomController,
          hint: "Entrez votre nom",
          icon: Icons.person_outline,
          isLoading: isLoading,
          primaryDark: primaryDark,
        ),
        const SizedBox(height: 20),
        
        _buildLabel("Prénom", primaryDark),
        _buildTextField(
          controller: prenomController,
          hint: "Entrez votre prénom",
          icon: Icons.person_outline,
          isLoading: isLoading,
          primaryDark: primaryDark,
        ),
        const SizedBox(height: 20),
        
        _buildLabel("Date de naissance", primaryDark),
        _buildTextField(
          controller: dateNaissanceController,
          hint: "JJ / MM / AAAA",
          icon: Icons.calendar_today_outlined,
          readOnly: true,
          onTap: onTapDate,
          isLoading: isLoading,
          primaryDark: primaryDark,
        ),
      ],
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
    required bool isLoading,
    required Color primaryDark,
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
        readOnly: readOnly,
        onTap: onTap,
        enabled: !isLoading,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(icon, color: primaryDark),
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
            borderSide: const Color(0xFF2F66F6) == null 
                ? const BorderSide(color: Colors.blue, width: 2)
                : const BorderSide(color: Color(0xFF2F66F6), width: 2),
          ),
        ),
      ),
    );
  }
}