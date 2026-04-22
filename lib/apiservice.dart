import 'dart:convert';
import 'dart:typed_data';
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

      return data;
    } catch (e) {
      return {
        "success": false,
        "message": "Connection error: $e",
      };
    }
  }

  // ==========================
  // 📍 SUBMIT REPORT
  // ==========================
  static Future<Map<String, dynamic>> submitReport({
    required String userId,
    required String location,
    required String barangay,
    required String reportType,
    String details = '',
    String photo = '',
    Uint8List? photoBytes,
    String? photoFileName,
  }) async {
    try {
      late http.Response response;
      final uri = Uri.parse("$baseUrl/add_report.php");

      if (photoBytes != null && photoBytes.isNotEmpty) {
        final request = http.MultipartRequest('POST', uri)
          ..fields['user_id'] = userId
          ..fields['location'] = location
          ..fields['barangay'] = barangay
          ..fields['report_type'] = reportType
          ..fields['details'] = details
          ..fields['photo'] = photo;

        request.files.add(
          http.MultipartFile.fromBytes(
            'photo_file',
            photoBytes,
            filename: photoFileName ?? 'report_photo.jpg',
          ),
        );

        final streamed = await request.send();
        final body = await streamed.stream.bytesToString();
        response = http.Response(body, streamed.statusCode);
      } else {
        response = await http.post(
          uri,
          body: {
            "user_id": userId,
            "location": location,
            "barangay": barangay,
            "report_type": reportType,
            "details": details,
            "photo": photo,
          },
        );
      }

      final data = json.decode(response.body);
      return data is Map<String, dynamic>
          ? data
          : <String, dynamic>{
              "success": false,
              "message": "Unexpected server response format.",
            };
    } catch (e) {
      return {
        "success": false,
        "message": "Connection error: $e",
      };
    }
  }

  // ==========================
  // 📄 GET REPORTS
  // ==========================
  static Future<Map<String, dynamic>> getReports({String? userId}) async {
    try {
      final body = <String, String>{};
      if (userId != null && userId.trim().isNotEmpty) {
        body["user_id"] = userId.trim();
      }

      final response = await http.post(
        Uri.parse("$baseUrl/get_reports.php"),
        body: body,
      );

      final data = json.decode(response.body);
      return data is Map<String, dynamic>
          ? data
          : <String, dynamic>{
              "success": false,
              "message": "Unexpected server response format.",
            };
    } catch (e) {
      return {
        "success": false,
        "message": "Connection error: $e",
      };
    }
  }
}