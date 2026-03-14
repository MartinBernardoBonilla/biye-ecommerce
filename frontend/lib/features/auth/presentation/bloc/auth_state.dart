// lib/features/auth/presentation/bloc/auth_state.dart

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

// Estado para autenticación COMPLETA (Firebase + Token)
class AuthAuthenticated extends AuthState {
  final User user;
  final Map<String, dynamic>? userData;

  const AuthAuthenticated({required this.user, this.userData});

  @override
  List<Object?> get props => [user, userData];
}

// 👇 SOLO UNA DEFINICIÓN (eliminé la duplicada)
class AuthTokenAuthenticated extends AuthState {
  final Map<String, String?> userData;
  final String token;

  const AuthTokenAuthenticated({
    required this.userData,
    required this.token,
  });

  @override
  List<Object?> get props => [userData, token];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}
