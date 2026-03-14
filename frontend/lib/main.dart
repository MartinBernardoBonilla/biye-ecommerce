import 'package:biye/core/widgets/persistent_bottom_nav.dart';
import 'package:biye/features/admin/presentation/pages/admin_order_detail_page.dart';
import 'package:biye/features/admin/presentation/pages/admin_orders_page.dart';
import 'package:biye/features/admin/presentation/pages/admin_users_page.dart';
import 'package:biye/features/cart/presentation/pages/enhanced_cart_page.dart';
import 'package:biye/features/order/presentation/pages/my_orders_page.dart';
import 'package:biye/features/order/presentation/pages/order_detail_page.dart';
import 'package:biye/features/product/presentation/pages/product_detail_page.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'shared/utils/network_test.dart';

// PROVIDER
import 'package:provider/provider.dart';

import 'core/network/api_client.dart';

// CORE
import 'core/navigation/navigator_key.dart';
import 'core/utils/payment_deep_link_handler.dart';

// ADMIN
import 'package:biye/features/admin/data/services/admin_service.dart';
import 'package:biye/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:biye/features/admin/domain/repositories/admin_repository_impl.dart';
import 'package:biye/features/admin/presentation/pages/admin_login_page.dart';
import 'package:biye/features/admin/presentation/pages/admin_panel_page.dart';
import 'package:biye/features/product/presentation/pages/product_management_page.dart';
import 'package:biye/features/product/presentation/pages/admin/admin_create_product_page.dart';
import 'package:biye/features/product/presentation/pages/admin/admin_edit_product_page.dart';
import 'package:biye/features/admin/presentation/pages/admin_dashboard_page.dart';

// AUTH
import 'package:biye/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:biye/features/auth/presentation/login_screen.dart';
import 'package:biye/features/auth/presentation/registration_screen.dart';
import 'package:biye/features/auth/presentation/bloc/auth_event.dart';

// CART / ORDER / PAYMENT
import 'package:biye/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:biye/features/order/data/services/order_service.dart';
import 'package:biye/features/payment/data/services/mercadopago_service.dart';

// ORDER BLOC
import 'package:biye/features/order/presentation/bloc/order_bloc.dart';
import 'package:biye/features/order/data/repositories/order_repository_impl.dart';
import 'package:biye/features/order/data/datasources/order_remote_datasource.dart';

// HOME
import 'package:biye/features/home/presentation/home_screen.dart';

