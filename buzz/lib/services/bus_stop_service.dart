import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/decodeJsonResponse.dart';
import 'package:buzz/config/config.dart';

class BusStopService {
  Future<Map<String, dynamic>> fetchBusStopDetails(int busStopId) async {
    final response =
        await http.get(Uri.parse('${Config.backendUrl}/bus_stops/$busStopId'));
    if (response.statusCode == 200) {
      return decodeJsonResponse(response);
    } else {
      throw Exception('Failed to load bus stop details');
    }
  }
}
