class Producto {
  final int id;
  final String nombre;
  final String? marca;
  final String descripcion;
  final String categoria;
  final int categoriaId;
  final int stock;
  final double precio;
  final double descuento;
  final bool estado;
  final String? urlImagenPrincipal;
  final List<ImagenProducto> imagenes;

  Producto({
    required this.id,
    required this.nombre,
    this.marca,
    required this.descripcion,
    required this.categoria,
    required this.categoriaId,
    required this.stock,
    required this.precio,
    required this.descuento,
    required this.estado,
    this.urlImagenPrincipal,
    this.imagenes = const [],
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'],
      nombre: json['nombre'],
      marca: json['marca'],
      descripcion: json['descripcion'] ?? '',
      categoria: json['categoria']?['nombre'] ?? '',
      categoriaId: json['categoria']?['id'] ?? json['categoria_id'] ?? 0,
      stock: json['stock'],
      precio: double.tryParse(json['precio'].toString()) ?? 0.0,
      descuento: double.tryParse(json['descuento'].toString()) ?? 0.0,
      estado: json['estado'],
      urlImagenPrincipal: json['url_imagen_principal'],
      imagenes:
          (json['imagenes'] as List?)
              ?.map((e) => ImagenProducto.fromJson(e))
              .toList() ??
          [],
    );
  }

  double get precioFinal => precio * (1 - descuento);
  bool get tieneDescuento => descuento > 0;
  String get imagenPrincipal =>
      urlImagenPrincipal ?? (imagenes.isNotEmpty ? imagenes.first.url : '');
}

class ImagenProducto {
  final int id;
  final String url;
  final String? descripcion;

  ImagenProducto({required this.id, required this.url, this.descripcion});

  factory ImagenProducto.fromJson(Map<String, dynamic> json) {
    return ImagenProducto(
      id: json['id'],
      url: json['url'],
      descripcion: json['descripcion'],
    );
  }
}
