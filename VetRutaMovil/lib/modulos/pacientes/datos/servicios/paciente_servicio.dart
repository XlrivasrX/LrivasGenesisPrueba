import 'package:dio/dio.dart';
import 'package:vetruta_movil/core/red/cliente_api.dart';
import 'package:vetruta_movil/core/red/excepcion_api.dart';
import 'package:vetruta_movil/modulos/pacientes/datos/modelos/paciente_detalle.dart';

class PacienteServicio {
  PacienteServicio(this._clienteApi);

  final ClienteApi _clienteApi;

  Future<PacienteDetalle> obtenerDetalle(int pacienteId) async {
    try {
      final respuesta =
          await _clienteApi.dio.get<Map<String, dynamic>>(
        '/pacientes/$pacienteId',
      );

      final datos = respuesta.data;

      if (datos == null) {
        throw const ExcepcionApi(
          'La respuesta del servidor no es válida.',
        );
      }

      return PacienteDetalle.fromJson(datos);
    } on DioException catch (excepcion) {
      throw ExcepcionApi(
        _obtenerMensaje(excepcion),
        codigoEstado: excepcion.response?.statusCode,
      );
    } on FormatException {
      throw const ExcepcionApi(
        'La respuesta del servidor no tiene el formato esperado.',
      );
    } on TypeError {
      throw const ExcepcionApi(
        'La respuesta del servidor no tiene el formato esperado.',
      );
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
        return 'No fue posible obtener el detalle del paciente.';
    }
  }
}