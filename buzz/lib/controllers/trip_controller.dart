import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TripController extends ChangeNotifier {
  bool _hasActiveTrip = false;

  bool get hasActiveTrip => _hasActiveTrip;

  void startTrip() {
    _hasActiveTrip = true;
    notifyListeners();
  }

  void endTrip() {
    _hasActiveTrip = false;
    notifyListeners();
  }

  Future<void> checkActiveTrip(int driverId) async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/trips/active/$driverId'));
    if (response.statusCode == 200) {
      _hasActiveTrip = true;
    } else {
      _hasActiveTrip = false;
    }
    notifyListeners();
  }

  Future<void> initiateTrip(int driverId, int busId) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/trips/'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'trip_type': 1,  // Assuming 1 is for IDA
        'bus_id': busId,
        'driver_id': driverId,
      }),
    );

    if (response.statusCode == 200) {
      _hasActiveTrip = true;
    } else {
      throw Exception('Failed to start trip');
    }
    notifyListeners();
  }

  Future<void> completeTrip(int tripId) async {
    final response = await http.put(Uri.parse('http://127.0.0.1:8000/trips/$tripId/finalizar_ida'));
    if (response.statusCode == 200) {
      _hasActiveTrip = false;
    } else {
      throw Exception('Failed to end trip');
    }
    notifyListeners();
  }
}
