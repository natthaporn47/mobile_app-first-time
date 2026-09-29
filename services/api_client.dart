import 'dart:convert';
import 'package:http/http.dart' as http;


class ApiClient {
  final String baseUrl;
  ApiClient(this.baseUrl);

  Future<dynamic> getJson(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final res = await http.get(uri);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    return json.decode(res.body);
  }
}
