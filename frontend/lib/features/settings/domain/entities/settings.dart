// lib/features/settings/domain/entities/settings.dart

class Settings {
  final bool notificationsEnabled;
  final String language;
  final String appVersion;

  Settings({
    required this.notificationsEnabled,
    required this.language,
    required this.appVersion,
  });

  factory Settings.defaultSettings() {
    return Settings(
      notificationsEnabled: true,
      language: 'es',
      appVersion: '1.0.0',
    );
  }

  Settings copyWith({
    bool? notificationsEnabled,
    String? language,
    String? appVersion,
  }) {
    return Settings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      language: language ?? this.language,
      appVersion: appVersion ?? this.appVersion,
    );
  }
}
