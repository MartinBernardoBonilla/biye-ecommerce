import 'package:biye/core/services/navigation_service.dart';
import 'package:biye/core/utils/auth_storage.dart';
import 'package:biye/core/widgets/persistent_bottom_nav.dart';
import 'package:biye/features/address/presentation/pages/addres_list_page.dart';
import 'package:biye/features/admin/presentation/pages/admin_order_detail_page.dart';
import 'package:biye/features/admin/presentation/pages/admin_orders_page.dart';
import 'package:biye/features/admin/presentation/pages/admin_users_page.dart';

import 'package:biye/features/order/presentation/pages/my_orders_page.dart';
import 'package:biye/features/order/presentation/pages/order_detail_page.dart';
import 'package:biye/features/product/presentation/pages/product_detail_page.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

//import 'shared/utils/network_test.dart';

// PROVIDER
import 'package:provider/provider.dart';

import 'core/network/api_client.dart';

// CORE
import 'core/navigation/navigator_key.dart';
import 'core/utils/payment_deep_link_handler.dart';
import 'core/widgets/app_initializer.dart';

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

// ORDER BLOC
import 'package:biye/features/order/presentation/bloc/order_bloc.dart';
import 'package:biye/features/order/data/repositories/order_repository_impl.dart';
import 'package:biye/features/order/data/datasources/order_remote_datasource.dart';

// FAVORITOS
import 'package:biye/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:biye/features/favorites/presentation/bloc/favorites_event.dart';
import 'package:biye/features/favorites/data/repositories/favorites_repository.dart';

// PAYMENT RESULT
import 'package:biye/features/payment/presentation/pages/payment_success_page.dart';
import 'package:biye/features/payment/presentation/pages/payment_pending_page.dart';
import 'package:biye/features/payment/presentation/pages/payment_failure_page.dart';

// CHECKOUT
import 'package:biye/features/checkout/presentation/pages/checkout_page.dart';
import 'package:biye/features/checkout/presentation/pages/payment_page.dart';
import 'package:biye/features/checkout/presentation/bloc/checkout_bloc.dart';

// ADDRESS
import 'package:biye/features/address/presentation/pages/address_form_page.dart';
import 'package:biye/features/address/presentation/bloc/address_bloc.dart';
import 'package:biye/features/address/data/repositories/address_repository.dart';

// PAYMENT METHODS
import 'package:biye/features/payment_methods/presentation/pages/payment_method_list_page.dart';
import 'package:biye/features/payment_methods/presentation/pages/payment_method_form_page.dart';
import 'package:biye/features/payment_methods/presentation/bloc/payment_method_bloc.dart';
import 'package:biye/features/payment_methods/data/repositories/payment_method_repository.dart';

// SETTINGS
import 'package:biye/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:biye/features/settings/data/repositories/settings_repository.dart';

// THEME
import 'core/providers/theme_provider.dart';
import 'core/theme/app_theme.dart';

// WEB
import 'package:biye/core/web/web_import.dart'
    if (dart.library.html) 'package:biye/core/web/web_import.dart'
    if (dart.library.io) 'package:biye/core/web/web_import_stub.dart';