// PAYMENT RESULT
import 'package:biye/features/payment/presentation/pages/payment_success_page.dart';
import 'package:biye/features/payment/presentation/pages/payment_pending_page.dart';
import 'package:biye/features/payment/presentation/pages/payment_failure_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kDebugMode) {
    NetworkTest.runTest();
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PaymentDeepLinkHandler.initialize(navigatorKey);
    });
  }

  @override
  void dispose() {
    PaymentDeepLinkHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseUrl = kDebugMode
        ? 'https://shanae-shearless-rakishly.ngrok-free.dev'
        : 'https://api.biye.com';

    return MultiProvider(
      providers: [
        Provider<ApiClient>(
          create: (_) => ApiClient(),
        ),
        Provider<AdminService>(
          create: (context) => AdminService(
            apiClient: context.read<ApiClient>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) {
              print('🚀 Creando AuthBloc...');
              final authBloc = AuthBloc(
                apiClient: context.read<ApiClient>(),
              );
              authBloc.add(AuthCheckStatus());
              return authBloc;
            },
          ),
          BlocProvider<OrderBloc>(
            create: (context) => OrderBloc(
              repository: OrderRepositoryImpl(
                remoteDataSource: OrderRemoteDataSource(
                  baseUrl: baseUrl, // ✅ AHORA SÍ, usa la baseUrl de main.dart
                  client: http.Client(), // ✅ http.Client en lugar de ApiClient
                ),
              ),
            ),
          ),
          BlocProvider<CartBloc>(
            create: (context) => CartBloc(
              authBloc: context.read<AuthBloc>(),
              mercadoPagoService: MercadoPagoService(),
              orderService: OrderService(),
            ),
          ),
          BlocProvider<AdminBloc>(
            create: (context) => AdminBloc(
              repository: AdminRepositoryImpl(
                baseUrl: baseUrl,
                client: http.Client(), // ✅ ESTO ESTÁ BIEN
              ),
            ),
          ),
        ],
        child: Builder(
          builder: (context) => MaterialApp(
            navigatorKey: navigatorKey,
            title: 'Biye',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(primarySwatch: Colors.blue),
            initialRoute: '/',
            onGenerateRoute: (settings) {
              // Aquí el context SÍ tiene acceso a los providers
              switch (settings.name) {
                // 🏠 PÚBLICAS CON NAVBAR PERSISTENTE
                case '/':
                case '/products':
                case '/profile':
                  return MaterialPageRoute(
                    builder: (context) => const PersistentBottomNav(
                      child: SizedBox.shrink(),
                    ),
                  );

                // Rutas SIN NAVBAR PERSISTENTE
                case '/login':
                  return MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  );
                case '/register':
                  return MaterialPageRoute(
                    builder: (context) => const RegistrationScreen(),
                  );
                case '/product-detail':
                  final args = settings.arguments as String;
                  return MaterialPageRoute(
                    builder: (context) => ProductDetailPage(productId: args),
                  );
                case '/cart':
                  return MaterialPageRoute(
                    builder: (context) => const CartPage(),
                  );

                // 👑 ADMIN
                case AdminLoginPage.routeName:
                  return MaterialPageRoute(
                    builder: (context) => const AdminLoginPage(),
                  );
                case AdminPanelPage.routeName:
                  return MaterialPageRoute(
                    builder: (context) => const AdminPanelPage(),
                  );
                case AdminDashboardPage.routeName:
                  return MaterialPageRoute(
                    builder: (context) => const AdminDashboardPage(),
                  );
                case AdminOrdersPage.routeName:
                  return MaterialPageRoute(
                    builder: (context) => const AdminOrdersPage(),
                  );
                case AdminOrderDetailPage.routeName:
                  return MaterialPageRoute(
                    builder: (context) => const AdminOrderDetailPage(),
                  );
                case AdminUsersPage.routeName:
                  return MaterialPageRoute(
                    builder: (context) => const AdminUsersPage(),
                  );

                // 📦 PRODUCTOS (ADMIN)
                case ProductManagementPage.routeName:
                  final args = settings.arguments as Map<String, dynamic>?;
                  return MaterialPageRoute(
                    builder: (context) =>
                        ProductManagementPage(arguments: args),
                  );
                case AdminCreateProductPage.routeName:
                  return MaterialPageRoute(
                    builder: (context) => const AdminCreateProductPage(),
                  );
                case AdminEditProductPage.routeName:
                  return MaterialPageRoute(
                    builder: (context) => const AdminEditProductPage(),
                  );

                // 📋 ÓRDENES (CLIENTE) - AHORA SIN BlocProvider.value porque el contexto ya lo tiene
                case MyOrdersPage.routeName:
                  return MaterialPageRoute(
                    builder: (context) => const MyOrdersPage(),
                  );
                case OrderDetailPage.routeName:
                  return MaterialPageRoute(
                    builder: (context) => const OrderDetailPage(),
                  );

                // 💳 PAGOS
                case '/checkout/success':
                  return MaterialPageRoute(
                    builder: (context) => const PaymentSuccessPage(),
                  );
                case '/checkout/pending':
                  return MaterialPageRoute(
                    builder: (context) => const PaymentPendingPage(),
                  );
                case '/checkout/failure':
                  return MaterialPageRoute(
                    builder: (context) => const PaymentFailurePage(),
                  );

                default:
                  return MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  );
              }
            },
          ),
        ),
      ),
    );
  }
}
