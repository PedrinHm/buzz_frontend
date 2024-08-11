import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TripController extends ChangeNotifier {
  bool _hasActiveTrip = false;
  int? _activeTripId;
  int? _tripType;

  bool get hasActiveTrip => _hasActiveTrip;
  int? get activeTripId => _activeTripId;
  int? get tripType => _tripType;

  void startTrip(int tripId, int tripType) {
    _hasActiveTrip = true;
    _activeTripId = tripId;
    _tripType = tripType;
    notifyListeners();
  }

  void endTrip() {
    _hasActiveTrip = false;
    _activeTripId = null;
    _tripType = null;
    notifyListeners();
  }

  Future<void> checkActiveTrip(int driverId) async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/trips/active/$driverId'));
    if (response.statusCode == 200) {
      final tripData = json.decode(response.body);
      _activeTripId = tripData['id'];
      _tripType = tripData['trip_type'];
      _hasActiveTrip = true;
    } else {
      _hasActiveTrip = false;
      _activeTripId = null;
      _tripType = null;
    }
    notifyListeners();
  }

  Future<void> initiateTrip(int driverId, int busId, int tripType) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/trips/'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'trip_type': tripType,
        'status': 1,
        'bus_id': busId,
        'driver_id': driverId,
      }),
    );

    if (response.statusCode == 200) {
      final tripData = json.decode(response.body);
      _activeTripId = tripData['id'];
      _tripType = tripType;
      _hasActiveTrip = true;
    } else {
      throw Exception('Failed to start trip');
    }
    notifyListeners();
  }

  Future<void> completeTrip(int tripId) async {
    String endpoint = _tripType == 1 ? 'finalizar_ida' : 'finalizar_volta';
    final response = await http.put(Uri.parse('http://127.0.0.1:8000/trips/$tripId/$endpoint'));
    
    if (response.statusCode == 200) {
      if (_tripType == 1) {
        final returnTripData = json.decode(response.body);
        startTrip(returnTripData['id'], 2); // Iniciar viagem de volta
      } else {
        endTrip(); // Encerrar completamente a viagem
      }
    } else {
      throw Exception('Failed to complete trip');
    }
  }
}
