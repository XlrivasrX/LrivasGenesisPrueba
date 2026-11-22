class UsuarioJerarquia {
  const UsuarioJerarquia({
    required this.usuarioId,
    required this.nombreUsuario,
    required this.nombres,
    required this.apellidos,
    required this.activo,
    required this.rolId,
    required this.codigoRol,
    required this.nombreRol,
  });

  final int usuarioId;
  final String nombreUsuario;
  final String nombres;
  final String apellidos;
  final bool activo;
  final int rolId;
  final String codigoRol;
  final String nombreRol;

  String get nombreCompleto {
    final nombre = '$nombres $apellidos'.trim();
    return nombre.isEmpty ? nombreUsuario : nombre;
  }

  factory UsuarioJerarquia.fromJson(Map<String, dynamic> json) {
    return UsuarioJerarquia(
      usuarioId: json['usuarioId'] as int,
      nombreUsuario: json['nombreUsuario'] as String? ?? '',
      nombres: json['nombres'] as String? ?? '',
      apellidos: json['apellidos'] as String? ?? '',
      activo: json['activo'] as bool? ?? false,
      rolId: json['rolId'] as int,
      codigoRol: json['codigoRol'] as String? ?? '',
      nombreRol: json['nombreRol'] as String? ?? '',
    );
  }
}

class TecnicoAsignado {
  const TecnicoAsignado({
    required this.asignacionJerarquiaId,
    required this.usuarioSuperiorId,
    required this.usuarioSubordinadoId,
    required this.nombreUsuario,
    required this.nombres,
    required this.apellidos,
    required this.activo,
    required this.codigoRol,
    required this.nombreRol,
    required this.fechaInicio,
  });

  final int asignacionJerarquiaId;
  final int usuarioSuperiorId;
  final int usuarioSubordinadoId;
  final String nombreUsuario;
  final String nombres;
  final String apellidos;
  final bool activo;
  final String codigoRol;
  final String nombreRol;
  final DateTime fechaInicio;

  String get nombreCompleto {
    final nombre = '$nombres $apellidos'.trim();
    return nombre.isEmpty ? nombreUsuario : nombre;
  }

  factory TecnicoAsignado.fromJson(Map<String, dynamic> json) {
    return TecnicoAsignado(
      asignacionJerarquiaId:
          json['asignacionJerarquiaId'] as int,
      usuarioSuperiorId: json['usuarioSuperiorId'] as int,
      usuarioSubordinadoId:
          json['usuarioSubordinadoId'] as int,
      nombreUsuario: json['nombreUsuario'] as String? ?? '',
      nombres: json['nombres'] as String? ?? '',
      apellidos: json['apellidos'] as String? ?? '',
      activo: json['activo'] as bool? ?? false,
      codigoRol: json['codigoRol'] as String? ?? '',
      nombreRol: json['nombreRol'] as String? ?? '',
      fechaInicio: DateTime.parse(json['fechaInicio'] as String),
    );
  }
}