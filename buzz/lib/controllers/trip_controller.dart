import 'package:flutter/material.dart';

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
}
