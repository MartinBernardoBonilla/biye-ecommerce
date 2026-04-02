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
    debugPrint('🔥🔥🔥 ADMIN_USERS_PAGE INITSTATE EJECUTADO');
    _loadUsers();
    _scrollController.addListener(_onScroll);
  }

  void _loadUsers() {
    debugPrint('📢📢📢 _loadUsers() EJECUTADO - Página: $_page');
    debugPrint('📢📢📢 AdminBloc existe: ${context.read<AdminBloc>() != null}');
    context.read<AdminBloc>().add(LoadUsers(page: _page));
    debugPrint('📢📢📢 Evento LoadUsers DISPARADO');
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<AdminBloc>().state;
      if (state is AdminLoaded && state.hasMoreUsers) {
        _page++;
        _loadUsers();
      }
    }
  }

  // 👇 NUEVO MÉTODO PARA MOSTRAR ACCIONES DEL USUARIO
  void _showUserActions(BuildContext context, Map<String, dynamic> user) {
    String name = user['username']?.toString() ??
        user['name']?.toString() ??
        'Sin nombre';
    String email = user['email']?.toString() ?? 'Sin email';
    String role = user['role']?.toString().toLowerCase() ?? 'user';
    String userId = user['_id']?.toString() ?? '';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header con información del usuario
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        role == 'admin' ? Colors.purple : Colors.blue,
                    child: Text(
                      email.isNotEmpty ? email[0].toUpperCase() : 'U',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          email,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 32),

            // Opción: Editar usuario
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit, color: Colors.blue),
              ),
              title: const Text(
                'Editar usuario',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: const Text('Modificar información del usuario'),
              onTap: () {
                Navigator.pop(context);
                _showEditUserDialog(context, user);
              },
            ),

            // Opción: Cambiar rol
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  role == 'admin' ? Icons.person : Icons.admin_panel_settings,
                  color: Colors.purple,
                ),
              ),
              title: Text(
                role == 'admin'
                    ? 'Cambiar a usuario normal'
                    : 'Hacer administrador',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                role == 'admin'
                    ? 'Quitar privilegios de administrador'
                    : 'Otorgar privilegios de administrador',
              ),
              onTap: () {
                Navigator.pop(context);
                _showChangeRoleDialog(context, user, role);
              },
            ),

            // Opción: Activar/Desactivar
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.block, color: Colors.orange),
              ),
              title: const Text(
                'Desactivar usuario',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle:
                  const Text('El usuario no podrá acceder a la plataforma'),
              onTap: () {
                Navigator.pop(context);
                _showConfirmDisableDialog(context, user);
              },
            ),

            const Divider(height: 32),

            // Opción cancelar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 👇 DIÁLOGO PARA EDITAR USUARIO
  void _showEditUserDialog(BuildContext context, Map<String, dynamic> user) {
    String name =
        user['username']?.toString() ?? user['name']?.toString() ?? '';
    String email = user['email']?.toString() ?? '';

    final nameController = TextEditingController(text: name);
    final emailController = TextEditingController(text: email);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar usuario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // Aquí iría la lógica para guardar
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Usuario actualizado (simulado)'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // 👇 DIÁLOGO PARA CAMBIAR ROL
  void _showChangeRoleDialog(
      BuildContext context, Map<String, dynamic> user, String currentRole) {
    String name =
        user['username']?.toString() ?? user['name']?.toString() ?? 'Usuario';
    String newRole = currentRole == 'admin' ? 'user' : 'admin';
    String roleName = newRole == 'admin' ? 'Administrador' : 'Usuario normal';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cambiar rol de $name'),
        content: Text('¿Estás seguro de cambiar el rol a $roleName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // Aquí iría la lógica para cambiar rol
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Rol cambiado a ${newRole.toUpperCase()} (simulado)'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  // 👇 DIÁLOGO PARA DESACTIVAR USUARIO
  void _showConfirmDisableDialog(
      BuildContext context, Map<String, dynamic> user) {
    String name =
        user['username']?.toString() ?? user['name']?.toString() ?? 'Usuario';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desactivar usuario'),
        content: Text(
            '¿Estás seguro de desactivar a $name? El usuario no podrá acceder a la plataforma.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // Aquí iría la lógica para desactivar
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Usuario desactivado (simulado)'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Desactivar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        backgroundColor: Colors.blueGrey[800],
        actions: [
          // Botón de búsqueda
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implementar búsqueda después
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Búsqueda - Próximamente')),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          debugPrint('📱 [USERS PAGE] Estado: ${state.runtimeType}');

          if (state is AdminLoading && _page == 1) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AdminError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
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
            debugPrint('📱 Usuarios cargados: ${users.length}');

            if (users.isEmpty) {
              return const Center(child: Text('No hay usuarios'));
            }

            return RefreshIndicator(
              onRefresh: () async {
                _page = 1;
                _loadUsers();
              },
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: users.length + (state.hasMoreUsers ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == users.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final user = users[index];
                  String name = user['username']?.toString() ??
                      user['name']?.toString() ??
                      'Sin nombre';
                  String email = user['email']?.toString() ?? 'Sin email';
                  String role =
                      user['role']?.toString().toLowerCase() ?? 'user';
                  bool isActive = user['isActive'] != false; // Por defecto true

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
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (!isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'INACTIVO',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.red[900],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Text(email),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
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
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.more_vert),
                            onPressed: () => _showUserActions(context, user),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
