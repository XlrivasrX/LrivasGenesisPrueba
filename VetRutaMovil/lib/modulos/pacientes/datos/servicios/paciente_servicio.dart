import 'package:dio/dio.dart';
import 'package:vetruta_movil/core/red/cliente_api.dart';
import 'package:vetruta_movil/core/red/excepcion_api.dart';
import 'package:vetruta_movil/modulos/jerarquia/datos/modelos/usuario_jerarquia.dart';
import 'package:vetruta_movil/modulos/pacientes/datos/modelos/catalogos_paciente.dart';
import 'package:vetruta_movil/modulos/pacientes/datos/modelos/historial_clinico.dart';
import 'package:vetruta_movil/modulos/pacientes/datos/modelos/paciente_detalle.dart';

class PacienteServicio {
  PacienteServicio(this._clienteApi);

  final ClienteApi _clienteApi;

  Future<PacienteDetalle> obtenerDetalle(int pacienteId) async {
    try {
      final respuesta = await _clienteApi.dio.get<Map<String, dynamic>>(
        '/pacientes/$pacienteId',
      );

      final datos = respuesta.data;

      if (datos == null) {
        throw const ExcepcionApi('La respuesta del servidor no es válida.');
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

  Future<List<HistorialClinico>> obtenerHistorial(int pacienteId) async {
    try {
      final respuesta = await _clienteApi.dio.get<List<dynamic>>(
        '/visitas/paciente/$pacienteId/historial',
      );

      final datos = respuesta.data;

      if (datos == null) {
        throw const ExcepcionApi('La respuesta del servidor no es válida.');
      }

      final historial = datos
          .map(
            (elemento) => HistorialClinico.fromJson(
              Map<String, dynamic>.from(elemento as Map),
            ),
          )
          .toList();

      historial.sort(
        (primero, segundo) =>
            segundo.fechaRegistro.compareTo(primero.fechaRegistro),
      );

      return historial;
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

  Future<List<EspecieCatalogo>> obtenerEspecies() async {
    try {
      final respuesta = await _clienteApi.dio.get<List<dynamic>>(
        '/catalogos/especies',
        queryParameters: {'activo': true},
      );

      final datos = respuesta.data;

      if (datos == null) {
        throw const ExcepcionApi('La respuesta del servidor no es válida.');
      }

      return datos
          .map(
            (elemento) => EspecieCatalogo.fromJson(
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

  Future<List<RazaCatalogo>> obtenerRazas(int especieId) async {
    try {
      final respuesta = await _clienteApi.dio.get<List<dynamic>>(
        '/catalogos/razas',
        queryParameters: {'especieId': especieId, 'activo': true},
      );

      final datos = respuesta.data;

      if (datos == null) {
        throw const ExcepcionApi('La respuesta del servidor no es válida.');
      }

      return datos
          .map(
            (elemento) => RazaCatalogo.fromJson(
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

  Future<List<TecnicoAsignado>> obtenerMisTecnicos() async {
    try {
      final respuesta = await _clienteApi.dio.get<List<dynamic>>(
        '/jerarquia/mis-tecnicos',
      );

      final datos = respuesta.data;

      if (datos == null) {
        throw const ExcepcionApi('La respuesta del servidor no es válida.');
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
    }
  }

  Future<int> crearPacienteAsignado({
    required String nombresPropietario,
    required String apellidosPropietario,
    required String telefono,
    required String direccion,
    required int especieId,
    required int razaId,
    required String nombrePaciente,
    required int tecnicoUsuarioId,
    String? telefonoAlternativo,
    DateTime? fechaNacimiento,
    String? observaciones,
    double? latitud,
    double? longitud,
  }) async {
    try {
      final respuestaPropietario = await _clienteApi.dio
          .post<Map<String, dynamic>>(
            '/propietarios',
            data: {
              'nombres': nombresPropietario.trim(),
              'apellidos': apellidosPropietario.trim(),
              'telefono': telefono.trim(),
              'telefonoAlternativo': _textoOpcional(telefonoAlternativo),
              'direccion': direccion.trim(),
              'latitud': latitud,
              'longitud': longitud,
              'activo': true,
            },
          );

      final propietarioId = respuestaPropietario.data?['propietarioId'] as int?;

      if (propietarioId == null) {
        throw const ExcepcionApi('No fue posible crear el propietario.');
      }

      final respuestaPaciente = await _clienteApi.dio
          .post<Map<String, dynamic>>(
            '/pacientes',
            data: {
              'propietarioId': propietarioId,
              'especieId': especieId,
              'razaId': razaId,
              'nombre': nombrePaciente.trim(),
              'fechaNacimientoAproximada': fechaNacimiento?.toIso8601String(),
              'rutaFoto': null,
              'observaciones': _textoOpcional(observaciones),
              'activo': true,
            },
          );

      final pacienteId = respuestaPaciente.data?['pacienteId'] as int?;

      if (pacienteId == null) {
        throw const ExcepcionApi('No fue posible crear el paciente.');
      }

      await _clienteApi.dio.post<Map<String, dynamic>>(
        '/asignaciones',
        data: {
          'pacienteId': pacienteId,
          'tecnicoUsuarioId': tecnicoUsuarioId,
          'observacion': 'Asignación inicial del paciente.',
        },
      );

      return pacienteId;
    } on DioException catch (excepcion) {
      throw ExcepcionApi(
        _obtenerMensaje(excepcion),
        codigoEstado: excepcion.response?.statusCode,
      );
    }
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
        return 'No fue posible obtener el detalle del paciente.';
    }
  }
}
