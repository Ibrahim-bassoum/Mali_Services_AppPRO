import 'package:flutter/material.dart';

class StepTwoSecurity extends StatefulWidget {
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool isLoading;

  const StepTwoSecurity({
    super.key,
    required this.phoneController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isLoading,
  });

  @override
  State<StepTwoSecurity> createState() => _StepTwoSecurityState();
}

class _StepTwoSecurityState extends State<StepTwoSecurity> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    final Color primaryDark = const Color(0xFF00235B);
    final Color greyText = const Color(0xFF6B7280);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Sécurité du compte",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryDark),
        ),
        const SizedBox(height: 8),
        Text(
          "Protégez votre compte avec un mot de passe sécurisé.",
          style: TextStyle(fontSize: 14, color: greyText),
        ),
        const SizedBox(height: 30),
        
        _buildLabel("Numéro de téléphone", primaryDark),
        _buildTextField(
          controller: widget.phoneController,
          hint: "70 12 34 56",
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          isLoading: widget.isLoading,
          primaryDark: primaryDark,
          prefix: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 12),
              const Text("🇲🇱", style: TextStyle(fontSize: 20)),
              const SizedBox(width: 6),
              Text("+223", style: TextStyle(fontWeight: FontWeight.bold, color: primaryDark)),
              const SizedBox(width: 10),
              Container(width: 1, height: 20, color: Colors.grey.shade300),
              const SizedBox(width: 10),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        _buildLabel("Créer un mot de passe", primaryDark),
        _buildTextField(
          controller: widget.passwordController,
          hint: "••••••••",
          icon: Icons.lock_outline,
          obscureText: _obscurePassword,
          isLoading: widget.isLoading,
          primaryDark: primaryDark,
          suffix: IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: primaryDark),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        const SizedBox(height: 20),
        
        _buildLabel("Confirmer le mot de passe", primaryDark),
        _buildTextField(
          controller: widget.confirmPasswordController,
          hint: "••••••••",
          icon: Icons.lock_outline,
          obscureText: _obscureConfirmPassword,
          isLoading: widget.isLoading,
          primaryDark: primaryDark,
          suffix: IconButton(
            icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: primaryDark),
            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
          ),
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
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? prefix,
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
        obscureText: obscureText,
        keyboardType: keyboardType,
        enabled: !isLoading,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: prefix ?? Icon(icon, color: primaryDark),
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
}