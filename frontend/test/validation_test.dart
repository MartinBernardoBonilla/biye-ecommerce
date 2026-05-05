import 'package:flutter_test/flutter_test.dart';

// Funciones de validación (copiá estas o adaptalas a las tuyas reales)
bool isValidEmail(String email) {
  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  return emailRegex.hasMatch(email);
}

bool isValidPhone(String phone) {
  final phoneRegex = RegExp(r'^\d{7,15}$');
  return phoneRegex.hasMatch(phone);
}

bool isFormValid(String email, String phone) {
  return isValidEmail(email) && isValidPhone(phone);
}

void main() {
  group('Validación de email', () {
    test('Email válido', () {
      expect(isValidEmail('test@example.com'), true);
    });

    test('Email sin @ es inválido', () {
      expect(isValidEmail('testexample.com'), false);
    });

    test('Email sin dominio es inválido', () {
      expect(isValidEmail('test@'), false);
    });

    test('Email vacío es inválido', () {
      expect(isValidEmail(''), false);
    });
  });

  group('Validación de teléfono', () {
    test('Teléfono válido (10 dígitos)', () {
      expect(isValidPhone('1234567890'), true);
    });

    test('Teléfono muy corto es inválido', () {
      expect(isValidPhone('123'), false);
    });

    test('Teléfono vacío es inválido', () {
      expect(isValidPhone(''), false);
    });
  });

  group('Formulario completo', () {
    test('Formulario válido', () {
      expect(isFormValid('test@example.com', '1234567890'), true);
    });

    test('Email inválido hace fallar el formulario', () {
      expect(isFormValid('invalid', '1234567890'), false);
    });

    test('Teléfono inválido hace fallar el formulario', () {
      expect(isFormValid('test@example.com', '123'), false);
    });
  });
}
