import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // 10.0.2.2 pour l'émulateur Android, utilise ton IP locale pour un vrai téléphone
  final String baseUrl = "http://192.168.1.18:8000/api"; 

  // --- CONNEXION (LOGIN) ---
  Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "phone": phone,
          "password": password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Si la connexion réussit et qu'un token est renvoyé, on le sauvegarde
        if (data['access_token'] != null) {
          await saveToken(data['access_token']);
        }
        return {"status": "success", "data": data};
      } else {
        return {
          "status": "error",
          "message": data['message'] ?? "Identifiants incorrects",
        };
      }
    } catch (e) {
      return {"status": "error", "message": "Erreur de connexion au serveur"};
    }
  }

  // --- INSCRIPTION (REGISTER) ---
  Future<Map<String, dynamic>> register({
    required String name,
    required String firstname,
    required String birthDate,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String role,
    String? categoryId,
    String? experienceYears,
    String? interventionZone,
    String? specialty,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "name": name,
          "firstname": firstname,
          "birth_date": birthDate,
          "phone": phone,
          "password": password,
          "password_confirmation": passwordConfirmation,
          "role": role,
          if (role == 'pro') ...{
            "category_id": categoryId,
            "experience_years": experienceYears,
            "intervention_zone": interventionZone,
            "specialty": specialty,
          }
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {"status": "success", "data": data};
      } else {
        return {
          "status": "error", 
          "message": data['message'] ?? "Erreur de validation",
          "errors": data['errors']
        };
      }
    } catch (e) {
      return {"status": "error", "message": "Erreur de connexion au serveur : $e"};
    }
  }

  // --- GESTION DU TOKEN ---
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}