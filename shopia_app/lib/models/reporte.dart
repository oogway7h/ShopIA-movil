class Reporte {
  final String id;
  final String titulo;
  final String descripcion;
  final String endpoint;
  final String fileName;
  final bool requiereFechas;
  final bool requiereCategoria;

  Reporte({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.endpoint,
    required this.fileName,
    this.requiereFechas = false,
    this.requiereCategoria = false,
  });
}
