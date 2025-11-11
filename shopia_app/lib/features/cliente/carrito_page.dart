import 'package:flutter/material.dart';
import '../../services/apiService.dart';
import 'checkout_page.dart'; // <-- AGREGA ESTO

class CarritoPage extends StatefulWidget {
  const CarritoPage({Key? key}) : super(key: key);

  @override
  State<CarritoPage> createState() => _CarritoPageState();
}

class _CarritoPageState extends State<CarritoPage> {
  final ApiService api = ApiService();
  Map<String, dynamic>? carrito;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    cargarCarrito();
  }

  Future<void> cargarCarrito() async {
    setState(() => loading = true);
    try {
      final data = await api.get('ventas/carrito/');
      setState(() => carrito = data);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> actualizarCantidad(int productoId, int cantidad) async {
    try {
      await api.put('ventas/carrito/actualizar-cantidad/', {
        'producto_id': productoId,
        'cantidad': cantidad,
      });
      cargarCarrito();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> eliminarProducto(int productoId) async {
    try {
      await api.delete('ventas/carrito/eliminar-producto/$productoId/');
      cargarCarrito();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Producto eliminado')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = carrito?['items'] as List? ?? [];
    final total = items.fold<double>(
      0,
      (sum, item) =>
          sum +
          (double.tryParse(item['precio_unitario'].toString()) ?? 0.0) *
              (item['cantidad'] ?? 0),
    );

    return Scaffold(
      resizeToAvoidBottomInset: false, // <-- CORREGIDO
      appBar: AppBar(title: Text('Mi Carrito (${items.length})')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 48,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Tu carrito está vacío',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final item = items[i];
                      final producto = item['producto'];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: (() {
                                  // Intenta url_imagen_principal
                                  final url =
                                      producto['url_imagen_principal'] ??
                                      (producto['imagenes'] != null &&
                                              producto['imagenes'].isNotEmpty
                                          ? producto['imagenes'][0]['url']
                                          : null);
                                  if (url != null &&
                                      url.toString().isNotEmpty) {
                                    return Image.network(
                                      url,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.broken_image),
                                    );
                                  } else {
                                    return const Icon(
                                      Icons.image_not_supported,
                                    );
                                  }
                                })(),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      producto['nombre'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Bs${item['precio_unitario']}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          icon: const Icon(
                                            Icons.remove_circle_outline,
                                            size: 24,
                                          ),
                                          onPressed: item['cantidad'] > 1
                                              ? () => actualizarCantidad(
                                                  producto['id'],
                                                  item['cantidad'] - 1,
                                                )
                                              : null,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          child: Text(
                                            '${item['cantidad']}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          icon: const Icon(
                                            Icons.add_circle_outline,
                                            size: 24,
                                          ),
                                          onPressed: () => actualizarCantidad(
                                            producto['id'],
                                            item['cantidad'] + 1,
                                          ),
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () =>
                                              eliminarProducto(producto['id']),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
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
                            'Bs${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CheckoutPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Proceder al pago',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
