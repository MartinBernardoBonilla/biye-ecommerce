// lib/features/admin/presentation/utils/order_ui_helper.dart
import 'package:flutter/material.dart';

class OrderUiHelper {
  // Color para UI según estado
  static Color getStatusColor(String status) {
    switch (status) {
      case 'PAID':
        return Colors.green;
      case 'WAITING_PAYMENT':
        return Colors.orange;
      case 'CANCELLED':
      case 'PAYMENT_REJECTED':
        return Colors.red;
      case 'REFUNDED':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  // Texto para UI según estado
  static String getStatusText(String status) {
    switch (status) {
      case 'PAID':
        return 'Pagado';
      case 'WAITING_PAYMENT':
        return 'Esperando pago';
      case 'CANCELLED':
        return 'Cancelado';
      case 'PAYMENT_REJECTED':
        return 'Rechazado';
      case 'REFUNDED':
        return 'Reembolsado';
      default:
        return status;
    }
  }

  // Formatear fecha para UI
  static String formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 0) {
      return '${diff.inDays}d';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m';
    } else {
      return 'ahora';
    }
  }
}
