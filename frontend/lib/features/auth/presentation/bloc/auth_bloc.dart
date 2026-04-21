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
    on<AuthStarted>(_onAuthStarted);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthUserChanged>(_onUserChanged);
    on<AuthCheckStatus>(_onCheckStatus);

    _authService.authStateChanges.listen(
      (user) => add(AuthUserChanged(user)),
    );

    add(AuthCheckStatus());
  }

  // ================================
  // INIT
  // ================================
  void _onAuthStarted(
    AuthStarted event,
    Emitter<AuthState> emit,
  ) {
    add(AuthCheckStatus());
  }

  // ================================
  // CHECK STATUS
  // ================================
  Future<void> _onCheckStatus(
    AuthCheckStatus event,
    Emitter<AuthState> emit,
  ) async {
    final hasToken = await AuthStorage.isLoggedIn();
    final userData = await AuthStorage.getUserData();
    final firebaseUser = _authService.currentUser;

    if (hasToken) {
      final token = await AuthStorage.getToken();

      if (token != null) {
        apiClient.setToken(token);

        if (firebaseUser != null) {
          emit(AuthAuthenticated(
            user: firebaseUser,
            userData: userData,
          ));
        } else {
          emit(AuthTokenAuthenticated(
            userData: userData,
            token: token,
          ));
        }
        return;
      }
    }

    emit(AuthUnauthenticated());
  }

  // ================================
  // LOGIN 🔥 CORREGIDO
  // ================================
  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final response = await apiClient.post(
        'auth/login',
        {
          'email': event.email,
          'password': event.password,
        },
      );

      final data = response['data'];

      if (data == null) {
        emit(const AuthError(message: 'Error del servidor'));
        return;
      }

      final String token = data['token'];
      final String refreshToken = data['refreshToken'];

      final String userId = data['_id']?.toString() ?? '';
      final String email = data['email'] ?? event.email;
      final String role = data['role'] ?? 'user';
      final String username = data['username'] ?? 'Usuario';

      if (token.isEmpty) {
        emit(const AuthError(message: 'Credenciales inválidas'));
        return;
      }

      // 🔥 FIREBASE (OPCIONAL)
      User? firebaseUser;

      try {
        final result = await _authService.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        firebaseUser = result.user;
      } catch (_) {}

      // 🔥 GUARDAR TOKENS
      await AuthStorage.saveToken(token);
      await AuthStorage.saveRefreshToken(refreshToken);

      await AuthStorage.saveUserData(
        userId: userId,
        email: email,
        role: role,
        username: username,
      );

      apiClient.setToken(token);

      // 🔥 EMITIR ESTADO
      if (firebaseUser != null) {
        emit(AuthAuthenticated(
          user: firebaseUser,
          userData: {
            'userId': userId,
            'email': email,
            'role': role,
            'username': username,
          },
        ));
      } else {
        emit(AuthTokenAuthenticated(
          userData: {
            'userId': userId,
            'email': email,
            'role': role,
            'username': username,
          },
          token: token,
        ));
      }
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
    await AuthStorage.clearAll();
    apiClient.clearToken();

    try {
      await _authService.signOut();
    } catch (_) {}

    emit(AuthUnauthenticated());
  }

  // ================================
  // FIREBASE LISTENER
  // ================================
  Future<void> _onUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) async {
    final user = event.user;
    final hasToken = await AuthStorage.isLoggedIn();

    if (user == null) {
      if (hasToken) {
        final userData = await AuthStorage.getUserData();
        final token = await AuthStorage.getToken();

        emit(AuthTokenAuthenticated(
          userData: userData,
          token: token ?? '',
        ));
      } else {
        emit(AuthUnauthenticated());
      }
    } else {
      if (!hasToken) {
        await _authService.signOut();
      } else {
        final userData = await AuthStorage.getUserData();
        emit(AuthAuthenticated(user: user, userData: userData));
      }
    }
  }
}
