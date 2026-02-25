import 'package:equatable/equatable.dart';
import 'package:biye/features/cart/domain/entities/cart_item.dart';

class CartState extends Equatable {
  final List<CartItem> items;
  final double total;
  final bool isLoading;
  final String? orderId;

  // Checkout
  final bool isCheckoutLoading;
  final String? initPoint;
  final String? checkoutError;

  // QR (campos actualizados)
  final String? qrCode; // texto del QR
  final String? qrBase64; // opcional base64
  final String? paymentMethod; // 'link' o 'qr'
  final DateTime? qrExpiresAt; // 🆕 Cuándo expira el QR
  final bool isPolling; // 🆕 Si estamos haciendo polling

  const CartState({
    this.items = const [],
    this.total = 0.0,
    this.isLoading = false,
    this.orderId,
    this.isCheckoutLoading = false,
    this.initPoint,
    this.checkoutError,
    this.qrCode,
    this.qrBase64,
    this.paymentMethod,
    this.qrExpiresAt,
    this.isPolling = false,
  });

  factory CartState.initial() => const CartState();

  CartState copyWith({
    List<CartItem>? items,
    double? total,
    bool? isLoading,
    String? orderId,
    bool? isCheckoutLoading,
    String? initPoint,
    String? checkoutError,
    String? qrCode,
    String? qrBase64,
    String? paymentMethod,
    DateTime? qrExpiresAt,
    bool? isPolling,
  }) {
    return CartState(
      items: items ?? this.items,
      total: total ?? this.total,
      isLoading: isLoading ?? this.isLoading,
      orderId: orderId ?? this.orderId,
      isCheckoutLoading: isCheckoutLoading ?? this.isCheckoutLoading,
      initPoint: initPoint ?? this.initPoint,
      checkoutError: checkoutError ?? this.checkoutError,
      qrCode: qrCode ?? this.qrCode,
      qrBase64: qrBase64 ?? this.qrBase64,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      qrExpiresAt: qrExpiresAt ?? this.qrExpiresAt,
      isPolling: isPolling ?? this.isPolling,
    );
  }

  /// 🆕 Helper para limpiar datos del QR
  CartState clearQrData() {
    return CartState(
      items: items,
      total: total,
      isLoading: isLoading,
      orderId: orderId,
      isCheckoutLoading: false,
      initPoint: initPoint,
      checkoutError: checkoutError,
      qrCode: null,
      qrBase64: null,
      paymentMethod: null,
      qrExpiresAt: null,
      isPolling: false,
    );
  }

  @override
  List<Object?> get props => [
        items,
        total,
        isLoading,
        orderId,
        isCheckoutLoading,
        initPoint,
        checkoutError,
        qrCode,
        qrBase64,
        paymentMethod,
        qrExpiresAt,
        isPolling,
      ];
}

/// Checkout States (las mantenemos como estaban)
class CheckoutLoadingState extends CartState {
  CheckoutLoadingState({required CartState state})
      : super(
          items: state.items,
          total: state.total,
          isCheckoutLoading: true,
          qrCode: state.qrCode,
          qrBase64: state.qrBase64,
          paymentMethod: state.paymentMethod,
          qrExpiresAt: state.qrExpiresAt,
          isPolling: state.isPolling,
        );
}

class CheckoutErrorState extends CartState {
  final String message;

  CheckoutErrorState({
    required CartState state,
    required this.message,
  }) : super(
          items: state.items,
          total: state.total,
          isCheckoutLoading: false,
          checkoutError: message,
          qrCode: state.qrCode,
          qrBase64: state.qrBase64,
          paymentMethod: state.paymentMethod,
          qrExpiresAt: state.qrExpiresAt,
          isPolling: state.isPolling,
        );

  @override
  List<Object?> get props => [...super.props, message];
}

/// 🆕 Estado cuando el QR expiró
class QrExpiredState extends CartState {
  QrExpiredState({required CartState state})
      : super(
          items: state.items,
          total: state.total,
          isCheckoutLoading: false,
          checkoutError: 'El código QR ha expirado',
        );
}

/// 🆕 Estado cuando el pago fue confirmado
class PaymentSuccessState extends CartState {
  final String confirmedOrderId;

  PaymentSuccessState({
    required this.confirmedOrderId,
  }) : super(
          items: const [], // Limpiamos el carrito
          total: 0.0,
          orderId: confirmedOrderId,
        );

  @override
  List<Object?> get props => [...super.props, confirmedOrderId];
}
