class UsuarioAdministracion {
  const UsuarioAdministracion({
    required this.usuarioId,
    required this.nombreUsuario,
    required this.nombres,
    required this.apellidos,
    required this.codigoRol,
    required this.nombreRol,
    required this.activo,
    this.correo,
    this.telefono,
  });

  final int usuarioId;
  final String nombreUsuario;
  final String nombres;
  final String apellidos;
  final String codigoRol;
  final String nombreRol;
  final bool activo;
  final String? correo;
  final String? telefono;

  String get nombreCompleto => '$nombres $apellidos'.trim();

  factory UsuarioAdministracion.fromJson(Map<String, dynamic> json) {
    return UsuarioAdministracion(
      usuarioId: (json['usuarioId'] as num?)?.toInt() ?? 0,
      nombreUsuario: json['nombreUsuario'] as String? ?? '',
      nombres: json['nombres'] as String? ?? '',
      apellidos: json['apellidos'] as String? ?? '',
      codigoRol: json['codigoRol'] as String? ?? '',
      nombreRol: json['nombreRol'] as String? ?? '',
      activo: json['activo'] as bool? ?? false,
      correo: json['correo'] as String?,
      telefono: json['telefono'] as String?,
    );
  }
}

class RolAdministracion {
  const RolAdministracion({
    required this.rolId,
    required this.codigo,
    required this.nombre,
  });

  final int rolId;
  final String codigo;
  final String nombre;

  factory RolAdministracion.fromJson(Map<String, dynamic> json) {
    return RolAdministracion(
      rolId: (json['rolId'] as num?)?.toInt() ?? 0,
      codigo: json['codigo'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
    );
  }
}
