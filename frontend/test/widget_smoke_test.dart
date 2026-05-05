import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Un widget simple de prueba (reemplazá con uno de tu app si existe sin Firebase)
class DummyButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const DummyButton({required this.onPressed, required this.label});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

void main() {
  testWidgets('El botón existe y se puede presionar',
      (WidgetTester tester) async {
    bool wasPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DummyButton(
            onPressed: () => wasPressed = true,
            label: 'Presioname',
          ),
        ),
      ),
    );

    expect(find.text('Presioname'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);

    await tester.tap(find.byType(ElevatedButton));
    expect(wasPressed, true);
  });
}
