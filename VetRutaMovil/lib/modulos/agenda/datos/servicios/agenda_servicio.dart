import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vetruta_movil/core/red/cliente_api.dart';
import 'package:vetruta_movil/core/red/excepcion_api.dart';
import 'package:vetruta_movil/modulos/agenda/datos/modelos/agenda_visita.dart';
import 'package:vetruta_movil/modulos/agenda/datos/modelos/completar_visita_solicitud.dart';
import 'package:vetruta_movil/modulos/agenda/datos/modelos/detalle_visita.dart';
import 'package:vetruta_movil/modulos/agenda/datos/modelos/evidencia_resultado.dart';
import 'package:vetruta_movil/modulos/agenda/datos/modelos/evidencia_visita.dart';
import 'package:vetruta_movil/modulos/agenda/datos/modelos/opciones_programacion.dart';
import 'package:vetruta_movil/modulos/agenda/datos/modelos/registro_visita_resultado.dart';

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

      visitas.sort((primera, segunda) {
        return primera.fechaProgramada.compareTo(segunda.fechaProgramada);
      });

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

  Future<DetalleVisita> obtenerDetalle(int visitaId) async {
    try {
      final respuesta = await _clienteApi.dio.get<Map<String, dynamic>>(
        '/visitas/$visitaId',
      );

      final datos = respuesta.data;

      if (datos == null) {
        throw const ExcepcionApi('La respuesta del servidor no es válida.');
      }

      return DetalleVisita.fromJson(datos);
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

  Future<List<PacienteProgramacion>> obtenerPacientesProgramacion() async {
    try {
      final respuesta = await _clienteApi.dio.get<List<dynamic>>(
        '/asignaciones/mis-pacientes',
        queryParameters: {'activo': true},
      );

      final datos = respuesta.data;
      if (datos == null) {
        throw const ExcepcionApi('La respuesta del servidor no es válida.');
      }

      return datos
          .map(
            (elemento) => PacienteProgramacion.fromJson(
              Map<String, dynamic>.from(elemento as Map),
            ),
          )
          .toList();
    } on DioException catch (excepcion) {
      throw ExcepcionApi(
        _obtenerMensaje(excepcion),
        codigoEstado: excepcion.response?.statusCode,
      );
    }
  }

  Future<List<ServicioProgramacion>> obtenerServiciosProgramacion() async {
    try {
      final respuesta = await _clienteApi.dio.get<List<dynamic>>(
        '/catalogos/servicios',
        queryParameters: {'activo': true},
      );

      final datos = respuesta.data;
      if (datos == null) {
        throw const ExcepcionApi('La respuesta del servidor no es válida.');
      }

      return datos
          .map(
            (elemento) => ServicioProgramacion.fromJson(
              Map<String, dynamic>.from(elemento as Map),
            ),
          )
          .toList();
    } on DioException catch (excepcion) {
      throw ExcepcionApi(
        _obtenerMensaje(excepcion),
        codigoEstado: excepcion.response?.statusCode,
      );
    }
  }

  Future<void> programarVisita({
    required PacienteProgramacion paciente,
    required ServicioProgramacion servicio,
    required DateTime fechaProgramada,
    required double precioProgramado,
    String? observaciones,
  }) async {
    try {
      await _clienteApi.dio.post<Map<String, dynamic>>(
        '/visitas',
        data: {
          'pacienteId': paciente.pacienteId,
          'servicioId': servicio.servicioId,
          'medicoResponsableUsuarioId': paciente.asignadoPorUsuarioId,
          'tecnicoUsuarioId': paciente.tecnicoUsuarioId,
          'fechaProgramada': fechaProgramada.toIso8601String(),
          'precioProgramado': precioProgramado,
          'observacionesProgramacion': _textoOpcional(observaciones),
        },
      );
    } on DioException catch (excepcion) {
      throw ExcepcionApi(
        _obtenerMensaje(excepcion),
        codigoEstado: excepcion.response?.statusCode,
      );
    }
  }

  Future<List<EvidenciaVisita>> obtenerEvidencias(int visitaId) async {
    try {
      final respuesta = await _clienteApi.dio.get<List<dynamic>>(
        '/visitas/$visitaId/evidencias',
      );

      final datos = respuesta.data;

      if (datos == null) {
        throw const ExcepcionApi('La respuesta del servidor no es válida.');
      }

      return datos
          .map(
            (elemento) => EvidenciaVisita.fromJson(
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

  Future<RegistroVisitaResultado> completarVisita(
    int visitaId,
    CompletarVisitaSolicitud solicitud,
  ) async {
    try {
      final respuesta = await _clienteApi.dio.post<Map<String, dynamic>>(
        '/visitas/$visitaId/completar',
        data: solicitud.toJson(),
      );

      final datos = respuesta.data;

      if (datos == null) {
        throw const ExcepcionApi('La respuesta del servidor no es válida.');
      }

      return RegistroVisitaResultado.fromJson(datos);
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

  Future<EvidenciaResultado> agregarEvidencia(
    int visitaId,
    XFile archivo,
  ) async {
    try {
      final bytes = await archivo.readAsBytes();

      if (bytes.isEmpty) {
        throw const ExcepcionApi('La fotografía está vacía.');
      }

      if (bytes.length > 10 * 1024 * 1024) {
        throw const ExcepcionApi('La fotografía no puede superar los 10 MB.');
      }

      final tipoContenido = _obtenerTipoContenido(archivo);

      final formulario = FormData.fromMap({
        'archivo': MultipartFile.fromBytes(
          bytes,
          filename: archivo.name,
          contentType: DioMediaType.parse(tipoContenido),
        ),
        'fechaCaptura': DateTime.now().toIso8601String(),
      });

      final respuesta = await _clienteApi.dio.post<Map<String, dynamic>>(
        '/visitas/$visitaId/evidencias',
        data: formulario,
      );

      final datos = respuesta.data;

      if (datos == null) {
        throw const ExcepcionApi('La respuesta del servidor no es válida.');
      }

      return EvidenciaResultado.fromJson(datos);
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

  String _obtenerTipoContenido(XFile archivo) {
    final tipoInformado = archivo.mimeType?.toLowerCase();

    if (tipoInformado == 'image/jpeg' ||
        tipoInformado == 'image/png' ||
        tipoInformado == 'image/webp') {
      return tipoInformado!;
    }

    final nombre = archivo.name.toLowerCase();

    if (nombre.endsWith('.jpg') || nombre.endsWith('.jpeg')) {
      return 'image/jpeg';
    }

    if (nombre.endsWith('.png')) {
      return 'image/png';
    }

    if (nombre.endsWith('.webp')) {
      return 'image/webp';
    }

    throw const ExcepcionApi('Solo se permiten fotografías JPG, PNG o WEBP.');
  }

  String _formatearFecha(DateTime fecha) {
    final anio = fecha.year.toString().padLeft(4, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final dia = fecha.day.toString().padLeft(2, '0');

    return '$anio-$mes-$dia';
  }

  String? _textoOpcional(String? texto) {
    final valor = texto?.trim();
    return valor == null || valor.isEmpty ? null : valor;
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
        return 'Ocurrió un error al comunicarse con el servidor.';
    }
  }
}
