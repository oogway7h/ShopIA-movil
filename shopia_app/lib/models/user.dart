class User {
  final int id;
  final String correo;
  final String nombre;
  final String apellido;
  final List<String> roles;
  final String? telefono;
  final String? sexo;
  final bool estado;

  User({
    required this.id,
    required this.correo,
    required this.nombre,
    required this.apellido,
    required this.roles,
    this.telefono,
    this.sexo,
    required this.estado,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      correo: json['correo'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      roles: (json['roles'] as List).map((r) => r['nombre'] as String).toList(),
      telefono: json['telefono'],
      sexo: json['sexo'],
      estado: json['estado'],
    );
  }

  String get nombreCompleto => '$nombre $apellido'.trim();
  bool get esAdmin => roles.contains('admin');
  bool get esCliente => roles.contains('cliente');
}
