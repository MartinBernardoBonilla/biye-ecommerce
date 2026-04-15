// lib/features/payment_methods/domain/entities/payment_method.dart

class PaymentMethod {
  final String id;
  final String type;
  final String name;
  final String displayName;
  final bool isDefault;
  final CardDetails? cardDetails;

  const PaymentMethod({
    required this.id,
    required this.type,
    required this.name,
    required this.displayName,
    this.isDefault = false,
    this.cardDetails,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      name: json['name'] ?? '',
      displayName: json['displayName'] ??
          '${json['brand'] ?? ''} **** ${json['lastFourDigits'] ?? ''}',
      isDefault: json['isDefault'] ?? false,
      cardDetails: json['cardDetails'] != null
          ? CardDetails.fromJson(json['cardDetails'])
          : (json['brand'] != null
              ? CardDetails(
                  brand: json['brand'],
                  lastFourDigits: json['lastFourDigits'] ?? '',
                  expirationMonth:
                      int.tryParse(json['expirationMonth'].toString()) ?? 0,
                  expirationYear:
                      int.tryParse(json['expirationYear'].toString()) ?? 0,
                  cardholderName: json['cardholderName'] ?? '',
                )
              : null),
    );
  }

  // ✅ Agregamos toJson()
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'displayName': displayName,
      'isDefault': isDefault,
      'cardDetails': cardDetails?.toJson(),
      if (cardDetails != null) 'cardDetails': cardDetails!.toJson(),
    };
  }
}

class CardDetails {
  final String brand;
  final String lastFourDigits;
  final int expirationMonth;
  final int expirationYear;
  final String cardholderName;

  const CardDetails({
    required this.brand,
    required this.lastFourDigits,
    required this.expirationMonth,
    required this.expirationYear,
    required this.cardholderName,
  });

  factory CardDetails.fromJson(Map<String, dynamic> json) {
    return CardDetails(
      brand: json['brand'] ?? '',
      lastFourDigits: json['lastFourDigits'] ?? '',
      expirationMonth: int.tryParse(json['expirationMonth'].toString()) ?? 0,
      expirationYear: int.tryParse(json['expirationYear'].toString()) ?? 0,
      cardholderName: json['cardholderName'] ?? '',
    );
  }

  // ✅ También agregamos toJson() a CardDetails
  Map<String, dynamic> toJson() {
    return {
      'brand': brand,
      'lastFourDigits': lastFourDigits,
      'expirationMonth': expirationMonth,
      'expirationYear': expirationYear,
      'cardholderName': cardholderName,
    };
  }
}
