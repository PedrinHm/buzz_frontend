import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TripController extends ChangeNotifier {
  bool _hasActiveTrip = false;
  int? _activeTripId;

  bool get hasActiveTrip => _hasActiveTrip;
  int? get activeTripId => _activeTripId;

  void startTrip(int tripId) {
    _hasActiveTrip = true;
    _activeTripId = tripId;
    notifyListeners();
  }

  void endTrip() {
    _hasActiveTrip = false;
    _activeTripId = null;
    notifyListeners();
  }

  Future<void> checkActiveTrip(int driverId) async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/trips/active/$driverId'));
    if (response.statusCode == 200) {
      final tripData = json.decode(response.body);
      _activeTripId = tripData['id'];
      _hasActiveTrip = true;
    } else {
      _hasActiveTrip = false;
      _activeTripId = null;
    }
    notifyListeners();
  }

  Future<void> initiateTrip(int driverId, int busId) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/trips/'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'trip_type': 1,  // Assuming 1 is for IDA
        'status': 1,
        'bus_id': busId,
        'driver_id': driverId,
      }),
    );

    if (response.statusCode == 200) {
      final tripData = json.decode(response.body);
      _activeTripId = tripData['id'];
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
      _activeTripId = null;
    } else {
      throw Exception('Failed to end trip');
    }
    notifyListeners();
  }
}
