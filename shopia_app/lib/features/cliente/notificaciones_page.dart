import 'package:flutter/material.dart';
import '../../services/apiService.dart';
import '../../models/notificacion.dart';
import 'package:intl/intl.dart';

class NotificacionesPage extends StatefulWidget {
  const NotificacionesPage({Key? key}) : super(key: key);

  @override
  State<NotificacionesPage> createState() => _NotificacionesPageState();
}

class _NotificacionesPageState extends State<NotificacionesPage> {
  final ApiService api = ApiService();
  List<Notificacion> notificaciones = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    cargarNotificaciones();
  }

  Future<void> cargarNotificaciones() async {
    try {
      final data = await api.get('cuenta/mis-notificaciones/');
      setState(() {
        notificaciones = (data as List)
            .map((n) => Notificacion.fromJson(n))
            .toList();
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> marcarLeida(Notificacion notif) async {
    if (notif.leida) return;

    try {
      await api.post('cuenta/mis-notificaciones/${notif.id}/marcar_leida/', {
        'plataforma': 'app',
      });
      cargarNotificaciones();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notificaciones')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (notificaciones.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notificaciones')),
        body: const Center(child: Text('No tienes notificaciones')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () async {
              await api.post(
                'cuenta/mis-notificaciones/marcar_todas_leidas/',
                {},
              );
              cargarNotificaciones();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: cargarNotificaciones,
        child: ListView.builder(
          itemCount: notificaciones.length,
          itemBuilder: (ctx, i) {
            final notif = notificaciones[i];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: notif.leida ? null : Colors.blue.shade50,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getColorTipo(notif.tipo),
                  child: Icon(_getIconTipo(notif.tipo), color: Colors.white),
                ),
                title: Text(
                  notif.titulo,
                  style: TextStyle(
                    fontWeight: notif.leida
                        ? FontWeight.normal
                        : FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notif.descripcion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat(
                        'dd/MM/yyyy HH:mm',
                      ).format(notif.fechaCreacion),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                trailing: notif.leida
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () => marcarLeida(notif),
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getColorTipo(String tipo) {
    switch (tipo) {
      case 'success':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'error':
        return Colors.red;
      case 'promocion':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  IconData _getIconTipo(String tipo) {
    switch (tipo) {
      case 'success':
        return Icons.check_circle;
      case 'warning':
        return Icons.warning;
      case 'error':
        return Icons.error;
      case 'promocion':
        return Icons.local_offer;
      default:
        return Icons.info;
    }
  }
}
