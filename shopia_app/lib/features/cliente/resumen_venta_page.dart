import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import '../../services/apiService.dart';
import 'compra_exitosa_page.dart';

class ResumenVentaPage extends StatefulWidget {
  final int ventaId;

  const ResumenVentaPage({Key? key, required this.ventaId}) : super(key: key);

  @override
  State<ResumenVentaPage> createState() => _ResumenVentaPageState();
}

class _ResumenVentaPageState extends State<ResumenVentaPage> {
  final ApiService api = ApiService();
  Map<String, dynamic>? venta;
  bool loading = false;
  bool loadingPago = false;

  @override
  void initState() {
    super.initState();
    cargarVenta();
  }

  Future<void> cargarVenta() async {
    setState(() => loading = true);
    try {
      final data = await api.get('ventas/ventas/${widget.ventaId}/');
      setState(() => venta = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> handlePagar() async {
    setState(() => loadingPago = true);
    try {
      // 1. Crear Payment Intent en el backend
      final response = await api.post(
        'ventas/ventas/${widget.ventaId}/crear-payment-intent-mobile/',
        {},
      );

      final clientSecret = response['client_secret'];
      final paymentIntentId = response['payment_intent_id'];

      if (clientSecret == null) {
        throw Exception('No se recibió el client_secret');
      }

      // 2. Inicializar el Payment Sheet de Stripe
      await stripe.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: stripe.SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Shopia',
          style: ThemeMode.system,
          appearance: const stripe.PaymentSheetAppearance(
            colors: stripe.PaymentSheetAppearanceColors(
              primary: Color(0xFF673AB7), // deepPurple
            ),
          ),
        ),
      );

      // 3. Presentar el formulario de pago
      await stripe.Stripe.instance.presentPaymentSheet();

      // 4. Si llegamos aquí, el pago fue exitoso
      if (mounted) {
        // Confirmar el pago en el backend
        await api.post(
          'ventas/ventas/${widget.ventaId}/confirmar-pago-mobile/',
          {'payment_intent_id': paymentIntentId},
        );

        // Navegar a la página de éxito
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CompraExitosaPage(
              ventaId: widget.ventaId,
              sessionId: paymentIntentId,
            ),
          ),
        );
      }
    } on stripe.StripeException catch (e) {
      // Error de Stripe (usuario canceló, tarjeta rechazada, etc.)
      if (mounted) {
        String mensaje = 'Error al procesar el pago';
        if (e.error.code == 'canceled') {
          mensaje = 'Pago cancelado';
        } else if (e.error.localizedMessage != null) {
          mensaje = e.error.localizedMessage!;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensaje), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      // Otros errores
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => loadingPago = false);
      }
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'PENDIENTE':
        return Colors.orange;
      case 'PAGADA':
        return Colors.green;
      case 'ENVIADA':
        return Colors.blue;
      case 'CANCELADA':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getEstadoTexto(String estado) {
    switch (estado) {
      case 'PENDIENTE':
        return 'Pendiente de Pago';
      case 'PAGADA':
        return 'Pagada';
      case 'ENVIADA':
        return 'Enviada';
      case 'CANCELADA':
        return 'Cancelada';
      default:
        return estado;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (venta == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Resumen de Compra')),
        body: const Center(child: Text('Venta no encontrada')),
      );
    }

    final detalles = venta!['detalles'] as List? ?? [];
    final estado = venta!['estado'];
    final montoTotal = double.tryParse(venta!['monto_total'].toString()) ?? 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Resumen de Compra'), elevation: 4),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información de orden
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Orden #${venta!['id']}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getEstadoColor(estado).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _getEstadoColor(estado)),
                          ),
                          child: Text(
                            _getEstadoTexto(estado),
                            style: TextStyle(
                              color: _getEstadoColor(estado),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat(
                            'dd/MM/yyyy HH:mm',
                          ).format(DateTime.parse(venta!['fecha'])),
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${venta!['direccion']}${venta!['numero_int'] != null ? ' #${venta!['numero_int']}' : ''}',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Productos
            const Text(
              'Productos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...detalles.map((detalle) {
              final producto = detalle['producto'];
              final precioUnitario =
                  double.tryParse(detalle['precio_unitario'].toString()) ?? 0.0;
              final cantidad = detalle['cantidad'] ?? 0;
              final subtotal = precioUnitario * cantidad;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              producto['nombre'] ?? 'Producto',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Cantidad: $cantidad',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Bs${subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 20),

            // Total
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Bs${montoTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Botón de pago
            if (estado == 'PENDIENTE')
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: loadingPago ? null : handlePagar,
                  icon: loadingPago
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.payment),
                  label: Text(
                    loadingPago ? 'Procesando...' : 'Pagar con Tarjeta',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

            // Mensaje de éxito
            if (estado == 'PAGADA')
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 32),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '¡Pago completado exitosamente!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
