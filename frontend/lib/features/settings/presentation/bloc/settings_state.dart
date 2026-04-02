// lib/features/settings/presentation/bloc/settings_state.dart

import 'package:biye/features/settings/domain/entities/settings.dart';
import 'package:equatable/equatable.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();
  @override
  List<Object?> get props => [];
}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final Settings settings;
  const SettingsLoaded({required this.settings});
  @override
  List<Object?> get props => [settings];
}

class SettingsSuccess extends SettingsState {
  final String message;
  const SettingsSuccess({required this.message});
  @override
  List<Object?> get props => [message];
}

class SettingsError extends SettingsState {
  final String message;
  const SettingsError({required this.message});
  @override
  List<Object?> get props => [message];
}
