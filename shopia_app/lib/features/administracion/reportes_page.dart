import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../models/reporte.dart';
import '../../services/apiService.dart';

class ReportesPage extends StatefulWidget {
  const ReportesPage({super.key});

  @override
  State<ReportesPage> createState() => _ReportesPageState();
}

class _ReportesPageState extends State<ReportesPage> {
  bool _isLoading = false;

  final List<Reporte> _reportes = [
    Reporte(
      id: 'ventas',
      titulo: 'Reporte de Ventas',
      descripcion: 'Listado completo de ventas realizadas',
      endpoint: 'reportes/ventas/pdf',
      fileName: 'reporte_ventas.pdf',
      requiereFechas: true,
    ),
    Reporte(
      id: 'clientes',
      titulo: 'Reporte de Clientes',
      descripcion: 'Listado de todos los clientes registrados',
      endpoint: 'reportes/clientes/pdf',
      fileName: 'reporte_clientes.pdf',
      requiereFechas: true,
    ),
    Reporte(
      id: 'mas_vendidos',
      titulo: 'Productos Más Vendidos',
      descripcion: 'Top 10 productos con mayor venta',
      endpoint: 'reportes/mas_vendidos/pdf',
      fileName: 'reporte_mas_vendidos.pdf',
      requiereFechas: true,
    ),
  ];

  Future<void> _descargarReporte(Reporte reporte) async {
    if (reporte.requiereFechas) {
      _mostrarDialogoFiltros(reporte);
    } else {
      _ejecutarDescarga(reporte, {});
    }
  }

  Future<void> _ejecutarDescarga(
    Reporte reporte,
    Map<String, String> params,
  ) async {
    setState(() => _isLoading = true);

    try {
      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          await Permission.storage.request();
        }
      }

      String url = '${ApiService.baseUrl}/${reporte.endpoint}';

      if (params.isNotEmpty) {
        final queryString = params.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('&');
        url += '?$queryString';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          if (ApiService.token != null)
            'Authorization': 'Bearer ${ApiService.token}',
        },
      );

      if (response.statusCode == 200) {
        Directory? directory;
        if (Platform.isAndroid) {
          directory = Directory('/storage/emulated/0/Download');
        } else {
          directory = await getApplicationDocumentsDirectory();
        }

        final filePath = '${directory.path}/${reporte.fileName}';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✓ Reporte descargado en:\n$filePath'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 4),
            ),
          );
        }
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al descargar: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarDialogoFiltros(Reporte reporte) {
    DateTime? fechaInicio;
    DateTime? fechaFin;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Filtros - ${reporte.titulo}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text('Fecha Inicio'),
                  subtitle: Text(
                    fechaInicio != null
                        ? DateFormat('dd/MM/yyyy', 'es').format(fechaInicio!)
                        : 'No seleccionada',
                  ),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      locale: const Locale('es', 'ES'),
                    );
                    if (picked != null) {
                      setDialogState(() => fechaInicio = picked);
                    }
                  },
                ),
                Divider(),
                ListTile(
                  title: Text('Fecha Fin'),
                  subtitle: Text(
                    fechaFin != null
                        ? DateFormat('dd/MM/yyyy', 'es').format(fechaFin!)
                        : 'No seleccionada',
                  ),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      locale: const Locale('es', 'ES'),
                    );
                    if (picked != null) {
                      setDialogState(() => fechaFin = picked);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            IconButton(
              onPressed: () {
                Navigator.pop(context);

                final params = <String, String>{};
                if (fechaInicio != null) {
                  params['fecha_inicio'] = DateFormat(
                    'yyyy-MM-dd',
                  ).format(fechaInicio!);
                }
                if (fechaFin != null) {
                  params['fecha_fin'] = DateFormat(
                    'yyyy-MM-dd',
                  ).format(fechaFin!);
                }

                _ejecutarDescarga(reporte, params);
              },
              icon: Icon(Icons.download, color: Colors.deepPurple, size: 28),
              tooltip: 'Descargar',
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reportes'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Descargando reporte...'),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _reportes.length,
              itemBuilder: (context, index) {
                final reporte = _reportes[index];
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    leading: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.picture_as_pdf,
                        color: Colors.deepPurple,
                        size: 32,
                      ),
                    ),
                    title: Text(
                      reporte.titulo,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(reporte.descripcion),
                    ),
                    trailing: IconButton(
                      onPressed: () => _descargarReporte(reporte),
                      icon: Icon(Icons.download, color: Colors.deepPurple),
                      iconSize: 28,
                      tooltip: 'Descargar',
                    ),
                  ),
                );
              },
            ),
    );
  }
}
