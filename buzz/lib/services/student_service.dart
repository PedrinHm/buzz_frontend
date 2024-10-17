import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/decodeJsonResponse.dart';
import 'package:buzz/config/config.dart';

class StudentService {
  Future<List<dynamic>> fetchStudents(int tripId) async {
    final response = await http
        .get(Uri.parse('${Config.backendUrl}/student_trips/by_trip/$tripId'));
    if (response.statusCode == 200) {
      return decodeJsonResponse(response);
    } else {
      throw Exception('Failed to load students');
    }
  }
}
