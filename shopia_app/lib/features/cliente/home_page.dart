import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_controller.dart';
import '../../services/apiService.dart';
import './tienda_page.dart';
import './carrito_page.dart';
import './historia_page.dart';
import './notificaciones_page.dart';

class ClientHomePage extends StatefulWidget {
  const ClientHomePage({super.key});

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const CategoriasPage();
      case 1:
        return const CarritoPage();
      case 2:
        return const HistoriaPage(); // <-- CAMBIADO
      case 3:
        return const NotificacionesPage(); // <-- CAMBIADO
      default:
        return const CategoriasPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<AuthController>(
          builder: (context, auth, _) {
            return Text('¡Hola, ${auth.user?.nombre ?? ''}!');
          },
        ),
        actions: [
          // Icono carrito
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            tooltip: 'Carrito',
            onPressed: () {
              setState(() {
                _selectedIndex = 1; // Cambia a la pestaña de carrito
              });
            },
          ),
          // Icono notificaciones
          IconButton(
            icon: const Icon(Icons.notifications),
            tooltip: 'Notificaciones',
            onPressed: () {
              setState(() {
                _selectedIndex = 3; // Cambia a la pestaña de notificaciones
              });
              // Puedes mostrar un mensaje temporal si quieres
              // ScaffoldMessenger.of(context).showSnackBar(
              //   const SnackBar(content: Text('Próximamente notificaciones'))
              // );
            },
          ),
          // Menú perfil y cerrar sesión
          Consumer<AuthController>(
            builder: (context, auth, _) {
              return PopupMenuButton<String>(
                icon: CircleAvatar(
                  child: Text(auth.user?.nombre[0].toUpperCase() ?? 'U'),
                ),
                onSelected: (value) async {
                  if (value == 'logout') {
                    await auth.logout();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/');
                    }
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'profile',
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(auth.user?.nombre ?? ''),
                      subtitle: Text(auth.user?.correo ?? ''),
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: const ListTile(
                      leading: Icon(Icons.logout, color: Colors.red),
                      title: Text(
                        'Cerrar sesión',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
        elevation: 4, // Sombra
        backgroundColor: Colors.white,
        foregroundColor: const Color.fromARGB(255, 94, 92, 98),
        shape: const Border(
          bottom: BorderSide(
            color: Color.fromARGB(255, 196, 195, 197),
            width: 1.2,
          ),
        ),
      ),
      body: _getPage(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Tienda'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Carrito',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historial',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notificaciones',
          ),
        ],
      ),
    );
  }
}

// Nueva página para categorías (antes era el contenido de ClientHomePage)
class CategoriasPage extends StatefulWidget {
  const CategoriasPage({Key? key}) : super(key: key);

  @override
  State<CategoriasPage> createState() => _CategoriasPageState();
}

class _CategoriasPageState extends State<CategoriasPage> {
  List<dynamic> categorias = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    cargarCategorias();
  }

  Future<void> cargarCategorias() async {
    try {
      final api = ApiService();
      final data = await api.get('categorias/');

      // ✅ Verificar si el widget sigue montado antes de setState
      if (mounted) {
        setState(() {
          categorias = data;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error al cargar categorías: $e');

      // ✅ Verificar si el widget sigue montado
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Consumer<AuthController>(
            builder: (context, auth, _) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.deepPurple.shade300],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Hola, ${auth.user?.nombre}!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Bienvenido a tu tienda online',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              );
            },
          ),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: categorias.length,
                    itemBuilder: (context, i) {
                      final cat = categorias[i];
                      return _buildCategoryCard(
                        cat['nombre'],
                        cat['id'],
                        _getCategoryIconByName(cat['nombre']),
                        _getCategoryColor(i),
                      );
                    },
                  ),
                ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    String title,
    int categoriaId,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  TiendaPage(categoriaId: categoriaId, categoriaNombre: title),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIconByName(String nombre) {
    final lower = nombre.toLowerCase();
    if (lower.contains('teclado')) return Icons.keyboard;
    if (lower.contains('monitor')) return Icons.desktop_windows;
    if (lower.contains('heladera')) return Icons.kitchen;
    if (lower.contains('licuadora')) return Icons.blender;
    if (lower.contains('televisor')) return Icons.tv;
    if (lower.contains('aire')) return Icons.ac_unit;
    if (lower.contains('cocina') || lower.contains('vitro'))
      return Icons.restaurant;
    if (lower.contains('celular')) return Icons.phone_android;
    if (lower.contains('lavadora')) return Icons.local_laundry_service;
    if (lower.contains('microonda')) return Icons.microwave;
    return Icons.category;
  }

  Color _getCategoryColor(int index) {
    final colors = [
      Colors.blue,
      Colors.pink,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.red,
      Colors.indigo,
    ];
    return colors[index % colors.length];
  }
}
