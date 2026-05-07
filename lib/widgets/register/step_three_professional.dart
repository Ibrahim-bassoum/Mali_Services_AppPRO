import 'package:flutter/material.dart';
import 'package:app_mali_services_pro/models/Category.dart';

class StepThreeProfessional extends StatelessWidget {
  final List<Category> categories;
  final bool isLoadingCategories;
  final int? selectedCategoryId;
  final ValueChanged<int?> onCategoryChanged;
  final TextEditingController experienceController;
  final String? selectedZone;
  final ValueChanged<String?> onZoneChanged;
  final bool isLoading;

  const StepThreeProfessional({
    super.key,
    required this.categories,
    required this.isLoadingCategories,
    required this.selectedCategoryId,
    required this.onCategoryChanged,
    required this.experienceController,
    required this.selectedZone,
    required this.onZoneChanged,
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
          "Profil professionnel",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryDark),
        ),
        const SizedBox(height: 8),
        Text(
          "Parlez-nous de votre métier et de votre expérience.",
          style: TextStyle(fontSize: 14, color: greyText),
        ),
        const SizedBox(height: 30),
        
        _buildLabel("Catégorie de métier", primaryDark),
        isLoadingCategories
            ? const Center(child: Padding(
                padding: EdgeInsets.all(12.0),
                child: CircularProgressIndicator(),
              ))
            : _buildCategoryDropdownField(
                value: selectedCategoryId,
                hint: "Sélectionnez votre catégorie",
                icon: Icons.work_outline,
                items: categories,
                onChanged: onCategoryChanged,
                isLoading: isLoading,
                primaryDark: primaryDark,
              ),
        const SizedBox(height: 20),
        
        _buildLabel("Années d'expérience", primaryDark),
        _buildTextField(
          controller: experienceController,
          hint: "Ex: 5",
          icon: Icons.trending_up_outlined,
          keyboardType: TextInputType.number,
          isLoading: isLoading,
          primaryDark: primaryDark,
          suffix: Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 15.0),
            child: Text("ans", style: TextStyle(color: greyText, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 20),
        
        _buildLabel("Zone d'intervention", primaryDark),
        _buildZoneDropdownField(
          value: selectedZone,
          hint: "Sélectionnez vos zones",
          icon: Icons.location_on_outlined,
          items: ["Sébénikoro", "Baco-Djikoroni", "Hamdallaye", "Kalaban Coura", "Badalabougou"],
          onChanged: onZoneChanged,
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
    TextInputType keyboardType = TextInputType.text,
    Widget? suffix,
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
        keyboardType: keyboardType,
        enabled: !isLoading,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(icon, color: primaryDark),
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
            borderSide: const BorderSide(color: Color(0xFF2F66F6), width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdownField({
    required int? value,
    required String hint,
    required IconData icon,
    required List<Category> items,
    required ValueChanged<int?> onChanged,
    required bool isLoading,
    required Color primaryDark,
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
        icon: Icon(Icons.expand_more, color: primaryDark),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: primaryDark),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        items: isLoading 
            ? null 
            : items.map((Category cat) {
                return DropdownMenuItem<int>(
                  value: cat.id,
                  child: Text(cat.name, style: TextStyle(color: primaryDark)),
                );
              }).toList(),
        onChanged: isLoading ? null : onChanged,
      ),
    );
  }

  Widget _buildZoneDropdownField({
    required String? value,
    required String hint,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required bool isLoading,
    required Color primaryDark,
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
        icon: Icon(Icons.expand_more, color: primaryDark),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: primaryDark),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        items: isLoading 
            ? null 
            : items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item, style: TextStyle(color: primaryDark)),
                );
              }).toList(),
        onChanged: isLoading ? null : onChanged,
      ),
    );
  }
}