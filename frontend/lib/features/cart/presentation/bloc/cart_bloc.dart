import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:biye/features/cart/domain/entities/cart_item.dart';
import 'cart_event.dart';
import 'cart_state.dart';
import 'package:biye/features/payment/data/services/mercadopago_service.dart';
import 'package:biye/features/order/data/services/order_service.dart';
import 'package:biye/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:biye/features/auth/presentation/bloc/auth_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final MercadoPagoService mercadoPagoService;
  final OrderService orderService;
  final AuthBloc? authBloc;

  // 🆕 Timers para polling y expiración del QR
  Timer? _pollingTimer;
  Timer? _expirationTimer;

  CartBloc({
    required this.mercadoPagoService,
    required this.orderService,
    this.authBloc,
  }) : super(CartState.initial()) {
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<ClearCart>(_onClearCart);
    on<UpdateQuantity>(_onUpdateQuantity);
    on<StartCheckout>(_onStartCheckout);
    on<StartCheckoutWithQR>(_onStartCheckoutWithQR);

    // 🆕 Nuevos handlers para QR
    on<CheckQrPaymentStatus>(_onCheckQrPaymentStatus);
    on<QrExpired>(_onQrExpired);
  }

  /// 🔄 REEMPLAZA el mock anterior con llamada real al backend
  Future<void> _onStartCheckoutWithQR(
    StartCheckoutWithQR event,
    Emitter<CartState> emit,
  ) async {
    // Cancelar timers previos si existen
    _cancelTimers();

    // 1. Marcar como cargando
    emit(state.copyWith(
      isCheckoutLoading: true,
      checkoutError: null,
      paymentMethod: 'qr',
    ));

    try {
      // 2. Obtener info del usuario
      final authState = authBloc?.state;
      String buyerName = 'Invitado';
      String buyerEmail = 'invitado@biye.app';

      if (authState is AuthAuthenticated) {
        final user = authState.user;
        final userData = authState.userData;

        buyerName =
            userData?['firstName'] ?? user.email?.split('@').first ?? 'Usuario';
        buyerEmail = user.email ?? buyerEmail;
      }

      print('📱 Iniciando checkout con QR...');

      // 3. Crear orden en backend
      final orderId = await orderService.createOrder(
        items: _mapCartItemsToOrderItems(),
        buyerName: buyerName,
        buyerEmail: buyerEmail,
      );

      print('✅ Orden creada: $orderId');

      // 4. Crear QR de pago (llamada real al backend)
      final qrResponse = await mercadoPagoService.createQrPayment(orderId);

      print('✅ QR generado: ${qrResponse['qrData']}');

      // 5. Parsear fecha de expiración
      final expiresAt = qrResponse['expiresAt'] != null
          ? DateTime.parse(qrResponse['expiresAt'])
          : DateTime.now().add(const Duration(minutes: 10));

      // 6. Emitir estado con QR listo
      emit(state.copyWith(
        isCheckoutLoading: false,
        qrCode: qrResponse['qrData'],
        orderId: orderId,
        qrExpiresAt: expiresAt,
        isPolling: true,
        checkoutError: null,
      ));

      // 7. Iniciar polling y timer de expiración
      _startPolling(orderId);
      _startExpirationTimer(expiresAt);

      print('✅ Polling iniciado para orden: $orderId');
    } catch (e) {
      _cancelTimers();

      print('❌ Error creando QR: $e');

      emit(CheckoutErrorState(
        state: state,
        message: 'No se pudo generar el código QR: ${e.toString()}',
      ));
    }
  }

  /// 🆕 Inicia polling cada 3 segundos para verificar el pago
  void _startPolling(String orderId) {
    _pollingTimer?.cancel();

    _pollingTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) {
        print('🔄 Verificando estado del pago...');
        add(CheckQrPaymentStatus(orderId));
      },
    );
  }

  /// 🆕 Timer para cuando expire el QR (10 minutos)
  void _startExpirationTimer(DateTime expiresAt) {
    _expirationTimer?.cancel();

    final duration = expiresAt.difference(DateTime.now());

    if (duration.isNegative) {
      add(const QrExpired());
      return;
    }

    _expirationTimer = Timer(duration, () {
      print('⏰ QR expirado');
      add(const QrExpired());
    });
  }

  /// 🆕 Handler para verificar estado del pago (polling)
  /// 🆕 Handler para verificar estado del pago (polling) - CORREGIDO (Opción 1)
  Future<void> _onCheckQrPaymentStatus(
    CheckQrPaymentStatus event,
    Emitter<CartState> emit,
  ) async {
    try {
      // 👇 CORREGIDO: Usamos event.paymentId (que es el orderId)
      print('📡 POLLING A: ${event.paymentId}');

      final String status =
          await mercadoPagoService.checkPaymentStatus(event.paymentId);

      print('📊 Estado del pago recibido: $status');
      print('📊 Estado del pago recibido: "$status"');
      print('🔍 Longitud del status: ${status.length}');
      print('🔍 Códigos de caracteres: ${status.codeUnits}');

      // Normalizamos a minúsculas para comparar seguro
      final normalizedStatus = status.toLowerCase();

      if (normalizedStatus == 'approved' || normalizedStatus == 'paid') {
        _cancelTimers();

        print('✅ ¡Pago confirmado! Limpiando carrito...');

        emit(PaymentSuccessState(confirmedOrderId: event.paymentId));

        await Future.delayed(const Duration(seconds: 1));
        add(const ClearCart());
      } else if (normalizedStatus == 'rejected' ||
          normalizedStatus == 'cancelled') {
        _cancelTimers();

        emit(CheckoutErrorState(
          state: state.clearQrData(),
          message: 'El pago fue $status',
        ));
      }
      // Si es 'pending' o 'waiting_payment', el timer del Bloc volverá a disparar este evento
    } catch (e) {
      print('⚠️ Error en polling (reintentando): $e');
    }
  }

  /// 🆕 Handler cuando el QR expira
  Future<void> _onQrExpired(
    QrExpired event,
    Emitter<CartState> emit,
  ) async {
    _cancelTimers();

    print('⏰ QR ha expirado');

    emit(QrExpiredState(state: state.clearQrData()));
  }

  /// Cancela todos los timers activos
  void _cancelTimers() {
    _pollingTimer?.cancel();
    _expirationTimer?.cancel();
    _pollingTimer = null;
    _expirationTimer = null;
  }

  // ════════════════════════════════════════════════════════════════
  // MÉTODOS EXISTENTES (sin cambios)
  // ════════════════════════════════════════════════════════════════

  void _onAddToCart(AddToCart event, Emitter<CartState> emit) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((e) => e.id == event.item.id);

    if (index >= 0) {
      items[index] = items[index].copyWith(quantity: items[index].quantity + 1);
    } else {
      items.add(event.item.copyWith(quantity: 1));
    }

    _emitTotals(items, emit);
  }

  void _onRemoveFromCart(RemoveFromCart event, Emitter<CartState> emit) {
    final items = state.items.where((e) => e.id != event.itemId).toList();
    _emitTotals(items, emit);
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    _emitTotals([], emit);
  }

  void _onUpdateQuantity(UpdateQuantity event, Emitter<CartState> emit) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((e) => e.id == event.itemId);

    if (index >= 0) {
      if (event.quantity > 0) {
        items[index] = items[index].copyWith(quantity: event.quantity);
      } else {
        items.removeAt(index);
      }
    }

    _emitTotals(items, emit);
  }

  Future<void> _onStartCheckout(
    StartCheckout event,
    Emitter<CartState> emit,
  ) async {
    emit(CheckoutLoadingState(state: state));

    try {
      final authState = authBloc?.state;

      String buyerName = 'Invitado';
      String buyerEmail = 'invitado@biye.app';

      if (authState is AuthAuthenticated) {
        final user = authState.user;
        final userData = authState.userData;

        buyerName =
            userData?['firstName'] ?? user.email?.split('@').first ?? 'Usuario';

        buyerEmail = user.email ?? buyerEmail;
      }

      print('🚀 ¿Hay authBloc? ${authBloc != null}');
      print('🚀 Estado auth: ${authBloc?.state.runtimeType}');
      print(
          '🚀 User autenticado: ${authBloc?.state is AuthAuthenticated ? (authBloc!.state as AuthAuthenticated).user.email : "No autenticado"}');

      // 1️⃣ Crear orden en backend
      final orderId = await orderService.createOrder(
        items: _mapCartItemsToOrderItems(),
        buyerName: buyerName,
        buyerEmail: buyerEmail,
      );

      // 2️⃣ Crear preferencia Mercado Pago
      final checkoutUrl =
          await mercadoPagoService.createPaymentPreference(orderId);

      // 3️⃣ Éxito → la UI abre el checkout
      emit(
        state.copyWith(
          isCheckoutLoading: false,
          initPoint: checkoutUrl,
          checkoutError: null,
          paymentMethod: 'link',
        ),
      );
    } catch (e) {
      emit(
        CheckoutErrorState(
          state: state,
          message: e.toString(),
        ),
      );
    }
  }

  void _emitTotals(List<CartItem> items, Emitter<CartState> emit) {
    final total = items.fold(
      0.0,
      (sum, item) => sum + item.price * item.quantity,
    );

    emit(
      state.copyWith(
        items: items,
        total: total,
        isCheckoutLoading: false,
        checkoutError: null,
      ),
    );
  }

  List<Map<String, dynamic>> _mapCartItemsToOrderItems() {
    return state.items.map((item) {
      return {
        'productId': item.id,
        'quantity': item.quantity,
        'price': item.price, // 👈 AGREGAR
        'name': item.name,
      };
    }).toList();
  }

  @override
  Future<void> close() {
    _cancelTimers();
    return super.close();
  }
}
