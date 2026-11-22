import 'package:dio/dio.dart';
import 'package:vetruta_movil/core/red/cliente_api.dart';
import 'package:vetruta_movil/core/red/excepcion_api.dart';
import 'package:vetruta_movil/modulos/agenda/datos/modelos/agenda_visita.dart';

class AgendaServicio {
  AgendaServicio(this._clienteApi);

  final ClienteApi _clienteApi;

  Future<List<AgendaVisita>> obtenerAgenda({
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) async {
    try {
      final parametros = <String, dynamic>{};

      if (fechaDesde != null) {
        parametros['fechaDesde'] = _formatearFecha(fechaDesde);
      }

      if (fechaHasta != null) {
        parametros['fechaHasta'] = _formatearFecha(fechaHasta);
      }

      final respuesta = await _clienteApi.dio.get<List<dynamic>>(
        '/visitas',
        queryParameters: parametros,
      );

      final datos = respuesta.data;
      if (datos == null) {
        throw const ExcepcionApi('La respuesta del servidor no es válida.');
      }

      final visitas = datos
          .map(
            (elemento) => AgendaVisita.fromJson(
              Map<String, dynamic>.from(elemento as Map),
            ),
          )
          .toList();

      visitas.sort(
        (primera, segunda) {
          return primera.fechaProgramada.compareTo(segunda.fechaProgramada);
        },
      );

      return visitas;
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

  String _formatearFecha(DateTime fecha) {
    final anio = fecha.year.toString().padLeft(4, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final dia = fecha.day.toString().padLeft(2, '0');

    return '$anio-$mes-$dia';
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
        return 'No fue posible obtener la agenda.';
    }
  }
}