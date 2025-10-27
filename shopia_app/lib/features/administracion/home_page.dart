import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_controller.dart';
import '../login_page.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Administrativo'),
        actions: [
          Consumer<AuthController>(
            builder: (context, auth, _) {
              return PopupMenuButton<String>(
                icon: CircleAvatar(
                  child: Text(auth.user?.nombre[0].toUpperCase() ?? 'A'),
                ),
                itemBuilder: (context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'profile',
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(auth.user?.nombreCompleto ?? ''),
                      subtitle: Text(auth.user?.correo ?? ''),
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: const ListTile(
                      leading: Icon(Icons.logout, color: Colors.red),
                      title: Text(
                        'Cerrar Sesión',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ],
                onSelected: (String value) async {
                  if (value == 'logout') {
                    await auth.logout();
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    }
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildAdminCard(
              icon: Icons.people,
              title: 'Usuarios',
              subtitle: 'Gestionar usuarios',
              onTap: () {
                // Navegar a usuarios
              },
            ),
            _buildAdminCard(
              icon: Icons.group,
              title: 'Clientes',
              subtitle: 'Gestionar clientes',
              onTap: () {
                // Navegar a clientes
              },
            ),
            _buildAdminCard(
              icon: Icons.inventory,
              title: 'Productos',
              subtitle: 'Gestionar productos',
              onTap: () {
                // Navegar a productos
              },
            ),
            _buildAdminCard(
              icon: Icons.notifications,
              title: 'Notificaciones',
              subtitle: 'Enviar notificaciones',
              onTap: () {
                // Navegar a notificaciones
              },
            ),
            _buildAdminCard(
              icon: Icons.history,
              title: 'Bitácora',
              subtitle: 'Ver actividad',
              onTap: () {
                // Navegar a bitácora
              },
            ),
            _buildAdminCard(
              icon: Icons.analytics,
              title: 'Reportes',
              subtitle: 'Ver estadísticas',
              onTap: () {
                // Navegar a reportes
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.deepPurple),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
