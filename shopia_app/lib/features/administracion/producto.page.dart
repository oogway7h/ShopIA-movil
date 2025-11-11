import 'package:flutter/material.dart';
import '../../services/apiService.dart';
import '../../models/producto.dart';

class ProductoPage extends StatefulWidget {
  const ProductoPage({Key? key}) : super(key: key);

  @override
  State<ProductoPage> createState() => _ProductoPageState();
}

class _ProductoPageState extends State<ProductoPage> {
  final ApiService api = ApiService();
  List<Producto> productos = [];
  List<Producto> productosFiltrados = [];
  bool loading = false;
  String error = '';
  String query = '';

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
      final data = await api.get('productos/');
      final List items = data is List ? data : (data['results'] ?? []);
      productos = items.map((e) => Producto.fromJson(e)).toList();
      filtrarProductos();
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

  void filtrarProductos() {
    // Asegura que productosFiltrados nunca sea null
    List<Producto> filtrados;
    if (query.isEmpty) {
      filtrados = productos;
    } else {
      final q = query.toLowerCase();
      filtrados = productos.where((p) {
        return (p.nombre.toLowerCase().contains(q) ||
            p.categoria.toLowerCase().contains(q));
      }).toList();
    }
    setState(() {
      productosFiltrados = filtrados;
    });
  }

  Future<void> editarProducto(Producto producto) async {
    final result = await showDialog<Producto>(
      context: context,
      builder: (context) => EditarProductoDialog(producto: producto),
    );
    if (result != null) {
      setState(() => loading = true);
      try {
        // Convierte el descuento a decimal si el usuario ingresa entero
        double descuentoDecimal = result.descuento;
        if (descuentoDecimal > 1) {
          descuentoDecimal = descuentoDecimal / 100;
        }

        // Obtén el producto actual desde la API
        final productoActual = await api.get('productos/${producto.id}/');

        // Mezcla los datos originales con los nuevos
        final data = {
          'nombre': productoActual['nombre'],
          'descripcion': productoActual['descripcion'],
          'categoria_id':
              productoActual['categoria_id'] ??
              productoActual['categoria']?['id'],
          'stock': result.stock,
          'precio': result.precio,
          'descuento': descuentoDecimal,
          'estado': result.estado,
        };

        await api.put('productos/${producto.id}/', data);
        await cargarProductos();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Producto actualizado')));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productosMostrar = productosFiltrados;
    return Scaffold(
      appBar: AppBar(title: const Text('Productos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o categoría...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.blue[50],
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                query = value;
                filtrarProductos();
              },
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : error.isNotEmpty
                ? Center(
                    child: Text(
                      error,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : productosMostrar.isEmpty
                ? const Center(child: Text('No hay productos disponibles'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: productosMostrar.length,
                    itemBuilder: (context, i) {
                      final p = productosMostrar[i];
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      p.nombre,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () => editarProducto(p),
                                    tooltip: 'Editar',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 12,
                                runSpacing: 4,
                                children: [
                                  Chip(
                                    label: Text('Categoría: ${p.categoria}'),
                                    backgroundColor: Colors.blue[50],
                                  ),
                                  Chip(
                                    label: Text('Stock: ${p.stock}'),
                                    backgroundColor: Colors.green[50],
                                  ),
                                  Chip(
                                    label: Text(
                                      'Estado: ${p.estado ? "Activo" : "Inactivo"}',
                                    ),
                                    backgroundColor: p.estado
                                        ? Colors.green[100]
                                        : Colors.red[100],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Precio: Bs${p.precio.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Descuento: ${p.descuento}%',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class EditarProductoDialog extends StatefulWidget {
  final Producto producto;
  const EditarProductoDialog({Key? key, required this.producto})
    : super(key: key);

  @override
  State<EditarProductoDialog> createState() => _EditarProductoDialogState();
}

class _EditarProductoDialogState extends State<EditarProductoDialog> {
  late TextEditingController stockCtrl;
  late TextEditingController precioCtrl;
  late TextEditingController descuentoCtrl;
  late bool estado;

  @override
  void initState() {
    super.initState();
    stockCtrl = TextEditingController(text: widget.producto.stock.toString());
    precioCtrl = TextEditingController(
      text: widget.producto.precio.toStringAsFixed(2),
    );
    descuentoCtrl = TextEditingController(
      text: widget.producto.descuento.toString(),
    );
    estado = widget.producto.estado;
  }

  @override
  void dispose() {
    stockCtrl.dispose();
    precioCtrl.dispose();
    descuentoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Producto'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: stockCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Stock'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: precioCtrl,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Precio'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descuentoCtrl,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Descuento (%)'),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Estado'),
              value: estado,
              onChanged: (v) => setState(() => estado = v),
              activeColor: Colors.green,
              inactiveThumbColor: Colors.red,
              inactiveTrackColor: Colors.red[100],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: const Text('Guardar'),
          onPressed: () {
            final stock = int.tryParse(stockCtrl.text) ?? widget.producto.stock;
            final precio =
                double.tryParse(precioCtrl.text) ?? widget.producto.precio;
            final descuento =
                double.tryParse(descuentoCtrl.text) ??
                widget.producto.descuento;
            Navigator.pop(
              context,
              Producto(
                id: widget.producto.id,
                nombre: widget.producto.nombre,
                categoria: widget.producto.categoria,
                categoriaId: widget.producto.categoriaId,
                descripcion: widget.producto.descripcion, // <-- AGREGA ESTO
                stock: stock,
                precio: precio,
                descuento: descuento,
                estado: estado,
              ),
            );
          },
        ),
      ],
    );
  }
}
