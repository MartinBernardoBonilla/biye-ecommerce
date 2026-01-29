import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';

class PaymentDeepLinkHandler {
  static StreamSubscription? _sub;

  static void initialize(GlobalKey<NavigatorState> navigatorKey) {
    if (kIsWeb) {
      // 🚫 uni_links NO soporta Web
      debugPrint('🔗 Deep links deshabilitados en Web');
      return;
    }

    _sub = uriLinkStream.listen((Uri? uri) {
      if (uri == null) return;

      final path = uri.path;

      if (path.contains('/checkout/success')) {
        navigatorKey.currentState?.pushNamed('/checkout/success');
      } else if (path.contains('/checkout/pending')) {
        navigatorKey.currentState?.pushNamed('/checkout/pending');
      } else if (path.contains('/checkout/failure')) {
        navigatorKey.currentState?.pushNamed('/checkout/failure');
      }
    });
  }

  static void dispose() {
    _sub?.cancel();
  }
}
