class EstadisticaVentas {
  final String periodo;
  final double monto;
  final String tipo; // 'real' o 'prediccion'
  final double crecimiento;

  EstadisticaVentas({
    required this.periodo,
    required this.monto,
    required this.tipo,
    required this.crecimiento,
  });

  factory EstadisticaVentas.fromJson(Map<String, dynamic> json) {
    return EstadisticaVentas(
      periodo: json['periodo'] ?? '',
      monto: (json['monto'] ?? 0).toDouble(),
      tipo: json['tipo'] ?? 'real',
      crecimiento: (json['crecimiento'] ?? 0).toDouble(),
    );
  }
}

class CrecimientoCategoria {
  final String nombre;
  final double porcentaje;
  final String tendencia;

  CrecimientoCategoria({
    required this.nombre,
    required this.porcentaje,
    required this.tendencia,
  });

  factory CrecimientoCategoria.fromJson(Map<String, dynamic> json) {
    return CrecimientoCategoria(
      nombre: json['categoria_nombre'] ?? '',
      porcentaje: (json['porcentaje_cambio'] ?? 0).toDouble(),
      tendencia: json['tendencia'] ?? 'estable',
    );
  }
}
