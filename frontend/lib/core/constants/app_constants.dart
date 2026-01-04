class AppConstants {
  // ============================================
  // 1. URLs DEL BACKEND (TU IP REAL)
  // ============================================

  // ✅ TU IP REAL: 192.168.1.49
  static const String apiBaseUrl = 'http://192.168.1.49:5000/api/v1';

  // Para imágenes (puedes usar Cloudinary directamente)
  static const String imageBaseUrl = 'http://192.168.1.49:5000';

  // Cloudinary (si subes imágenes directo desde Flutter)
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
      'Origin': 'http://localhost:42321', // Puerto de Flutter web
      'Access-Control-Request-Method': 'GET,POST,PUT,DELETE,OPTIONS',
    };
  }

  // Headers con autenticación
  static Map<String, String> headersWithAuth(String token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Origin': 'http://localhost:42321',
    };
  }

  // ============================================
  // 7. HELPERS
  // ============================================

  // Helper para URLs de imagen
  static String getFullImageUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    if (path.startsWith('/')) return '$imageBaseUrl$path';
    return '$imageBaseUrl/$path';
  }

  // Helper para construir URLs de API
  static String buildApiUrl(String endpoint) {
    // Si el endpoint ya tiene /api/v1, removerlo
    String cleanEndpoint = endpoint;

    if (endpoint.startsWith('/api/v1')) {
      cleanEndpoint = endpoint.substring(7);
    } else if (endpoint.startsWith('api/v1')) {
      cleanEndpoint = endpoint.substring(6);
    }

    // Asegurar que empiece con /
    if (!cleanEndpoint.startsWith('/')) {
      cleanEndpoint = '/$cleanEndpoint';
    }

    return '$apiBaseUrl$cleanEndpoint';
  }

  // Helper para Cloudinary
  static String getCloudinaryUrl(String publicId,
      {int width = 800, int height = 600}) {
    return 'https://res.cloudinary.com/$cloudinaryCloudName/image/upload/w_$width,h_$height,c_fill/$publicId';
  }
}
