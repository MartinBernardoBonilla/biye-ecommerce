// lib/features/admin/presentation/pages/admin_users_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:biye/features/admin/presentation/bloc/admin_bloc.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  static const String routeName = '/admin/users';

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final ScrollController _scrollController = ScrollController();
  int _page = 1;

  @override
  void initState() {
    super.initState();
    debugPrint('📱 [USERS PAGE] Inicializando página de usuarios');
    _loadUsers();
    _scrollController.addListener(_onScroll);
  }

  void _loadUsers() {
    debugPrint('📱 [USERS PAGE] Cargando usuarios - Página: $_page');
    context.read<AdminBloc>().add(LoadUsers(page: _page));
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<AdminBloc>().state;
      if (state is AdminLoaded && state.hasMoreUsers) {
        debugPrint(
            '📱 [USERS PAGE] Cargando más usuarios - Siguiente página: ${_page + 1}');
        _page++;
        _loadUsers();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          debugPrint('📱 [USERS PAGE] Estado actual: ${state.runtimeType}');

          if (state is AdminLoading && _page == 1) {
            debugPrint('📱 [USERS PAGE] Mostrando indicador de carga inicial');
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AdminError) {
            debugPrint('📱 [USERS PAGE] Error: ${state.message}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  ElevatedButton(
                    onPressed: () {
                      _page = 1;
                      _loadUsers();
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is AdminLoaded) {
            final users = state.users;
            debugPrint('📱 [USERS PAGE] Usuarios cargados: ${users.length}');
            debugPrint('📱 [USERS PAGE] Tipo de users: ${users.runtimeType}');

            if (users.isEmpty) {
              debugPrint('📱 [USERS PAGE] No hay usuarios para mostrar');
              return const Center(child: Text('No hay usuarios'));
            }

            // 👇 VERIFICAR LA ESTRUCTURA DEL PRIMER USUARIO
            if (users.isNotEmpty) {
              debugPrint('📱 [USERS PAGE] Primer usuario: ${users.first}');
              debugPrint(
                  '📱 [USERS PAGE] Keys del primer usuario: ${users.first is Map ? (users.first as Map).keys : 'No es Map'}');
            }

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: users.length + (state.hasMoreUsers ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == users.length) {
                  debugPrint(
                      '📱 [USERS PAGE] Mostrando indicador de carga para más usuarios');
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final user = users[index];

                // 👇 EXTRACCIÓN SEGURA DE CAMPOS
                String name = 'Sin nombre';
                String email = 'Sin email';
                String role = 'user';

                if (user is Map) {
                  name = user['name']?.toString() ??
                      user['firstName']?.toString() ??
                      user['username']?.toString() ??
                      'Sin nombre';
                  email = user['email']?.toString() ?? 'Sin email';
                  role = user['role']?.toString()?.toLowerCase() ?? 'user';
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          role == 'admin' ? Colors.purple : Colors.blue,
                      child: Text(
                        email.isNotEmpty ? email[0].toUpperCase() : 'U',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(name),
                    subtitle: Text(email),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: role == 'admin'
                            ? Colors.purple[100]
                            : Colors.blue[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        role.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: role == 'admin'
                              ? Colors.purple[900]
                              : Colors.blue[900],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }

          debugPrint(
              '📱 [USERS PAGE] Estado no manejado: ${state.runtimeType}');
          return const SizedBox();
        },
      ),
    );
  }

  @override
  void dispose() {
    debugPrint('📱 [USERS PAGE] Limpiando recursos');
    _scrollController.dispose();
    super.dispose();
  }
}
