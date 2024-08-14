import 'package:http/http.dart' as http;
import 'dart:convert';

class BusStopService {
  Future<Map<String, dynamic>> fetchBusStopDetails(int busStopId) async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/bus_stops/$busStopId'));
    if (response.statusCode == 200) {
        return json.decode(response.body);
    } else {
        throw Exception('Failed to load bus stop details');
    }
  }
}
