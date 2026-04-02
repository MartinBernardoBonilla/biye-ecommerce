class Address {
  final String id;
  final String alias;
  final String recipientName;
  final String phone;
  final String street;
  final String number;
  final String? apartment;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final bool isDefault;
  final String? instructions;
  final DateTime createdAt;
  final DateTime updatedAt;

  Address({
    required this.id,
    required this.alias,
    required this.recipientName,
    required this.phone,
    required this.street,
    required this.number,
    this.apartment,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.isDefault,
    this.instructions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['_id'],
      alias: json['alias'],
      recipientName: json['recipientName'],
      phone: json['phone'],
      street: json['street'],
      number: json['number'],
      apartment: json['apartment'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postalCode'],
      country: json['country'],
      isDefault: json['isDefault'] ?? false,
      instructions: json['instructions'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'alias': alias,
      'recipientName': recipientName,
      'phone': phone,
      'street': street,
      'number': number,
      if (apartment != null && apartment!.isNotEmpty) 'apartment': apartment,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'isDefault': isDefault,
      if (instructions != null && instructions!.isNotEmpty)
        'instructions': instructions,
    };
  }

  String get fullAddress {
    final parts = [
      '$street $number',
      if (apartment != null && apartment!.isNotEmpty) 'Piso/Apto: $apartment',
      '$city, $state',
      postalCode,
      country,
    ];
    return parts.where((p) => p.isNotEmpty).join(', ');
  }
}
