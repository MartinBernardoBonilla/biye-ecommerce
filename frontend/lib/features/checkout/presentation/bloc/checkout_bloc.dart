// lib/features/checkout/presentation/bloc/checkout_bloc.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:biye/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:biye/features/address/presentation/bloc/address_bloc.dart';
import 'package:biye/features/address/presentation/bloc/address_event.dart';
import 'package:biye/features/address/presentation/bloc/address_state.dart';
import 'package:biye/features/payment_methods/presentation/bloc/payment_method_bloc.dart';
import 'package:biye/features/payment_methods/presentation/bloc/payment_method_event.dart';
import 'package:biye/features/payment_methods/presentation/bloc/payment_method_state.dart';
import 'package:biye/features/address/domain/entities/address.dart';
import 'package:biye/features/payment_methods/domain/entities/payment_method.dart';
import 'package:biye/core/utils/auth_storage.dart';
import 'checkout_event.dart';
import 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final CartBloc _cartBloc;
  final AddressBloc _addressBloc;
  final PaymentMethodBloc _paymentMethodBloc;
  final String _apiBaseUrl = 'http://192.168.1.49:5000';

  // Control de polling
  bool _isPollingActive = false;
  static const int _maxPollingAttempts = 20;
  static const int _pollingIntervalSeconds = 3;

  CheckoutBloc({
    required CartBloc cartBloc,
    required AddressBloc addressBloc,
    required PaymentMethodBloc paymentMethodBloc,
  })  : _cartBloc = cartBloc,
        _addressBloc = addressBloc,
        _paymentMethodBloc = paymentMethodBloc,
        super(CheckoutInitial()) {
    on<LoadCheckoutData>(_onLoadCheckoutData);
    on<InitializeCheckout>(_onInitializeCheckout);
    on<SelectAddress>(_onSelectAddress);
    on<SelectPaymentMethod>(_onSelectPaymentMethod);
    on<ConfirmOrder>(_onConfirmOrder);
    on<CheckPaymentStatus>(_onCheckPaymentStatus);
    on<StopPolling>(_onStopPolling); // ✅ Debe estar aquí
  }

  // ==================== INITIALIZE ====================
  Future<void> _onInitializeCheckout(
    InitializeCheckout event,
    Emitter<CheckoutState> emit,
  ) async {
    if (state is CheckoutLoaded) {
      final current = state as CheckoutLoaded;
      emit(current.copyWith(
        selectedAddress: null,
        selectedPaymentMethod: null,
      ));
    }
  }

  // ==================== LOAD CHECKOUT DATA ====================
  Future<void> _onLoadCheckoutData(
    LoadCheckoutData event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(CheckoutLoading());

    _addressBloc.add(LoadAddresses());
    _paymentMethodBloc.add(LoadPaymentMethods());

    await Future.any([
      _addressBloc.stream.firstWhere((s) => s is AddressesLoaded || s is AddressError),
      Future.delayed(const Duration(seconds: 5)),
    ]);
    await Future.any([
      _paymentMethodBloc.stream.firstWhere((s) => s is PaymentMethodsLoaded || s is PaymentMethodError),
      Future.delayed(const Duration(seconds: 5)),
    ]);

    final addresses = _getAddressesFromState();
    final paymentMethods = _getPaymentMethodsFromState();

    final cartState = _cartBloc.state;
    final items = cartState.items;
    final subtotal = cartState.total;
    final shippingCost = 0.0;
    final tax = subtotal * 0.21;
    final total = subtotal + shippingCost + tax;

    if (items.isEmpty) {
      emit(CheckoutError(message: 'No hay productos en el carrito'));
      return;
    }

    emit(CheckoutLoaded(
      items: items,
      addresses: addresses,
      paymentMethods: paymentMethods,
      subtotal: subtotal,
      shippingCost: shippingCost,
      tax: tax,
      total: total,
    ));
  }

  List<Address> _getAddressesFromState() {
    final addressState = _addressBloc.state;
    print('📦 AddressBloc state: ${addressState.runtimeType}');

    if (addressState is AddressesLoaded) {
      print('✅ Addresses cargados: ${addressState.addresses.length}');
      return addressState.addresses;
    }

    print('❌ AddressBloc NO es AddressesLoaded');
    return [];
  }

  List<PaymentMethod> _getPaymentMethodsFromState() {
    final state = _paymentMethodBloc.state;
    if (state is PaymentMethodsLoaded) {
      return state.methods;
    }
    return [];
  }

  // ==================== SELECT ADDRESS ====================
  Future<void> _onSelectAddress(
    SelectAddress event,
    Emitter<CheckoutState> emit,
  ) async {
    if (state is CheckoutLoaded) {
      final current = state as CheckoutLoaded;
      emit(current.copyWith(selectedAddress: event.address));
    }
  }

  // ==================== SELECT PAYMENT METHOD ====================
  Future<void> _onSelectPaymentMethod(
    SelectPaymentMethod event,
    Emitter<CheckoutState> emit,
  ) async {
    if (state is CheckoutLoaded) {
      final current = state as CheckoutLoaded;
      print(
          '🟢 Seleccionando método: ${event.method.displayName} (ID: ${event.method.id})');
      emit(current.copyWith(
        selectedPaymentMethod: event.method,
        selectedPaymentMethodId: event.method.id, // ✅ AGREGAR
      ));
    }
  }

