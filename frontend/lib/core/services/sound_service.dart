// lib/core/services/sound_service.dart

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isEnabled = true;

  // Configurar si los sonidos están habilitados
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  bool get isEnabled => _isEnabled;

  // Reproducir sonido de splash
  Future<void> playSplashSound() async {
    if (!_isEnabled) return;
    try {
      await _player.play(AssetSource('sounds/splash.mp3'));
      if (kDebugMode) print('🔊 Sonido de splash reproducido');
    } catch (e) {
      if (kDebugMode) print('❌ Error reproduciendo sonido de splash: $e');
    }
  }

  // Reproducir sonido de pago exitoso
  Future<void> playPaymentSuccessSound() async {
    if (!_isEnabled) return;
    try {
      await _player.play(AssetSource('sounds/payment_success.mp3'));
      if (kDebugMode) print('🔊 Sonido de pago exitoso reproducido');
    } catch (e) {
      if (kDebugMode) print('❌ Error reproduciendo sonido de pago: $e');
    }
  }

  // Reproducir sonido de clic en botón (opcional)
  Future<void> playClickSound() async {
    if (!_isEnabled) return;
    try {
      await _player.play(AssetSource('sounds/click.mp3'));
    } catch (e) {
      if (kDebugMode) print('❌ Error reproduciendo sonido de clic: $e');
    }
  }

  // Detener cualquier sonido
  Future<void> stop() async {
    await _player.stop();
  }

  // Liberar recursos
  void dispose() {
    _player.dispose();
  }
}
