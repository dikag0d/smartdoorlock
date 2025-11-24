import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://doorlockapi.loca.lt";

  static Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse("$baseUrl/login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['error'] ?? 'Login gagal');
    }
  }
  static Future<Map<String, dynamic>> register(String username, String password) async {
    final url = Uri.parse("$baseUrl/register");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),

    );
    
    return jsonDecode(response.body);
    
  }
  // 📡 GET DATA TERBARU (maksimal 50 data)
  static Future<List<dynamic>> getData() async {
    final url = Uri.parse('$baseUrl/data?limit=50'); // ✅ Tambah limit di query

    final response = await http.get(
      url,
      headers: {

        "bypass-tunnel-reminder": "true",
        "Content-Type": "application/json", // untuk hindari warning ngrok
      },
    );

  print("🟩 Status: ${response.statusCode}");
  print("🟩 Body: ${response.body}");

  if (response.statusCode == 200) {
    try {
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception("Format JSON tidak valid: $e");
    }
  } else {
    throw Exception('Failed to fetch data: ${response.statusCode}');
  }
}


static Future<void> activateBuzzer() async {
  final response = await http.post(Uri.parse('$baseUrl/buzzer/on'));
  if (response.statusCode != 200) {
    throw Exception('Gagal menyalakan buzzer');
  }
}
 static Future<void> updateMode(bool isInRoom) async {
  final url = Uri.parse("$baseUrl/mode");
  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"inRoom": isInRoom}),
  );

  if (response.statusCode != 200) {
    throw Exception('Gagal memperbarui mode');
  }
}
static Future<void> registerToken(String token) async {
  final url = Uri.parse("$baseUrl/token");

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"token": token}),
  );

  if (response.statusCode != 200) {
    throw Exception("Gagal menyimpan token FCM");
  }
}

}

