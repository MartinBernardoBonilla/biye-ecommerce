// lib/features/auth/presentation/bloc/auth_bloc.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:biye/core/utils/auth_storage.dart';

import 'auth_event.dart';
import 'auth_state.dart';
import 'package:biye/core/services/firebase_auth_service.dart';
import 'package:biye/core/network/api_client.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuthService _authService;
  final ApiClient apiClient;

  AuthBloc({
    FirebaseAuthService? authService,
    required this.apiClient,
  })  : _authService = authService ?? FirebaseAuthService(),
        super(AuthInitial()) {
    // Registrar eventos
    on<AuthStarted>(_onAuthStarted);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthUserChanged>(_onUserChanged);
    on<AuthCheckStatus>(_onCheckStatus);

    // Escuchar cambios en Firebase Auth
    _authService.authStateChanges.listen(
      (user) => add(AuthUserChanged(user)),
    );

    // Verificar estado al iniciar
    add(AuthCheckStatus());
  }

  // ================================
  // APP START - NUEVO MÉTODO DEFINIDO
  // ================================
  void _onAuthStarted(
    AuthStarted event,
    Emitter<AuthState> emit,
  ) {
    final user = _authService.currentUser;

    if (user != null) {
      // Si hay usuario en Firebase, verificamos token
      add(AuthCheckStatus());
    } else {
      // No hay usuario, verificamos si hay token guardado
      add(AuthCheckStatus());
    }
  }

  // ================================
// VERIFICAR TOKEN GUARDADO (CORREGIDO)
// ================================
  Future<void> _onCheckStatus(
    AuthCheckStatus event,
    Emitter<AuthState> emit,
  ) async {
    final hasToken = await AuthStorage.isLoggedIn();
    final userData = await AuthStorage.getUserData();
    final firebaseUser = _authService.currentUser;

    print('🔍 [AUTH] Verificando estado:');
    print('   - Token existe: $hasToken');
    print('   - Firebase user: ${firebaseUser?.email}');
    print('   - Role guardado: ${userData['role']}');

    if (hasToken) {
      final token = await AuthStorage.getToken();
      if (token != null) {
        // Restaurar token en ApiClient
        apiClient.setToken(token);

        if (firebaseUser != null) {
          // ✅ Caso 1: Firebase + Token
          debugPrint('✅ [AUTH] Sesión completa restaurada');
          emit(AuthAuthenticated(
            user: firebaseUser,
            userData: userData,
          ));
        } else {
          // 🔥 CORREGIDO: Si hay token pero no Firebase, intentar obtener usuario de Firebase
          debugPrint(
              '🔄 [AUTH] Token presente, intentando restaurar Firebase...');

          // Intentar obtener usuario con el token
          try {
            // Aquí podrías intentar obtener el perfil del usuario desde tu backend
            // Por ahora, emitimos un estado especial o mantenemos el token

            // Opción 1: Emitir un estado solo con token (recomendado)
            emit(AuthTokenAuthenticated(
              userData: userData,
              token: token,
            ));

            // Opción 2: Intentar recuperar Firebase (depende de tu configuración)
            // await _authService.signInWithCustomToken(token);
          } catch (e) {
            debugPrint('❌ Error restaurando Firebase: $e');
            // Si falla, mantener sesión con token
            emit(AuthTokenAuthenticated(
              userData: userData,
              token: token,
            ));
          }
        }
        return;
      }
    }

    // No hay token
    debugPrint('🔴 [AUTH] No hay sesión activa');
    emit(AuthUnauthenticated());
  }

  // ================================
// LOGIN
// ================================
  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint('🔐 [AUTH] Intento de login para: ${event.email}');
    emit(AuthLoading());

    try {
      // ✅ PRIMERO: Login en el backend (sin Firebase)
      final response = await apiClient.post(
        'auth/login',
        {
          'email': event.email,
          'password': event.password,
        },
      );

      debugPrint('📦 [AUTH] Respuesta backend: $response');

      if (response['data'] == null) {
        debugPrint('❌ [AUTH] Respuesta inválida del backend');
        emit(const AuthError(message: 'Error del servidor'));
        return;
      }

      final backendToken = response['data']?['token'];
      final userRole = response['data']?['role'] ?? 'user';
      final userId = response['data']?['_id']?.toString() ?? '';
      final username = response['data']?['username'] ?? 'Usuario';

      if (backendToken == null || backendToken.isEmpty) {
        debugPrint('❌ [AUTH] No se recibió token del backend');
        emit(const AuthError(message: 'Credenciales inválidas'));
        return;
      }

      // ✅ SEGUNDO: Intentar login en Firebase (opcional, no crítico)
      User? firebaseUser;
      try {
        final result = await _authService.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        firebaseUser = result.user;
        debugPrint('✅ [AUTH] Firebase login exitoso');
      } catch (firebaseError) {
        debugPrint(
            '⚠️ [AUTH] Firebase login falló (no crítico): $firebaseError');
        // No es crítico, el usuario ya está autenticado con el backend
      }

      // ✅ TERCERO: Guardar token del backend
      await AuthStorage.saveToken(backendToken);
      await AuthStorage.saveUserData(
        userId: userId,
        email: event.email,
        role: userRole,
        username: response['data']?['username'], // 👈 AGREGAR
      );

      apiClient.setToken(backendToken);

      // ✅ CUARTO: Emitir estado autenticado
      if (firebaseUser != null) {
        emit(AuthAuthenticated(
          user: firebaseUser,
          userData: {
            'role': userRole,
            'userId': userId,
            'email': event.email,
            'username': username,
          },
        ));
      } else {
        // Si Firebase falla, igual estamos autenticados con el backend
        emit(AuthTokenAuthenticated(
          userData: {
            'role': userRole,
            'userId': userId,
            'email': event.email,
            'username': username,
          },
          token: backendToken,
        ));
      }

      debugPrint('✅ [AUTH] Login completo - Role: $userRole');
    } catch (e) {
      debugPrint('❌ [AUTH] Error inesperado: $e');
      emit(AuthError(message: 'Error al iniciar sesión: ${e.toString()}'));
    }
  }

  // ================================
  // LOGOUT
  // ================================
  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint('👋 [AUTH] Cerrando sesión');

    try {
      await AuthStorage.clearAll();
      apiClient.clearToken();
      await _authService.signOut();
      debugPrint('✅ [AUTH] Logout completado');
    } catch (e) {
      debugPrint('❌ [AUTH] Error en logout: $e');
    }

    emit(AuthUnauthenticated());
  }

  // ================================
  // CAMBIO EN FIREBASE AUTH
  // ================================
  Future<void> _onUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) async {
    final user = event.user;
    final hasToken = await AuthStorage.isLoggedIn();

    if (user == null) {
      // Firebase cerró sesión
      if (hasToken) {
        debugPrint('⚠️ [AUTH] Firebase null pero hay token - limpiando');
        await AuthStorage.clearAll();
        apiClient.clearToken();
      }
      emit(AuthUnauthenticated());
    } else {
      // Firebase detectó usuario
      if (!hasToken) {
        debugPrint('⚠️ [AUTH] Firebase user pero no token - cerrando Firebase');
        await _authService.signOut();
      } else {
        // Todo bien
        final userData = await AuthStorage.getUserData();
        emit(AuthAuthenticated(user: user, userData: userData));
      }
    }
  }
}
