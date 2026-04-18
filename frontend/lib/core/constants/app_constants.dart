class AppConstants {
// ============================================
// 1. URLs DEL BACKEND
// ============================================
  static const String apiBaseUrl =
      'https://biye-ecommerce-production.up.railway.app/api/v1';

  static const String imageBaseUrl =
      'https://biye-ecommerce-production.up.railway.app';

// Cloudinary
  static const String cloudinaryCloudName = 'dwchpxcrv';
  static const String cloudinaryUploadPreset = 'biye_products';

  // ============================================
  // 2. ENDPOINTS DE API
  // ============================================

  // Admin
  static const String apiAdminLogin = '/admin/login';
  static const String apiAdminProducts = '/admin/products';
  static const String apiAdminDashboard = '/admin/dashboard';
  static const String apiAdminUpload = '/admin/upload';

  // Públicos
  static const String apiProducts = '/products';
  static const String apiCategories = '/categories';
  static const String apiAuthLogin = '/auth/login';
  static const String apiAuthRegister = '/auth/register';
  static const String apiUsers = '/users';

  // ============================================
  // 3. CONFIGURACIÓN GENERAL
  // ============================================

  static const String appName = 'Biye';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ============================================
  // 4. ALMACENAMIENTO LOCAL
  // ============================================

  static const String adminTokenKey = 'admin_token';
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String cartItemsKey = 'cart_items';

  // ============================================
  // 5. MENSAJES
  // ============================================

  static const String networkError = 'Error de conexión con el servidor';
  static const String sessionExpired = 'Tu sesión ha expirado';
  static const String serverError = 'Error en el servidor';
  static const String unknownError = 'Error desconocido';

  // ============================================
  // 6. HEADERS HTTP (CORS para desarrollo web)
  // ============================================

  static Map<String, String> get headers {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Origin': 'https://biye-ecommerce-production.up.railway.app',
      'Access-Control-Request-Method': 'GET,POST,PUT,DELETE,OPTIONS',
    };
  }

  // Headers con autenticación
  static Map<String, String> headersWithAuth(String token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Origin': 'https://biye-ecommerce-production.up.railway.app',
    };
  }

  // ============================================
  // 7. HELPERS (Aquí es donde daba el error)
  // ============================================

  static String buildApiUrl(String endpoint) {
    String cleanEndpoint = endpoint;

    if (endpoint.startsWith('/api/v1')) {
      cleanEndpoint = endpoint.substring(7);
    } else if (endpoint.startsWith('api/v1')) {
      cleanEndpoint = endpoint.substring(6);
    }

    if (!cleanEndpoint.startsWith('/')) {
      cleanEndpoint = '/$cleanEndpoint';
    }

    // ✅ Ahora coincide con el nombre de la variable arriba
    return '$apiBaseUrl$cleanEndpoint';
  }
}