import 'package:biye/features/cart/presentation/pages/cart_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kDebugMode) {
    //   NetworkTest.runTest();
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

    _loadInitialToken();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyFlutterReady();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      PaymentDeepLinkHandler.initialize(navigatorKey);
    });
  }

  Future<void> _loadInitialToken() async {
    final token = await AuthStorage.getToken();
    if (token != null && token.isNotEmpty) {
      debugPrint('🔑 Token inicial cargado correctamente');
    } else {
      debugPrint('⚠️ No hay token guardado');
    }
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
        Provider<ApiClient>(create: (_) => ApiClient()),
        Provider<AdminService>(
          create: (context) => AdminService(
            apiClient: context.read<ApiClient>(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NavigationService()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) {
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
                  baseUrl: baseUrl,
                  client: http.Client(),
                ),
                apiClient: context.read<ApiClient>(),
              ),
            ),
          ),
          BlocProvider<CartBloc>(
            create: (context) => CartBloc(),
          ),
          BlocProvider<PaymentMethodBloc>(
            create: (context) => PaymentMethodBloc(
              repository: PaymentMethodRepository(
                apiClient: context.read<ApiClient>(),
              ),
            ),
          ),
          BlocProvider<AddressBloc>(
            create: (context) => AddressBloc(
              repository: AddressRepository(
                apiClient: context.read<ApiClient>(),
              ),
            ),
          ),
          BlocProvider<AdminBloc>(
            create: (context) => AdminBloc(
              repository: AdminRepositoryImpl(
                baseUrl: baseUrl,
                client: http.Client(),
              ),
            ),
          ),
          BlocProvider<FavoritesBloc>(
            create: (context) => FavoritesBloc(
              repository: FavoritesRepository(
                apiClient: context.read<ApiClient>(),
              ),
            )..add(LoadFavorites()),
          ),
          BlocProvider<SettingsBloc>(
            create: (context) => SettingsBloc(
              repository: SettingsRepository(),
            ),
          ),
          BlocProvider<CheckoutBloc>(
            create: (context) => CheckoutBloc(
              cartBloc: context.read<CartBloc>(),
              addressBloc: context.read<AddressBloc>(),
              paymentMethodBloc: context.read<PaymentMethodBloc>(),
            ),
          ),
        ],
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return MaterialApp(
              navigatorKey: navigatorKey,
              title: 'Biye',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeProvider.themeMode,
              home: const AppInitializer(
                child: PersistentBottomNav(),
              ),
              onGenerateRoute: (settings) {
                print('🔴 [MAIN] Generando ruta: ${settings.name}');

                switch (settings.name) {
                  // AUTH
                  case '/login':
                    return MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    );
                  case '/register':
                    return MaterialPageRoute(
                      builder: (context) => const RegistrationScreen(),
                    );

                  // PRODUCTS
                  case '/product-detail':
                    final args = settings.arguments as String;
                    return MaterialPageRoute(
                      builder: (context) => ProductDetailPage(productId: args),
                    );

                  // CART & CHECKOUT
                  case '/cart':
                    return MaterialPageRoute(
                      builder: (context) => const CartPage(),
                    );
                  case '/checkout':
                    return MaterialPageRoute(
                      builder: (context) => const CheckoutPage(),
                    );
                  case '/payment':
                    final args = settings.arguments as Map<String, dynamic>;
                    return MaterialPageRoute(
                      builder: (context) => PaymentPage(
                        orderId: args['orderId'],
                        qrData: args['qrData'],
                        paymentLink: args['paymentLink'],
                      ),
                    );

                  // ADDRESSES
                  case '/addresses':
                    return MaterialPageRoute(
                      builder: (context) => const AddressListPage(),
                    );
                  case '/addresses/add':
                    return MaterialPageRoute(
                      builder: (context) => const AddressFormPage(),
                    );

                  // PAYMENT METHODS
                  case '/payment-methods':
                    return MaterialPageRoute(
                      builder: (context) => const PaymentMethodListPage(),
                    );
                  case '/payment-methods/add':
                    return MaterialPageRoute(
                      builder: (context) => const PaymentMethodFormPage(),
                    );

                  // ADMIN
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

                  // PRODUCT MANAGEMENT (ADMIN)
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

                  // ORDERS
                  case MyOrdersPage.routeName:
                    return MaterialPageRoute(
                      builder: (context) => const MyOrdersPage(),
                    );
                  case OrderDetailPage.routeName:
                    return MaterialPageRoute(
                      builder: (context) => const OrderDetailPage(),
                    );

                  // PAYMENT RESULTS
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
                      builder: (context) => const PersistentBottomNav(),
                    );
                }
              },
            );
          },
        ),
      ),
    );
  }
}
