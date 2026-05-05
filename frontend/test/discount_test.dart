import 'package:flutter_test/flutter_test.dart';

double applyDiscount(double total, String couponCode) {
  if (couponCode == 'DESCUENTO10') {
    return total * 0.9; // 10% off
  } else if (couponCode == 'DESCUENTO20') {
    return total * 0.8; // 20% off
  } else if (couponCode == 'ENVIOGRATIS') {
    return total; // por ahora solo ejemplo, sin cambios
  }
  return total; // cupón inválido
}

void main() {
  group('Aplicar descuentos', () {
    test('Sin cupón = mismo precio', () {
      expect(applyDiscount(100, ''), 100);
    });

    test('Cupón inválido = mismo precio', () {
      expect(applyDiscount(100, 'INVALIDO'), 100);
    });

    test('DESCUENTO10 aplica 10% off', () {
      expect(applyDiscount(100, 'DESCUENTO10'), 90);
    });

    test('DESCUENTO20 aplica 20% off', () {
      expect(applyDiscount(100, 'DESCUENTO20'), 80);
    });

    test('Descuento con decimales', () {
      expect(applyDiscount(99.99, 'DESCUENTO10'), 89.991);
    });
  });
}
