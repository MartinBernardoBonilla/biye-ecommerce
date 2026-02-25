import 'package:biye/features/admin/presentation/pages/admin_orders_page.dart';
import 'package:biye/features/admin/presentation/pages/admin_users_page.dart';
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
import 'package:biye/features/admin/presentation/pages/product_management_page.dart';
import 'package:biye/features/admin/presentation/pages/admin_create_product_page.dart';
import 'package:biye/features/admin/presentation/pages/admin_edit_product_page.dart';
import 'package:biye/features/admin/presentation/pages/admin_dashboard_page.dart';

// AUTH
import 'package:biye/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:biye/features/auth/presentation/login_screen.dart';
import 'package:biye/features/auth/presentation/registration_screen.dart';

// CART / ORDER / PAYMENT
import 'package:biye/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:biye/features/order/data/services/order_service.dart';
import 'package:biye/features/payment/data/services/mercadopago_service.dart';

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
            create: (context) => AuthBloc(
              apiClient: context.read<ApiClient>(),
            ),
          ),
          BlocProvider<CartBloc>(
            create: (context) => CartBloc(
              authBloc: context.read<AuthBloc>(),
              mercadoPagoService: MercadoPagoService(
                baseUrl: baseUrl,
                token: '',
              ),
              orderService: OrderService(
                baseUrl: baseUrl,
                token: '',
              ),
            ),
          ),
          // ✅ NUEVO: AdminBloc AGREGADO AQUÍ
          BlocProvider<AdminBloc>(
            create: (context) => AdminBloc(
              repository: AdminRepositoryImpl(
                baseUrl: baseUrl,
                client: http.Client(),
              ),
            ),
          ),
        ],
        child: MaterialApp(
          navigatorKey: navigatorKey,
          title: 'Biye',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(primarySwatch: Colors.blue),
          initialRoute: '/',
          routes: {
            '/': (_) => const HomeScreen(),
            '/login': (_) => const LoginScreen(),
            '/register': (_) => const RegistrationScreen(),

            // ADMIN
            AdminLoginPage.routeName: (_) => const AdminLoginPage(),
            AdminPanelPage.routeName: (_) => const AdminPanelPage(),
            ProductManagementPage.routeName: (_) =>
                const ProductManagementPage(),
            AdminCreateProductPage.routeName: (_) =>
                const AdminCreateProductPage(),
            AdminEditProductPage.routeName: (_) => const AdminEditProductPage(),
            AdminDashboardPage.routeName: (_) => const AdminDashboardPage(),
            AdminOrdersPage.routeName: (_) => const AdminOrdersPage(),
            AdminUsersPage.routeName: (_) => const AdminUsersPage(),
            ProductManagementPage.routeName: (context) => ProductManagementPage(
                  arguments: ModalRoute.of(context)?.settings.arguments
                      as Map<String, dynamic>?,
                ),
            // PAYMENT RESULT
            '/checkout/success': (_) => const PaymentSuccessPage(),
            '/checkout/pending': (_) => const PaymentPendingPage(),
            '/checkout/failure': (_) => const PaymentFailurePage(),
          },
        ),
      ),
    );
  }
}
