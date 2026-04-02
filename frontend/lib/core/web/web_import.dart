import 'dart:html' as html;

void notifyFlutterReady() {
  final event = html.Event('flutter-first-frame');
  html.window.dispatchEvent(event);
  print('✅ Evento flutter-first-frame emitido (web)');
}
