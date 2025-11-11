import 'package:flutter/material.dart';

class Venta {
  final int id;
  final String usuario;
  final DateTime fecha;
  final double montoTotal;
  final String direccion;
  final int? numeroInt;
  final String estado;
  final List<DetalleVenta> detalles;
  final int pagos;

  Venta({
    required this.id,
    required this.usuario,
    required this.fecha,
    required this.montoTotal,
    required this.direccion,
    this.numeroInt,
    required this.estado,
    required this.detalles,
    required this.pagos,
  });

  factory Venta.fromJson(Map<String, dynamic> json) {
    return Venta(
      id: json['id'],
      usuario: json['usuario'],
      fecha: DateTime.parse(json['fecha']),
      montoTotal: double.tryParse(json['monto_total'].toString()) ?? 0.0,
      direccion: json['direccion'],
      numeroInt: json['numero_int'],
      estado: json['estado'],
      detalles: (json['detalles'] as List)
          .map((e) => DetalleVenta.fromJson(e))
          .toList(),
      pagos: json['pagos'] ?? 0,
    );
  }

  String get estadoTexto {
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

  Color get estadoColor {
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
}

class DetalleVenta {
  final int id;
  final Map<String, dynamic> producto;
  final double precioUnitario;
  final int cantidad;

  DetalleVenta({
    required this.id,
    required this.producto,
    required this.precioUnitario,
    required this.cantidad,
  });

  factory DetalleVenta.fromJson(Map<String, dynamic> json) {
    return DetalleVenta(
      id: json['id'],
      producto: json['producto'],
      precioUnitario:
          double.tryParse(json['precio_unitario'].toString()) ?? 0.0,
      cantidad: json['cantidad'],
    );
  }

  double get subtotal => precioUnitario * cantidad;
}
