import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PaymentDeepLinkHandler {
  static StreamSubscription? _sub;

  static void initialize(GlobalKey<NavigatorState> navigatorKey) {
    if (kIsWeb) {
      debugPrint('🔗 Deep links deshabilitados en Web');
      return;
    }

    // TODO: Implementar deep links cuando sea necesario
    debugPrint('🔗 PaymentDeepLinkHandler inicializado (versión simplificada)');
  }

  static void dispose() {
    _sub?.cancel();
  }
}
