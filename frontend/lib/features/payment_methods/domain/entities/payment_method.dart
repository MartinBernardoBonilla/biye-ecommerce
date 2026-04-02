class PaymentMethod {
  final String id;
  final String type; // 'card', 'mercadopago', 'other'
  final CardDetails? cardDetails;
  final String? mpPaymentMethodId;
  final String? mpPaymentTypeId;
  final bool isDefault;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentMethod({
    required this.id,
    required this.type,
    this.cardDetails,
    this.mpPaymentMethodId,
    this.mpPaymentTypeId,
    required this.isDefault,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  // ✅ Agregar fromJson
  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['_id'],
      type: json['type'],
      cardDetails: json['cardDetails'] != null
          ? CardDetails.fromJson(json['cardDetails'])
          : null,
      mpPaymentMethodId: json['mpPaymentMethodId'],
      mpPaymentTypeId: json['mpPaymentTypeId'],
      isDefault: json['isDefault'] ?? false,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // ✅ Agregar toJson
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (cardDetails != null) 'cardDetails': cardDetails!.toJson(),
      if (mpPaymentMethodId != null) 'mpPaymentMethodId': mpPaymentMethodId,
      if (mpPaymentTypeId != null) 'mpPaymentTypeId': mpPaymentTypeId,
      'isDefault': isDefault,
      'isActive': isActive,
    };
  }

  String get displayName {
    if (type == 'card' && cardDetails != null) {
      return '${cardDetails!.brand.toUpperCase()} •••• ${cardDetails!.lastFourDigits}';
    }
    if (type == 'mercadopago') {
      return 'Mercado Pago';
    }
    return 'Otro';
  }

  String get iconName {
    if (type == 'card' && cardDetails != null) {
      switch (cardDetails!.brand.toLowerCase()) {
        case 'visa':
          return 'visa';
        case 'mastercard':
          return 'mastercard';
        case 'amex':
          return 'amex';
        default:
          return 'credit_card';
      }
    }
    return 'payment';
  }
}

class CardDetails {
  final String lastFourDigits;
  final String brand;
  final String expirationMonth;
  final String expirationYear;
  final String cardholderName;

  CardDetails({
    required this.lastFourDigits,
    required this.brand,
    required this.expirationMonth,
    required this.expirationYear,
    required this.cardholderName,
  });

  factory CardDetails.fromJson(Map<String, dynamic> json) {
    return CardDetails(
      lastFourDigits: json['lastFourDigits'],
      brand: json['brand'],
      expirationMonth: json['expirationMonth'],
      expirationYear: json['expirationYear'],
      cardholderName: json['cardholderName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastFourDigits': lastFourDigits,
      'brand': brand,
      'expirationMonth': expirationMonth,
      'expirationYear': expirationYear,
      'cardholderName': cardholderName,
    };
  }
}