// ==================== CREATE ORDER ====================
  Future<Map<String, dynamic>> _createOrder(CheckoutLoaded state) async {
    try {
      final token = await AuthStorage.getToken();
      if (token == null) {
        return {'success': false, 'error': 'Usuario no autenticado'};
      }

      final userData = await AuthStorage.getUserData();
      final userEmail = userData['email'] ?? 'cliente@biye.com';
      final userName = userData['username'] ??
          state.selectedAddress?.recipientName ??
          'Cliente';

      final orderData = {
        'items': state.items
            .map((item) => ({
                  'productId': item.id,
                  'quantity': item.quantity,
                  'price': item.price,
                  'name': item.name,
                }))
            .toList(),
        'shippingAddress': state.selectedAddress!.toJson(),
        'paymentMethod': state.selectedPaymentMethod!.toJson(),
        'subtotal': state.subtotal,
        'shippingCost': state.shippingCost,
        'tax': state.tax,
        'total': state.total,
        'currency': 'ARS',
        'status': 'PENDING',
        'buyerInfo': {
          'email': userEmail,
          'name': userName,
        },
      };

      final response = await http.post(
        Uri.parse('$_apiBaseUrl/api/v1/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(orderData),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        final order = data['order'] ?? data;
        final orderId = order['_id'];

        if (orderId != null) {
          final paymentBody = {
            'items': state.items
                .map((item) => ({
                      'title': item.name,
                      'quantity': item.quantity,
                      'unit_price': item.price,
                      'currency_id': 'ARS',
                    }))
                .toList(),
          };

          final paymentResponse = await http.post(
            Uri.parse('$_apiBaseUrl/api/v1/payments/qr/$orderId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(paymentBody),
          );

          final paymentData = jsonDecode(paymentResponse.body);

          return {
            'success': true,
            'orderId': orderId,
            'qrData': paymentData['qrData'],
            'qrImageBase64': paymentData['qrImageBase64'], // ✅ AGREGAR
            'paymentLink': paymentData['checkoutUrl'],
          };
        }
      }

      return {
        'success': false,
        'error': data['message'] ?? 'Error al crear orden'
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

// ==================== CONFIRM ORDER ====================
  Future<void> _onConfirmOrder(
    ConfirmOrder event,
    Emitter<CheckoutState> emit,
  ) async {
    if (state is! CheckoutLoaded) return;

    final current = state as CheckoutLoaded;

    if (!current.canProceed) {
      emit(CheckoutError(message: 'Selecciona dirección y método de pago'));
      return;
    }

    emit(CheckoutLoading());

    final result = await _createOrder(current);

    if (result['success'] == true) {
      final orderId = result['orderId'];
      final qrData = result['qrData'];
      final qrImageBase64 = result['qrImageBase64']; // ✅ AGREGAR
      final paymentLink = result['paymentLink'];
      final paymentMethodType = current.selectedPaymentMethod?.type;

      print('💰 Método de pago seleccionado: $paymentMethodType');

      final url =
          (paymentMethodType == 'card') ? (paymentLink ?? qrData) : qrData;

      emit(CheckoutOrderCreated(
        orderId: orderId,
        qrData: url,
        qrImageBase64: qrImageBase64, // ✅ AGREGAR
        paymentMethodType: paymentMethodType,
      ));

      add(CheckPaymentStatus(orderId: orderId));
    } else {
      emit(CheckoutError(
          message: result['error'] ?? 'Error al crear el pedido'));
    }
  }

  // ==================== POLLING CONTROLADO CON FALLBACK ====================
  Future<void> _onCheckPaymentStatus(
    CheckPaymentStatus event,
    Emitter<CheckoutState> emit,
  ) async {
    if (_isPollingActive) return;

    _isPollingActive = true;
    int attempts = 0;

    while (_isPollingActive && attempts < _maxPollingAttempts) {
      attempts++;

      await Future.delayed(Duration(seconds: _pollingIntervalSeconds));

      try {
        final token = await AuthStorage.getToken();
        if (token == null) {
          _isPollingActive = false;
          emit(CheckoutError(message: 'Sesión expirada'));
          return;
        }

        final response = await http.get(
          Uri.parse('$_apiBaseUrl/api/v1/payments/status/${event.orderId}'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final status = data['status'];

          print('🔄 Polling intento $attempts: status = $status');

          if (status == 'approved') {
            print('✅ Pago aprobado!');
            _isPollingActive = false;
            emit(CheckoutPaymentConfirmed(orderId: event.orderId));
            return;
          } else if (status == 'rejected') {
            print('❌ Pago rechazado');
            _isPollingActive = false;
            emit(CheckoutError(message: 'El pago fue rechazado'));
            return;
          }
        }
      } catch (e) {
        print('⚠️ Error en polling: $e');
      }
    }

    // ✅ TIMEOUT - FALLBACK: Consultar MP directamente
    if (_isPollingActive) {
      _isPollingActive = false;
      print('🔄 Timeout alcanzado. Consultando MP directamente...');

      await _fallbackCheckPaymentStatus(event.orderId, emit);
    }
  }

// ✅ FALLBACK: Consultar MP directamente cuando el polling falla
  Future<void> _fallbackCheckPaymentStatus(
    String orderId,
    Emitter<CheckoutState> emit,
  ) async {
    try {
      final token = await AuthStorage.getToken();
      if (token == null) {
        emit(CheckoutError(message: 'Sesión expirada'));
        return;
      }

      // Consultar nuestro backend (que a su vez puede consultar MP)
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/api/v1/payments/status/$orderId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = data['status'];

        print('📊 Fallback: status = $status');

        if (status == 'approved') {
          print('✅ Pago confirmado vía fallback!');
          emit(CheckoutPaymentConfirmed(orderId: orderId));
          return;
        } else if (status == 'rejected') {
          emit(CheckoutError(message: 'El pago fue rechazado'));
          return;
        }
      }

      // Si todo falla, ofrecer opción de verificar manualmente
      emit(CheckoutError(
        message:
            'Tiempo de espera agotado. Puedes verificar tu pago en MercadoPago.',
      ));
    } catch (e) {
      print('❌ Error en fallback: $e');
      emit(CheckoutError(
        message: 'No pudimos confirmar tu pago. Verifica en MercadoPago.',
      ));
    }
  }

  void _onStopPolling(StopPolling event, Emitter<CheckoutState> emit) {
    _isPollingActive = false;
    print('🛑 Polling detenido manualmente');
  }
}
