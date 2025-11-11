import 'package:flutter/material.dart';
import '../../services/apiService.dart';
import '../../models/estadistica.dart';

class GraficasPage extends StatefulWidget {
  const GraficasPage({super.key});

  @override
  State<GraficasPage> createState() => _GraficasPageState();
}

class _GraficasPageState extends State<GraficasPage> {
  final ApiService _api = ApiService();
  bool _isLoading = true;
  String? _error;

  List<EstadisticaVentas> _ventasHistoricas = [];
  List<CrecimientoCategoria> _crecimientos = [];
  double _montoPromedio = 0;
  double _crecimientoPromedio = 0;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final ventasData = await _api.get(
        'predicciones/ventas/historico-predicciones/',
      );
      final crecimientosData = await _api.get('predicciones/crecimiento/');

      if (mounted) {
        setState(() {
          final datos = ventasData['datos'] as List;
          _ventasHistoricas = datos
              .map((d) => EstadisticaVentas.fromJson(d))
              .toList();

          final stats = ventasData['estadisticas'];
          _montoPromedio = (stats['monto_promedio'] ?? 0).toDouble();
          _crecimientoPromedio = (stats['crecimiento_promedio'] ?? 0)
              .toDouble();

          final crecList = crecimientosData['crecimientos'] as List;
          _crecimientos = crecList
              .take(5)
              .map((c) => CrecimientoCategoria.fromJson(c))
              .toList();

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _cargarDatos),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(_error!, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _cargarDatos,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _cargarDatos,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildResumenCards(),
                  const SizedBox(height: 24),
                  _buildVentasSimples(),
                  const SizedBox(height: 24),
                  _buildCrecimientoCategorias(),
                ],
              ),
            ),
    );
  }

  Widget _buildResumenCards() {
    return Row(
      children: [
        Expanded(
          child: Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.attach_money, color: Colors.blue, size: 32),
                  const SizedBox(height: 8),
                  const Text(
                    'Promedio Mensual',
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    'Bs ${_montoPromedio.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            color: _crecimientoPromedio >= 0
                ? Colors.green[50]
                : Colors.red[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    _crecimientoPromedio >= 0
                        ? Icons.trending_up
                        : Icons.trending_down,
                    color: _crecimientoPromedio >= 0
                        ? Colors.green
                        : Colors.red,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  const Text('Crecimiento', style: TextStyle(fontSize: 12)),
                  Text(
                    '${_crecimientoPromedio >= 0 ? '+' : ''}${_crecimientoPromedio.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _crecimientoPromedio >= 0
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVentasSimples() {
    if (_ventasHistoricas.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('No hay datos')),
        ),
      );
    }

    final ultimos6 = _ventasHistoricas.reversed
        .take(6)
        .toList()
        .reversed
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ventas Mensuales',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...ultimos6.map(
              (v) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      v.periodo,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Bs ${v.monto.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.deepPurple),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCrecimientoCategorias() {
    if (_crecimientos.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('No hay datos')),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top 5 Categorías',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._crecimientos.map((c) {
              final color = c.porcentaje >= 0 ? Colors.green : Colors.red;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      c.porcentaje >= 0
                          ? Icons.trending_up
                          : Icons.trending_down,
                      color: color,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        c.nombre,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Text(
                      '${c.porcentaje >= 0 ? '+' : ''}${c.porcentaje.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
