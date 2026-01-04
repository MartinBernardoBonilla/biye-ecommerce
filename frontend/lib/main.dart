import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // 👈 ESTA ES LA QUE FALTA para kDebugMode
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

// Importaciones de tus servicios y páginas
import 'package:biye/features/admin/data/services/admin_service.dart';
import 'package:biye/features/admin/presentation/pages/admin_login_page.dart';
import 'package:biye/features/admin/presentation/pages/admin_panel_page.dart';
import 'package:biye/features/admin/presentation/pages/product_management_page.dart';
import 'package:biye/features/admin/presentation/pages/admin_create_product_page.dart';
import 'package:biye/features/admin/presentation/pages/admin_edit_product_page.dart';
import 'package:biye/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:biye/features/auth/presentation/login_screen.dart';
import 'package:biye/features/auth/presentation/registration_screen.dart';
import 'package:biye/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:biye/features/home/presentation/home_screen.dart';
import 'shared/utils/network_test.dart';

void main() {
  // Asegurar que Flutter esté inicializado antes de las pruebas
  WidgetsFlutterBinding.ensureInitialized();

  // Probar conexión al iniciar (solo en desarrollo)
  if (kDebugMode) {
    NetworkTest.runTest();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 👈 Aquí instanciamos la clase AdminService correctamente
        Provider(create: (_) => AdminService()),
        BlocProvider(create: (_) => CartBloc()),
      ],
      child: MaterialApp(
        title: 'Biye',
        debugShowCheckedModeBanner: false, // Quita el banner de debug
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegistrationScreen(),
          AdminLoginPage.routeName: (context) => const AdminLoginPage(),
          AdminPanelPage.routeName: (context) => const AdminPanelPage(),
          AdminDashboardPage.routeName: (context) => const AdminDashboardPage(),
          ProductManagementPage.routeName: (context) =>
              const ProductManagementPage(),
          AdminCreateProductPage.routeName: (context) =>
              const AdminCreateProductPage(),
          // Nota: AdminEditProductPage suele requerir argumentos,
          // asegúrate de pasarlos en el Navigator.
          AdminEditProductPage.routeName: (context) =>
              const AdminEditProductPage(),
        },
      ),
    );
  }
}
