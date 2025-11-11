import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_controller.dart';
import '../login_page.dart';
import './producto.page.dart';
import './reportes_page.dart';
import './graficas_page.dart';

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
              icon: Icons.inventory,
              title: 'Productos',
              subtitle: 'Gestionar productos',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProductoPage()),
                );
              },
            ),
            _buildAdminCard(
              icon: Icons.analytics_outlined,
              title: 'Estadisticas',
              subtitle: 'Ver estadísticas',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GraficasPage()),
                );
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReportesPage()),
                );
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
              Icon(icon, size: 40, color: Colors.deepPurple),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ), // más pequeño
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
