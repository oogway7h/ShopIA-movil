class Notificacion {
  final int id;
  final String titulo;
  final String descripcion;
  final String tipo;
  final String plataforma;
  final DateTime fechaInicio;
  final DateTime fechaCreacion;
  final bool leida;
  final DateTime? fechaLectura;

  Notificacion({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.tipo,
    required this.plataforma,
    required this.fechaInicio,
    required this.fechaCreacion,
    required this.leida,
    this.fechaLectura,
  });

  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      id: json['id'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      tipo: json['tipo'],
      plataforma: json['plataforma'],
      fechaInicio: DateTime.parse(json['fecha_inicio']),
      fechaCreacion: DateTime.parse(json['fecha_creacion']),
      leida: json['leida'] ?? false,
      fechaLectura: json['fecha_lectura'] != null
          ? DateTime.parse(json['fecha_lectura'])
          : null,
    );
  }
}
