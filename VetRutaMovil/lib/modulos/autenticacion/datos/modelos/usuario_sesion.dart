class UsuarioSesion {
  const UsuarioSesion({
    required this.usuarioId,
    required this.nombreUsuario,
    required this.nombres,
    required this.apellidos,
    required this.rolId,
    required this.codigoRol,
    required this.nombreRol,
    required this.debeCambiarContrasena,
  });

  final int usuarioId;
  final String nombreUsuario;
  final String nombres;
  final String apellidos;
  final int rolId;
  final String codigoRol;
  final String nombreRol;
  final bool debeCambiarContrasena;

  String get nombreCompleto => '$nombres $apellidos'.trim();

  factory UsuarioSesion.fromJson(Map<String, dynamic> json) {
    return UsuarioSesion(
      usuarioId: json['usuarioId'] as int,
      nombreUsuario: json['nombreUsuario'] as String,
      nombres: json['nombres'] as String,
      apellidos: json['apellidos'] as String,
      rolId: json['rolId'] as int,
      codigoRol: json['codigoRol'] as String,
      nombreRol: json['nombreRol'] as String,
      debeCambiarContrasena: json['debeCambiarContrasena'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuarioId': usuarioId,
      'nombreUsuario': nombreUsuario,
      'nombres': nombres,
      'apellidos': apellidos,
      'rolId': rolId,
      'codigoRol': codigoRol,
      'nombreRol': nombreRol,
      'debeCambiarContrasena': debeCambiarContrasena,
    };
  }
}