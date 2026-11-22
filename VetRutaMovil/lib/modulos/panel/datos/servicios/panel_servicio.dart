import 'package:dio/dio.dart';
import 'package:vetruta_movil/core/red/cliente_api.dart';
import 'package:vetruta_movil/core/red/excepcion_api.dart';
import 'package:vetruta_movil/modulos/panel/datos/modelos/mascotas_atendidas.dart';
import 'package:vetruta_movil/modulos/panel/datos/modelos/pacientes_por_especie.dart';
import 'package:vetruta_movil/modulos/panel/datos/modelos/resumen_panel.dart';
import 'package:vetruta_movil/modulos/panel/datos/modelos/visitas_por_fecha.dart';
import 'package:vetruta_movil/modulos/panel/datos/modelos/visitas_por_servicio.dart';
import 'package:vetruta_movil/modulos/panel/datos/modelos/visitas_por_tecnico.dart';

class PanelServicio {
  PanelServicio(this._clienteApi);

  final ClienteApi _clienteApi;

  Future<ResumenPanel> obtenerResumen() async {
    try {
      final respuesta = await _clienteApi.dio.get<Map<String, dynamic>>(
        '/panel/resumen',
      );

      final datos = respuesta.data;
      if (datos == null) {
        throw const ExcepcionApi('La respuesta del servidor no es válida.');
      }

      return ResumenPanel.fromJson(datos);
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

  Future<List<VisitasPorServicio>> obtenerVisitasPorServicio() {
    return _obtenerLista(
      '/panel/visitas-por-servicio',
      VisitasPorServicio.fromJson,
    );
  }

  Future<List<VisitasPorFecha>> obtenerVisitasPorFecha() {
    return _obtenerLista(
      '/panel/visitas-por-fecha',
      VisitasPorFecha.fromJson,
    );
  }

  Future<List<VisitasPorTecnico>> obtenerVisitasPorTecnico() {
    return _obtenerLista(
      '/panel/visitas-por-tecnico',
      VisitasPorTecnico.fromJson,
    );
  }

  Future<List<MascotasAtendidas>> obtenerMascotasAtendidas() {
    return _obtenerLista(
      '/panel/mascotas-atendidas',
      MascotasAtendidas.fromJson,
    );
  }

  Future<List<PacientesPorEspecie>> obtenerPacientesPorEspecie() {
    return _obtenerLista(
      '/panel/pacientes-por-especie',
      PacientesPorEspecie.fromJson,
    );
  }

  Future<List<T>> _obtenerLista<T>(
    String ruta,
    T Function(Map<String, dynamic>) convertir,
  ) async {
    try {
      final respuesta = await _clienteApi.dio.get<List<dynamic>>(ruta);
      final datos = respuesta.data;

      if (datos == null) {
        throw const ExcepcionApi('La respuesta del servidor no es válida.');
      }

      return datos
          .map(
            (elemento) => convertir(
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
        return 'No fue posible obtener la información del panel.';
    }
  }
}
