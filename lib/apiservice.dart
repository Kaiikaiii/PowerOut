import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // 🔁 CHANGE THIS to your actual Hostinger domain
  static const String baseUrl = "https://lime-weasel-672604.hostingersite.com/powerout";

  // ==========================
  // 🔐 LOGIN
  // ==========================
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login.php"),
        body: {
          "email": email,
          "password": password,
        },
      );

      final data = json.decode(response.body);

      // Debug (remove later if you want)
      print("LOGIN RESPONSE: $data");

      return data;
    } catch (e) {
      return {
        "success": false,
        "message": "Connection error: $e",
      };
    }
  }

  // ==========================
  // 📝 SIGNUP
  // ==========================
  static Future<Map<String, dynamic>> signup(
    String name,
    String email,
    String password,
    String barangay,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/signup.php"),
        body: {
          "name": name,
          "email": email,
          "password": password,
          "barangay": barangay,
        },
      );

      final data = json.decode(response.body);

      // Debug (remove later if you want)
      print("SIGNUP RESPONSE: $data");

      return data;
    } catch (e) {
      return {
        "success": false,
        "message": "Connection error: $e",
      };
    }
  }
}