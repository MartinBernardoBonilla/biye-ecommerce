// lib/core/services/navigation_service.dart

import 'package:flutter/material.dart';

class NavigationService extends ChangeNotifier {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void navigateToFavorites() {
    setIndex(2);
  }

  void navigateToHome() {
    setIndex(0);
  }

  void navigateToProducts() {
    setIndex(1);
  }

  void navigateToProfile() {
    setIndex(3);
  }
}
