// lib/features/auth/presentation/bloc/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:biye/core/services/firebase_auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuthService _authService;

  AuthBloc({FirebaseAuthService? authService})
    : _authService = authService ?? FirebaseAuthService(),
      super(AuthInitial()) {
    on<AuthStarted>(_onAuthStarted);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
    on<AuthEmailVerificationRequested>(_onEmailVerificationRequested);

    // Escuchar cambios de autenticación
    _authService.authStateChanges.listen((User? user) async {
      if (user != null) {
        final userData = await _authService.getUserData(user.uid);
        emit(AuthAuthenticated(user: user, userData: userData));
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }

  void _onAuthStarted(AuthStarted event, Emitter<AuthState> emit) {
    final user = _authService.currentUser;
    if (user != null) {
      emit(AuthAuthenticated(user: user));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _authService.signInWithEmailAndPassword(
      email: event.email,
      password: event.password,
    );

    if (result.success && result.user != null) {
      final userData = await _authService.getUserData(result.user!.uid);
      emit(AuthAuthenticated(user: result.user!, userData: userData));
    } else {
      emit(AuthError(message: result.message));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _authService.registerWithEmailAndPassword(
      email: event.email,
      password: event.password,
      firstName: event.firstName,
      lastName: event.lastName,
    );

    if (result.success && result.user != null) {
      final userData = await _authService.getUserData(result.user!.uid);
      emit(AuthAuthenticated(user: result.user!, userData: userData));
    } else {
      emit(AuthError(message: result.message));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await _authService.signOut();
    emit(AuthUnauthenticated());
  }

  Future<void> _onPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final success = await _authService.resetPassword(event.email);

    if (success) {
      emit(AuthUnauthenticated());
    } else {
      emit(AuthError(message: 'Error al enviar email de recuperación'));
    }
  }

  Future<void> _onEmailVerificationRequested(
    AuthEmailVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    final success = await _authService.sendEmailVerification();

    if (!success) {
      emit(AuthError(message: 'Error al enviar email de verificación'));
    }
  }
}
