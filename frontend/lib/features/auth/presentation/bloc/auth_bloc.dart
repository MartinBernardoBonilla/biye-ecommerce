import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_event.dart';
import 'auth_state.dart';

import 'package:biye/core/services/firebase_auth_service.dart';
import 'package:biye/core/network/api_client.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuthService? _authService;
  final ApiClient apiClient;

  AuthBloc({
    FirebaseAuthService? authService,
    required this.apiClient,
  })  : _authService = kIsWeb ? null : (authService ?? FirebaseAuthService()),
        super(AuthInitial()) {
    // ✅ REGISTRAR SIEMPRE LOS EVENTS
    on<AuthStarted>(_onAuthStarted);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthUserChanged>(_onUserChanged);

    // 🔥 SOLO escuchar Firebase si existe
    if (_authService != null) {
      _authService!.authStateChanges.listen(
        (user) => add(AuthUserChanged(user)),
      );
    }
  }

  // ================================
  // APP START
  // ================================
  void _onAuthStarted(
    AuthStarted event,
    Emitter<AuthState> emit,
  ) {
    final user = _authService?.currentUser;

    if (user == null) {
      apiClient.clearToken();
      emit(AuthUnauthenticated());
    }
  }

  // ================================
  // LOGIN
  // ================================
  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (_authService == null) return;

    emit(AuthLoading());

    try {
      // 1️⃣ Login Firebase (solo validación UI)
      final result = await _authService!.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      final User user = result.user!;

      // 2️⃣ Login BACKEND (obtener JWT real)
      final response = await apiClient.post(
        'auth/login',
        {
          'email': event.email,
          'password': event.password,
        },
      );

      final backendToken = response['data']['token'];

      if (backendToken == null || backendToken.isEmpty) {
        emit(AuthError(message: 'No se pudo obtener token del backend'));
        return;
      }
      print('🧪 AuthBloc usando ApiClient: $apiClient');

      // 3️⃣ Guardar JWT del backend
      apiClient.setToken(backendToken);

      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  // ================================
  // LOGOUT
  // ================================
  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (_authService == null) return;

    await _authService!.signOut();

    apiClient.clearToken();

    emit(AuthUnauthenticated());
  }

  // ================================
  // AUTH STATE CHANGED (Firebase)
  // ================================
  Future<void> _onUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) async {
    final user = event.user;

    if (user == null) {
      apiClient.clearToken();
      emit(AuthUnauthenticated());
    } else {
      // ⚠️ NO tocar token acá
      emit(AuthAuthenticated(user: user));
    }
  }
}
