import 'package:http/http.dart' as http;
import 'dart:convert';

class StudentService {
  Future<List<dynamic>> fetchStudents(int tripId) async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/student_trips/by_trip/$tripId'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load students');
    }
  }
}
