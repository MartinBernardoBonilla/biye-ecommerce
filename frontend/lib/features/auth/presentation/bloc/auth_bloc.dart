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
    if (_authService != null) {
      on<AuthStarted>(_onAuthStarted);
      on<AuthLoginRequested>(_onLoginRequested);
      on<AuthLogoutRequested>(_onLogoutRequested);
      on<AuthUserChanged>(_onUserChanged);

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
      apiClient.updateToken(null);
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
      final result = await _authService!.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      final User user = result.user!;

      // 🔥 OBTENER TOKEN
      final String? token = await user.getIdToken();

      if (token == null || token.isEmpty) {
        emit(AuthError(message: 'No se pudo obtener el token'));
        return;
      }

      // 🔥 GUARDAR TOKEN EN API CLIENT
      apiClient.updateToken(token);

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

    apiClient.updateToken(null);

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
      apiClient.updateToken(null);
      emit(AuthUnauthenticated());
    } else {
      final token = await user.getIdToken();
      apiClient.updateToken(token);
      emit(AuthAuthenticated(user: user));
    }
  }
}
