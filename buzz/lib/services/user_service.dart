import 'package:http/http.dart' as http;
import 'dart:convert';

class UserService {
  Future<Map<String, dynamic>> fetchUserDetails(int userId) async {
    final response = await http.get(Uri.parse('https://buzzbackend-production.up.railway.app/users/$userId'));
    if (response.statusCode == 200) {
        return json.decode(response.body);
    } else {
        throw Exception('Failed to load user details');
    }
  }
}
