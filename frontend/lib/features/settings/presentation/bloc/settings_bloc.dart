// lib/features/settings/presentation/bloc/settings_bloc.dart

import 'package:biye/features/settings/data/repositories/settings_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _repository;

  SettingsBloc({required SettingsRepository repository})
      : _repository = repository,
        super(SettingsLoading()) {
    on<LoadSettings>(_onLoadSettings);
    on<ToggleNotifications>(_onToggleNotifications);
    on<ChangeLanguage>(_onChangeLanguage);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    print('🔧 [SETTINGS] Cargando configuración...');
    emit(SettingsLoading());
    try {
      final settings = await _repository.getSettings();
      print(
          '🔧 [SETTINGS] Configuración cargada: ${settings.notificationsEnabled}, ${settings.language}');
      emit(SettingsLoaded(settings: settings));
    } catch (e) {
      print('❌ [SETTINGS] Error: $e');
      emit(SettingsError(message: 'Error al cargar configuración: $e'));
    }
  }

  Future<void> _onToggleNotifications(
    ToggleNotifications event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _repository.saveNotificationsEnabled(event.enabled);

      if (state is SettingsLoaded) {
        final currentSettings = (state as SettingsLoaded).settings;
        final updatedSettings = currentSettings.copyWith(
          notificationsEnabled: event.enabled,
        );
        emit(SettingsLoaded(settings: updatedSettings));
        emit(SettingsSuccess(
            message: event.enabled
                ? 'Notificaciones activadas'
                : 'Notificaciones desactivadas'));
      }
    } catch (e) {
      emit(SettingsError(message: 'Error al cambiar notificaciones: $e'));
    }
  }

  Future<void> _onChangeLanguage(
    ChangeLanguage event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _repository.saveLanguage(event.language);

      if (state is SettingsLoaded) {
        final currentSettings = (state as SettingsLoaded).settings;
        final updatedSettings = currentSettings.copyWith(
          language: event.language,
        );
        emit(SettingsLoaded(settings: updatedSettings));
        emit(SettingsSuccess(
            message: 'Idioma cambiado a ${_getLanguageName(event.language)}'));
      }
    } catch (e) {
      emit(SettingsError(message: 'Error al cambiar idioma: $e'));
    }
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'es':
        return 'Español';
      case 'en':
        return 'Inglés';
      default:
        return code;
    }
  }
}
