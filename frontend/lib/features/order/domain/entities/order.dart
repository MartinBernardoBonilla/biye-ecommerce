// lib/features/order/domain/entities/order.dart

import 'package:biye/features/cart/domain/entities/cart_item.dart';
import 'package:biye/features/address/domain/entities/address.dart';
import 'package:biye/features/payment_methods/domain/entities/payment_method.dart';

class Order {
  final String? id;
  final List<CartItem> items;
  final Address shippingAddress;
  final PaymentMethod paymentMethod;
  final double subtotal;
  final double shippingCost;
  final double tax;
  final double total;
  final String status;
  final DateTime createdAt;

  Order({
    this.id,
    required this.items,
    required this.shippingAddress,
    required this.paymentMethod,
    required this.subtotal,
    required this.shippingCost,
    required this.tax,
    required this.total,
    required this.status,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'],
      items: (json['items'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList(),
      shippingAddress: Address.fromJson(json['shippingAddress']),
      paymentMethod: PaymentMethod.fromJson(json['paymentMethod']),
      subtotal: json['subtotal'].toDouble(),
      shippingCost: json['shippingCost'].toDouble(),
      tax: json['tax'].toDouble(),
      total: json['total'].toDouble(),
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'shippingAddress': shippingAddress.toJson(),
      'paymentMethod': paymentMethod.toJson(),
      'subtotal': subtotal,
      'shippingCost': shippingCost,
      'tax': tax,
      'total': total,
      'status': status,
    };
  }
}
