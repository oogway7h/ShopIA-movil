import 'package:flutter/material.dart';
import '../../services/apiService.dart';
import 'resumen_venta_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({Key? key}) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final ApiService api = ApiService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _numeroIntController = TextEditingController();

  String tipoPagoId = '1'; // Stripe por defecto
  bool loading = false;

  @override
  void dispose() {
    _direccionController.dispose();
    _numeroIntController.dispose();
    super.dispose();
  }

  Future<void> _finalizarCompra() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final response = await api.post('ventas/carrito/finalizar-compra/', {
        'direccion': _direccionController.text.trim(),
        'numero_int': _numeroIntController.text.isNotEmpty
            ? int.parse(_numeroIntController.text)
            : null,
        'tipo_pago_id': int.parse(tipoPagoId),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Venta creada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );

        // Navegar al resumen de venta
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResumenVentaPage(ventaId: response['venta_id']),
          ),
        );
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Finalizar Compra'), elevation: 4),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Información de Envío',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Dirección
              TextFormField(
                controller: _direccionController,
                decoration: InputDecoration(
                  labelText: 'Dirección de Envío *',
                  hintText: 'Calle, Número, Colonia',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La dirección es requerida';
                  }
                  return null;
                },
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Número Interior/Apartamento
              TextFormField(
                controller: _numeroIntController,
                decoration: InputDecoration(
                  labelText: 'Número Interior/Apartamento (Opcional)',
                  hintText: 'Ej: 101',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.home),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),

              const Text(
                'Método de Pago',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Método de pago
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: const Icon(Icons.credit_card, color: Colors.blue),
                  title: const Text('Tarjeta de Crédito/Débito'),
                  subtitle: const Text('Pago seguro con Stripe'),
                  trailing: Radio<String>(
                    value: '1',
                    groupValue: tipoPagoId,
                    onChanged: (value) {
                      setState(() => tipoPagoId = value!);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Botón finalizar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: loading ? null : _finalizarCompra,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Crear Orden de Compra',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
