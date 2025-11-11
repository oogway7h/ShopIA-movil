import 'package:flutter/material.dart';
import '../../services/apiService.dart';
import '../../models/producto.dart';
import 'producto_detalle_page.dart';
import './carrito_page.dart';

class TiendaPage extends StatefulWidget {
  final int? categoriaId;
  final String? categoriaNombre;

  const TiendaPage({Key? key, this.categoriaId, this.categoriaNombre})
    : super(key: key);

  @override
  State<TiendaPage> createState() => _TiendaPageState();
}

class _TiendaPageState extends State<TiendaPage> {
  final ApiService api = ApiService();
  List<Producto> productos = [];
  bool loading = false;
  String error = '';

  @override
  void initState() {
    super.initState();
    cargarProductos();
  }

  Future<void> cargarProductos() async {
    setState(() {
      loading = true;
      error = '';
    });
    try {
      final endpoint = widget.categoriaId != null
          ? 'productos/?categoria=${widget.categoriaId}'
          : 'productos/';
      final data = await api.get(endpoint);
      final List items = data is List ? data : (data['results'] ?? []);
      setState(() {
        productos = items
            .map((e) => Producto.fromJson(e))
            .where((p) => p.estado)
            .toList();
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoriaNombre ?? 'Tienda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CarritoPage()),
              );
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
          ? Center(
              child: Text(error, style: const TextStyle(color: Colors.red)),
            )
          : productos.isEmpty
          ? const Center(child: Text('No hay productos en esta categoría'))
          : RefreshIndicator(
              onRefresh: cargarProductos,
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: productos.length,
                itemBuilder: (context, i) {
                  return ProductoCard(producto: productos[i]);
                },
              ),
            ),
    );
  }
}

class ProductoCard extends StatefulWidget {
  final Producto producto;
  const ProductoCard({Key? key, required this.producto}) : super(key: key);

  @override
  State<ProductoCard> createState() => _ProductoCardState();
}

class _ProductoCardState extends State<ProductoCard> {
  final ApiService api = ApiService();
  int cantidad = 1;
  bool agregando = false;

  Future<void> agregarAlCarrito() async {
    setState(() => agregando = true);
    try {
      await api.post('ventas/carrito/agregar-producto/', {
        'producto_id': widget.producto.id,
        'cantidad': cantidad,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto agregado al carrito')),
      );
      setState(() => cantidad = 1);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => agregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.producto;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductoDetallePage(productoId: p.id),
                  ),
                );
              },
              child: Stack(
                children: [
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: p.imagenPrincipal.isNotEmpty
                        ? Image.network(
                            p.imagenPrincipal,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          )
                        : const Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          ),
                  ),
                  if (p.tieneDescuento)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '-${(p.descuento * 100).toInt()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.nombre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Bs${p.precioFinal.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: p.tieneDescuento ? Colors.green : Colors.black,
                      ),
                    ),
                    if (p.tieneDescuento) ...[
                      const SizedBox(width: 4),
                      Text(
                        'Bs${p.precio.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 11,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.remove, size: 18),
                      onPressed: cantidad > 1
                          ? () => setState(() => cantidad--)
                          : null,
                    ),
                    Text('$cantidad', style: const TextStyle(fontSize: 13)),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: cantidad < p.stock
                          ? () => setState(() => cantidad++)
                          : null,
                    ),
                    const Spacer(),
                    Flexible(
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          agregando
                              ? Icons.hourglass_empty
                              : Icons.shopping_cart,
                          size: 20,
                          color: Colors.blue,
                        ),
                        onPressed: agregando || p.stock == 0
                            ? null
                            : agregarAlCarrito,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
