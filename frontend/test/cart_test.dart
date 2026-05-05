import 'package:flutter_test/flutter_test.dart';

double calculateTotal(List<Map<String, dynamic>> items) {
  double total = 0;
  for (var item in items) {
    total += (item['price'] as num) * (item['quantity'] as num);
  }
  return total;
}

void main() {
  test('Calcula el total correctamente', () {
    final items = <Map<String, dynamic>>[
      {'price': 100, 'quantity': 2},
      {'price': 50, 'quantity': 1},
    ];
    expect(calculateTotal(items), 250);
  });

  test('Carrito vacío da total 0', () {
    final items = <Map<String, dynamic>>[];
    expect(calculateTotal(items), 0);
  });

  test('Maneja precios con decimales', () {
    final items = <Map<String, dynamic>>[
      {'price': 99.99, 'quantity': 1},
      {'price': 0.01, 'quantity': 1},
    ];
    expect(calculateTotal(items), 100.0);
  });
}
