// lib/features/settings/presentation/bloc/settings_event.dart

import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {}

class ToggleNotifications extends SettingsEvent {
  final bool enabled;
  const ToggleNotifications({required this.enabled});
  @override
  List<Object?> get props => [enabled];
}

class ChangeLanguage extends SettingsEvent {
  final String language;
  const ChangeLanguage({required this.language});
  @override
  List<Object?> get props => [language];
}
