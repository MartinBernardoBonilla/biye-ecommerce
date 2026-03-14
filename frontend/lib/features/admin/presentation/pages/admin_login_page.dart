// frontend/lib/features/admin/presentation/pages/admin_login_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:biye/features/admin/presentation/pages/admin_panel_page.dart';
import 'package:biye/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:biye/features/auth/presentation/bloc/auth_state.dart';
import 'package:biye/features/auth/presentation/bloc/auth_event.dart';
import 'package:provider/provider.dart';
import 'package:biye/core/network/api_client.dart';
import 'package:biye/core/utils/auth_storage.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  static const String routeName = '/admin/login';

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _checkExistingSession();
  }

  /// 🔥 VERIFICAR SI YA HAY UNA SESIÓN ACTIVA
  void _checkExistingSession() {
    debugPrint('🔍 [ADMIN LOGIN] Verificando sesión existente...');

    // Disparar verificación de token
    context.read<AuthBloc>().add(AuthCheckStatus());

    // Escuchar cambios en el estado de autenticación
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      _handleAuthState(authState);
    });
  }

  /// 🔥 MANEJAR ESTADO DE AUTENTICACIÓN
  void _handleAuthState(AuthState state) {
    if (state is AuthAuthenticated || state is AuthTokenAuthenticated) {
      debugPrint('✅ [ADMIN LOGIN] Sesión existente detectada, redirigiendo...');

      // Obtener el rol del usuario
      String? role;
      if (state is AuthAuthenticated) {
        role = state.userData?['role'];
      } else if (state is AuthTokenAuthenticated) {
        role = state.userData['role'];
      }

      // Solo redirigir si es admin (o forzar redirección)
      if (role == 'admin') {
        Future.microtask(() {
          Navigator.pushReplacementNamed(
            context,
            AdminPanelPage.routeName,
          );
        });
      }
    }
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    debugPrint('🟡 Iniciando proceso de login admin...');

    try {
      final apiClient = context.read<ApiClient>();
      debugPrint('📤 Enviando petición a auth/admin/login');

      final response = await apiClient.post(
        'auth/admin/login',
        {
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        },
      );

      debugPrint('📥 Respuesta recibida: $response');

      final token = response['data']?['token'];
      debugPrint('🔑 Token extraído: ${token != null ? 'SÍ' : 'NO'}');

      if (token == null || token.isEmpty) {
        throw Exception('Token admin inválido');
      }

      // Guardar token en ApiClient (esto ya llama a AuthStorage)
      apiClient.setToken(token);
      debugPrint('✅ Token guardado en ApiClient');

      // ✅ VERIFICACIÓN ADICIONAL
      final savedToken = await AuthStorage.getToken();
      debugPrint(
          '🔍 Verificando token en AuthStorage: ${savedToken != null ? savedToken.substring(0, 15) : 'null'}...');

      // También guardar datos del usuario
      await AuthStorage.saveUserData(
        userId: response['data']['id'] ?? response['data']['userId'] ?? '',
        email: response['data']['email'] ?? _emailController.text,
        role: response['data']['role'] ?? 'admin',
      );

      // 🔥 Disparar evento de login exitoso en AuthBloc
      // Esto actualizará el estado global de autenticación
      context.read<AuthBloc>().add(AuthCheckStatus());

      debugPrint('🚀 Intentando navegar a AdminPanelPage...');
      debugPrint('📍 mounted: $mounted');

      if (mounted) {
        Future.microtask(() {
          Navigator.pushReplacementNamed(
            context,
            AdminPanelPage.routeName,
          ).then((_) {
            debugPrint('✅ Navegación completada exitosamente');
          }).catchError((e) {
            debugPrint('❌ Error en navegación: $e');
          });
        });
      } else {
        debugPrint('❌ Widget no mounted, no se puede navegar');
      }
    } catch (error, stack) {
      debugPrint('🔥 ERROR EN LOGIN: $error');
      debugPrintStack(stackTrace: stack);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      /// 🔥 ESCUCHAR CAMBIOS EN EL ESTADO DE AUTENTICACIÓN
      listener: (context, state) {
        _handleAuthState(state);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Iniciar Sesión'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.admin_panel_settings,
                        size: 80,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Panel de Administración',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Ingresa tus credenciales de administrador',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu email';
                          }
                          if (!value.contains('@')) {
                            return 'Ingresa un email válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(
                                  () => _obscurePassword = !_obscurePassword);
                            },
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu contraseña';
                          }
                          if (value.length < 6) {
                            return 'La contraseña debe tener al menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Iniciar Sesión',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        color: Colors.grey[50],
                        child: const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Credenciales de prueba:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text('Email: admin@biye.com'),
                              Text('Contraseña: admin123'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
