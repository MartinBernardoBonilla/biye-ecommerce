// lib/features/settings/data/repositories/settings_repository.dart

import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/settings.dart';

class SettingsRepository {
  static const String _keyNotifications = 'notifications_enabled';
  static const String _keyLanguage = 'language';

  Future<Settings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();

    return Settings(
      notificationsEnabled: prefs.getBool(_keyNotifications) ?? true,
      language: prefs.getString(_keyLanguage) ?? 'es',
      appVersion: '1.0.0',
    );
  }

  Future<void> saveNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, enabled);
  }

  Future<void> saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguage, language);
  }
}
