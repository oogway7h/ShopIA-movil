import 'package:flutter/material.dart';
import '../../services/apiService.dart';
import '../../models/producto.dart';

class ProductoDetallePage extends StatefulWidget {
  final int productoId;
  const ProductoDetallePage({Key? key, required this.productoId})
    : super(key: key);

  @override
  State<ProductoDetallePage> createState() => _ProductoDetallePageState();
}

class _ProductoDetallePageState extends State<ProductoDetallePage> {
  final ApiService api = ApiService();
  Producto? producto;
  bool loading = false;
  String error = '';
  int imgIndex = 0;
  int cantidad = 1;
  bool agregando = false;

  @override
  void initState() {
    super.initState();
    cargarProducto();
  }

  Future<void> cargarProducto() async {
    setState(() {
      loading = true;
      error = '';
    });
    try {
      final data = await api.get('productos/${widget.productoId}/');
      setState(() {
        producto = Producto.fromJson(data);
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

  Future<void> agregarAlCarrito() async {
    setState(() => agregando = true);
    try {
      await api.post('ventas/carrito/agregar-producto/', {
        'producto_id': producto!.id,
        'cantidad': cantidad,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto agregado al carrito')),
      );
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
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cargando...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (error.isNotEmpty || producto == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Text(
            error.isNotEmpty ? error : 'Producto no encontrado',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    final p = producto!;
    final imagenes = [
      if (p.urlImagenPrincipal != null) p.urlImagenPrincipal!,
      ...p.imagenes.map((e) => e.url),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(p.nombre)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 300,
                  color: Colors.grey[100],
                  child: PageView.builder(
                    itemCount: imagenes.length,
                    onPageChanged: (i) => setState(() => imgIndex = i),
                    itemBuilder: (context, i) {
                      return Image.network(
                        imagenes[i],
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image, size: 100),
                      );
                    },
                  ),
                ),
                if (p.tieneDescuento)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '-${(p.descuento * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (imagenes.length > 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  imagenes.length,
                  (i) => Container(
                    margin: const EdgeInsets.all(4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: imgIndex == i ? Colors.blue : Colors.grey[300],
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.categoria,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    p.nombre,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Bs${p.precioFinal.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: p.tieneDescuento ? Colors.green : Colors.black,
                        ),
                      ),
                      if (p.tieneDescuento) ...[
                        const SizedBox(width: 8),
                        Text(
                          'Bs${p.precio.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Descripción',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    p.descripcion,
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    p.stock > 0 ? '${p.stock} disponibles' : 'Agotado',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: p.stock > 0 ? Colors.green : Colors.red,
                    ),
                  ),
                  if (p.stock > 0) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Cantidad:', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: cantidad > 1
                              ? () => setState(() => cantidad--)
                              : null,
                        ),
                        Text(
                          '$cantidad',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: cantidad < p.stock
                              ? () => setState(() => cantidad++)
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: agregando ? null : agregarAlCarrito,
                        icon: Icon(
                          agregando
                              ? Icons.hourglass_empty
                              : Icons.shopping_cart,
                        ),
                        label: Text(
                          agregando ? 'Agregando...' : 'Agregar al carrito',
                          style: const TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
