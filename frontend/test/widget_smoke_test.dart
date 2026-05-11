import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:biye/core/widgets/modern_card.dart';

void main() {
  testWidgets('ModernCard muestra su child correctamente',
      (WidgetTester tester) async {
    const testText = 'Contenido de prueba';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ModernCard(
            child: const Text(testText),
          ),
        ),
      ),
    );

    expect(find.text(testText), findsOneWidget);
  });

  testWidgets('ModernCard responde al tap cuando onTap no es nulo',
      (WidgetTester tester) async {
    bool wasTapped = false;
    const testText = 'Tócame';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ModernCard(
            onTap: () => wasTapped = true,
            child: const Text(testText),
          ),
        ),
      ),
    );

    expect(find.text(testText), findsOneWidget);
    await tester.tap(find.byType(ModernCard));
    expect(wasTapped, true);
  });
}
