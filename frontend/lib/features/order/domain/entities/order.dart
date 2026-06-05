import 'package:biye/features/cart/domain/entities/cart_item.dart';
import 'package:biye/features/address/domain/entities/address.dart';
import 'package:biye/features/payment_methods/domain/entities/payment_method.dart';

// ==========================================
// 🚚 CLASES DE SOPORTE PARA LOGÍSTICA
// ==========================================

class OrderTracking {
  final String? trackingNumber;
  final String
      status; // 'pending_label', 'ready_to_ship', 'in_transit', 'delivered', 'failed'
  final String? labelUrl;
  final DateTime? estimatedDelivery;

  OrderTracking({
    this.trackingNumber,
    required this.status,
    this.labelUrl,
    this.estimatedDelivery,
  });

  factory OrderTracking.fromJson(Map<String, dynamic> json) {
    return OrderTracking(
      trackingNumber: json['trackingNumber'],
      status: json['status'] ?? 'pending_label',
      labelUrl: json['labelUrl'],
      estimatedDelivery: json['estimatedDelivery'] != null
          ? DateTime.parse(json['estimatedDelivery'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'trackingNumber': trackingNumber,
        'status': status,
        'labelUrl': labelUrl,
        'estimatedDelivery': estimatedDelivery?.toIso8601String(),
      };

  /// Helper de UI para los textos amigables en Argentina
  String get statusText {
    switch (status) {
      case 'pending_label':
        return 'Preparando embalaje';
      case 'ready_to_ship':
        return 'Listo para despacho';
      case 'in_transit':
        return 'En viaje / Camino a tu domicilio';
      case 'delivered':
        return 'Entregado con éxito';
      case 'failed':
        return 'Incidencia en la entrega';
      default:
        return 'Procesando';
    }
  }
}

class OrderShipping {
  final String method; // 'pickup', 'custom_moto', 'carrier'
  final String? carrierName; // 'andreani', etc.
  final String? serviceType;
  final double cost;
  final Address?
      address; // Mapeado a tu entidad Address existente (null si es pickup)
  final OrderTracking tracking;

  OrderShipping({
    required this.method,
    this.carrierName,
    this.serviceType,
    required this.cost,
    this.address,
    required this.tracking,
  });

  factory OrderShipping.fromJson(Map<String, dynamic> json) {
    // 🎯 ACÁ ESTÁ EL FIX: Declaramos la variable local primero
    final methodType = json['method'] ?? 'pickup';

    return OrderShipping(
      method: methodType,
      carrierName: json['carrierName'],
      serviceType: json['serviceType'],
      cost: (json['cost'] ?? 0).toDouble(),

      // Ahora sí 'methodType' existe y es seguro usarlo acá abajo
      address: (methodType == 'pickup' ||
              json['address'] == null ||
              json['address']['street'] == null)
          ? null
          : Address.fromJson(json['address']),

      tracking: OrderTracking.fromJson(json['tracking'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'method': method,
        'carrierName': carrierName,
        'serviceType': serviceType,
        'cost': cost,
        'address': address?.toJson(),
        'tracking': tracking.toJson(),
      };
}

// ==========================================
// 📦 ENTIDAD PRINCIPAL (ORDER)
// ==========================================

class Order {
  final String? id;
  final List<CartItem> items;
  final PaymentMethod? paymentMethod;
  final double subtotal;
  final double tax;
  final double total;
  final String status;
  final DateTime createdAt;
  final OrderShipping shipping; // 👈 🚚 TODO LOGÍSTICA INTEGRADO AQUÍ

  Order({
    this.id,
    required this.items,
    required this.paymentMethod,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.shipping, // Requerido en constructor
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    try {
      // 🕵️‍♂️ DESENCAPSULADOR INTELIGENTE
      // Si el backend nos mandó la respuesta envuelta en { "success": true, "data": {...} }
      // extraemos la data de ahí adentro antes de parsear.
      final Map<String, dynamic> targetJson =
          (json.containsKey('data') && json['data'] is Map)
              ? json['data'] as Map<String, dynamic>
              : json;

      return Order(
        id: targetJson['_id'],

        // 🎯 Parseo seguro de Items
        items: targetJson['items'] != null
            ? (targetJson['items'] as List)
                .map((item) => CartItem.fromJson(item))
                .toList()
            : [],

        paymentMethod: targetJson['paymentMethod'] != null
            ? PaymentMethod.fromJson(targetJson['paymentMethod'])
            : null,

        subtotal: (targetJson['itemsPrice'] ?? targetJson['subtotal'] ?? 0)
            .toDouble(),
        tax: (targetJson['tax'] ?? 0).toDouble(),
        total:
            (targetJson['totalAmount'] ?? targetJson['total'] ?? 0).toDouble(),
        status: targetJson['status'] ?? 'PENDING',

        createdAt: targetJson['createdAt'] != null
            ? DateTime.parse(targetJson['createdAt'])
            : DateTime.now(),

        shipping: OrderShipping.fromJson(targetJson['shipping'] ?? {}),
      );
    } catch (e, stack) {
      print('🚨 [ERROR DE PARSEO EN ORDER]: $e');
      print('📦 [JSON CONFLICTIVO]: $json');
      print('📋 [STACKTRACE]: $stack');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'paymentMethod': paymentMethod?.toJson(),
      'itemsPrice': subtotal,
      'tax': tax,
      'totalAmount': total,
      'status': status,
      'shipping': shipping
          .toJson(), // Sincronizado para enviar al backend si hiciera falta
    };
  }

  // 💡 GETTERS INTERNOS (Para no romper código viejo si usabas order.shippingCost)
  double get shippingCost => shipping.cost;
  Address? get shippingAddress => shipping.address;
}
