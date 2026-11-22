import 'package:vetruta_movil/modulos/autenticacion/datos/modelos/usuario_sesion.dart';

class RespuestaInicioSesion {
  const RespuestaInicioSesion({
    required this.tokenAcceso,
    required this.tokenActualizacion,
    required this.fechaExpiracion,
    required this.usuario,
  });

  final String tokenAcceso;
  final String tokenActualizacion;
  final DateTime fechaExpiracion;
  final UsuarioSesion usuario;

  factory RespuestaInicioSesion.fromJson(Map<String, dynamic> json) {
    return RespuestaInicioSesion(
      tokenAcceso: json['token'] as String,
      tokenActualizacion: json['tokenActualizacion'] as String,
      fechaExpiracion: DateTime.parse(json['fechaExpiracion'] as String),
      usuario: UsuarioSesion.fromJson(
        json['usuario'] as Map<String, dynamic>,
      ),
    );
  }
}