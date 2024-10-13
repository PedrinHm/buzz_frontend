import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/decodeJsonResponse.dart';

class TripController extends ChangeNotifier {
  bool _hasActiveTrip = false;
  int? _activeTripId;
  int? _tripType; // 1 para ida, 2 para volta
  bool _isStudent = false;
  int? _studentTripId;
  bool _isLoading = false;

  bool get hasActiveTrip => _hasActiveTrip;
  int? get activeTripId => _activeTripId;
  int? get tripType => _tripType;
  bool get isStudent => _isStudent;
  int? get studentTripId => _studentTripId;
  bool get isLoading => _isLoading;

  void startStudentTrip(int studentTripId, int tripId) {
    _hasActiveTrip = true;
    _studentTripId = studentTripId;
    _activeTripId = tripId;

    // Usando addPostFrameCallback para chamar notifyListeners após o build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void startTrip(int tripId, int tripType) {
    _hasActiveTrip = true;
    _activeTripId = tripId;
    _tripType = tripType;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void endTrip() {
    print("Finalizando a viagem, tripId atual: $_activeTripId");
    _hasActiveTrip = false;
    _activeTripId = null; // Certifica-se de que activeTripId seja null
    _tripType = null;
    _isStudent = false;
    _studentTripId = null;
    print("Viagem finalizada. activeTripId é null agora.");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<void> checkActiveTrip(int userId, {bool isStudent = false}) async {
    _isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    _isStudent = isStudent;

    if (isStudent) {
      await checkActiveStudentTrip(userId);
    } else {
      await checkActiveDriverTrip(userId);
    }

    _isLoading = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<void> checkActiveDriverTrip(int driverId) async {
    final response = await http.get(Uri.parse(
        'https://buzzbackend-production.up.railway.app/trips/active/$driverId'));
    if (response.statusCode == 200) {
      final tripData = decodeJsonResponse(response);
      _activeTripId = tripData['id'];
      _tripType = tripData['trip_type'];
      _hasActiveTrip = true;
    } else {
      _hasActiveTrip = false;
      _activeTripId = null;
      _tripType = null;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<void> checkActiveStudentTrip(int studentId) async {
    try {
      final response = await http.get(Uri.parse(
          'https://buzzbackend-production.up.railway.app/student_trips/active/$studentId'));
      if (response.statusCode == 200) {
        final tripData = decodeJsonResponse(response);
        _activeTripId = tripData['trip_id'];
        _tripType = tripData['trip_type'] == 'IDA' ? 1 : 2;
        _studentTripId = tripData['student_trip_id'];
        _hasActiveTrip = true;
      } else {
        _hasActiveTrip = false;
        _activeTripId = null;
        _tripType = null;
        _studentTripId = null;
      }
    } catch (e) {
      print('Error fetching active student trip: $e');
      _hasActiveTrip = false;
      _activeTripId = null;
      _tripType = null;
      _studentTripId = null;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<void> initiateTrip(int driverId, int busId, int tripType) async {
    final response = await http.post(
      Uri.parse('https://buzzbackend-production.up.railway.app/trips/'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'trip_type': tripType,
        'status': 1,
        'bus_id': busId,
        'driver_id': driverId,
      }),
    );

    if (response.statusCode == 200) {
      final tripData = decodeJsonResponse(response);
      _activeTripId = tripData['id'];
      _tripType = tripType;
      _hasActiveTrip = true;
    } else {
      throw Exception('Failed to start trip');
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<void> completeTrip(int tripId) async {
    String endpoint = _tripType == 1 ? 'finalizar_ida' : 'finalizar_volta';
    final response = await http.put(Uri.parse(
        'https://buzzbackend-production.up.railway.app/trips/$tripId/$endpoint'));

    if (response.statusCode == 200) {
      final responseData = decodeJsonResponse(response);

      if (_tripType == 1) {
        // Inicia a viagem de volta usando o new_trip_id retornado na resposta
        int? returnTripId = responseData['new_trip_id'];
        if (returnTripId != null) {
          startTrip(returnTripId, 2); // Viagem de volta
        }
      } else {
        // Finaliza completamente a viagem de volta e redefine o estado para null
        endTrip(); // Define que não há mais viagem ativa
      }
    } else {
      throw Exception('Erro ao concluir a viagem');
    }
  }
}
