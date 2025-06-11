import 'dart:convert';

import 'package:http/http.dart' as http;

class AllApiCalling {
  // Add your API calling methods here
  // For example:

  static Future<String> createUserAndGetAccessToken(
      String userId, String name) async {
    final response = await http.post(
      Uri.parse(
          'https://28ce-2401-4900-1c08-563b-dd76-6128-9b23-ddda.ngrok-free.app/create-user-token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'name': name}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("Token from main method------>>>>>>${data['token']}");
      return data['token'];
    } else {
      throw Exception('Failed to fetch token');
    }
  }

  // You can add more methods as needed
}
