import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'shared/utils/network_test.dart';

// PROVIDER
import 'package:provider/provider.dart';

import '../../../../core/network/api_client.dart';

// CORE
import 'core/navigation/navigator_key.dart';
import 'core/utils/payment_deep_link_handler.dart';

// ADMIN
import 'package:biye/features/admin/data/services/admin_service.dart';
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
                baseUrl: kDebugMode
                    ? 'https://shanae-shearless-rakishly.ngrok-free.dev'
                    : 'https://api.biye.com',
                token: '',
              ),
              orderService: OrderService(
                baseUrl: kDebugMode
                    ? 'https://shanae-shearless-rakishly.ngrok-free.dev'
                    : 'https://api.biye.com',
                token: '',
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
