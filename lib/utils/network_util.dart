import 'dart:io';
import 'package:http/http.dart' as http;

class NetworkUtil {
  static Future<bool> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> isApiEndpointReachable() async {
    try {
      final response = await http.get(
        Uri.parse('https://generativelanguage.googleapis.com/v1/models/gemini-pro'),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode != 500;
    } catch (_) {
      return true; // Return true to allow the actual API call to handle any errors
    }
  }
}
