import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/decodeJsonResponse.dart';

class BusStopService {
  Future<Map<String, dynamic>> fetchBusStopDetails(int busStopId) async {
    final response = await http.get(Uri.parse(
        'https://buzzbackend-production.up.railway.app/bus_stops/$busStopId'));
    if (response.statusCode == 200) {
      return decodeJsonResponse(response);
    } else {
      throw Exception('Failed to load bus stop details');
    }
  }
}
