import 'package:dio/dio.dart';
import 'package:vetruta_movil/core/red/cliente_api.dart';
import 'package:vetruta_movil/core/red/excepcion_api.dart';
import 'package:vetruta_movil/modulos/jerarquia/datos/modelos/usuario_jerarquia.dart';

class JerarquiaServicio {
  JerarquiaServicio(this._clienteApi);

  final ClienteApi _clienteApi;

  Future<List<UsuarioJerarquia>> obtenerUsuariosActivos() async {
    try {
      final respuesta = await _clienteApi.dio.get<List<dynamic>>(
        '/usuarios',
        queryParameters: {
          'activo': true,
        },
      );

      final datos = respuesta.data;

      if (datos == null) {
        throw const ExcepcionApi(
          'La respuesta del servidor no es válida.',
        );
      }

      return datos
          .map(
            (elemento) => UsuarioJerarquia.fromJson(
              Map<String, dynamic>.from(elemento as Map),
            ),
          )
          .toList();
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

  Future<List<TecnicoAsignado>> obtenerTecnicosMedico(
    int medicoUsuarioId,
  ) async {
    try {
      final respuesta = await _clienteApi.dio.get<List<dynamic>>(
        '/jerarquia/medico/$medicoUsuarioId/tecnicos',
      );

      final datos = respuesta.data;

      if (datos == null) {
        throw const ExcepcionApi(
          'La respuesta del servidor no es válida.',
        );
      }

      return datos
          .map(
            (elemento) => TecnicoAsignado.fromJson(
              Map<String, dynamic>.from(elemento as Map),
            ),
          )
          .toList();
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

  Future<void> asignarTecnico({
    required int medicoUsuarioId,
    required int tecnicoUsuarioId,
  }) async {
    try {
      await _clienteApi.dio.post<Map<String, dynamic>>(
        '/jerarquia/asignar-tecnico',
        data: {
          'medicoUsuarioId': medicoUsuarioId,
          'tecnicoUsuarioId': tecnicoUsuarioId,
        },
      );
    } on DioException catch (excepcion) {
      throw ExcepcionApi(
        _obtenerMensaje(excepcion),
        codigoEstado: excepcion.response?.statusCode,
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
        return 'No fue posible administrar la jerarquía.';
    }
  }
}