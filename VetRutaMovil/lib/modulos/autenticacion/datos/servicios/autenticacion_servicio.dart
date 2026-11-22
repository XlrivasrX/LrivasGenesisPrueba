import 'package:dio/dio.dart';
import 'package:vetruta_movil/core/almacenamiento/almacenamiento_seguro.dart';
import 'package:vetruta_movil/core/red/cliente_api.dart';
import 'package:vetruta_movil/core/red/excepcion_api.dart';
import 'package:vetruta_movil/modulos/autenticacion/datos/modelos/respuesta_inicio_sesion.dart';

class AutenticacionServicio {
  AutenticacionServicio(this._clienteApi, this._almacenamientoSeguro);

  final ClienteApi _clienteApi;
  final AlmacenamientoSeguro _almacenamientoSeguro;

  Future<RespuestaInicioSesion> iniciarSesion(String nombreUsuario, String contrasena) async {
    try {
      final respuesta = await _clienteApi.dio.post<Map<String, dynamic>>(
        '/autenticacion/iniciar-sesion',
        data: {
          'nombreUsuario': nombreUsuario.trim(),
          'contrasena': contrasena,
        },
      );

      final datos = respuesta.data;
      if (datos == null) {
        throw const ExcepcionApi('La respuesta del servidor no es válida.');
      }

      final sesion = RespuestaInicioSesion.fromJson(datos);

      await _almacenamientoSeguro.guardarTokens(
        tokenAcceso: sesion.tokenAcceso,
        tokenActualizacion: sesion.tokenActualizacion,
      );

      return sesion;
    } on DioException catch (excepcion) {
      throw ExcepcionApi(
        _obtenerMensaje(excepcion),
        codigoEstado: excepcion.response?.statusCode,
      );
    } on FormatException {
      throw const ExcepcionApi('La respuesta del servidor no tiene el formato esperado.');
    } on TypeError {
      throw const ExcepcionApi('La respuesta del servidor no tiene el formato esperado.');
    }
  }

  Future<void> cerrarSesion() async {
    final tokenActualizacion =
        await _almacenamientoSeguro.obtenerTokenActualizacion();

    try {
      if (tokenActualizacion != null && tokenActualizacion.isNotEmpty) {
        await _clienteApi.dio.post<void>(
          '/autenticacion/cerrar-sesion',
          data: {
            'tokenActualizacion': tokenActualizacion,
          },
        );
      }
    } finally {
      await _almacenamientoSeguro.eliminarTokens();
    }
  }

  String _obtenerMensaje(DioException excepcion) {
    final datos = excepcion.response?.data;

    if (datos is Map && datos['mensaje'] is String) {
      return datos['mensaje'] as String;
    }

    switch (excepcion.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'El servidor tardó demasiado en responder.';
      case DioExceptionType.connectionError:
        return 'No fue posible conectarse con el servidor.';
      default:
        return 'Ocurrió un error al iniciar sesión.';
    }
  }
}