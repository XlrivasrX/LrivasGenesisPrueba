import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
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

  Future<Uint8List> obtenerFoto(int pacienteId) async {
    try {
      final respuesta = await _clienteApi.dio.get<List<int>>(
        '/pacientes/$pacienteId/foto',
        options: Options(responseType: ResponseType.bytes),
      );

      final datos = respuesta.data;
      if (datos == null || datos.isEmpty) {
        throw const ExcepcionApi('La fotografía no está disponible.');
      }

      return Uint8List.fromList(datos);
    } on DioException catch (excepcion) {
      throw ExcepcionApi(
        _obtenerMensaje(excepcion),
        codigoEstado: excepcion.response?.statusCode,
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

  Future<void> actualizarUbicacionPropietario({
    required int propietarioId,
    required double latitud,
    required double longitud,
  }) async {
    try {
      await _clienteApi.dio.patch<Map<String, dynamic>>(
        '/propietarios/$propietarioId/ubicacion',
        data: {'latitud': latitud, 'longitud': longitud},
      );
    } on DioException catch (excepcion) {
      throw ExcepcionApi(
        _obtenerMensaje(excepcion),
        codigoEstado: excepcion.response?.statusCode,
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
    XFile? fotoPaciente,
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

      if (fotoPaciente != null) {
        await _guardarFotoPaciente(pacienteId, fotoPaciente);
      }

      return pacienteId;
    } on DioException catch (excepcion) {
      throw ExcepcionApi(
        _obtenerMensaje(excepcion),
        codigoEstado: excepcion.response?.statusCode,
      );
    }
  }

  Future<void> _guardarFotoPaciente(int pacienteId, XFile archivo) async {
    final bytes = await archivo.readAsBytes();

    if (bytes.isEmpty) {
      throw const ExcepcionApi('La fotografía seleccionada está vacía.');
    }

    if (bytes.length > 10 * 1024 * 1024) {
      throw const ExcepcionApi('La fotografía no puede superar los 10 MB.');
    }

    final formulario = FormData.fromMap({
      'archivo': MultipartFile.fromBytes(
        bytes,
        filename: archivo.name,
        contentType: DioMediaType.parse(_obtenerTipoContenido(archivo)),
      ),
    });

    await _clienteApi.dio.post<Map<String, dynamic>>(
      '/pacientes/$pacienteId/foto',
      data: formulario,
    );
  }

  String _obtenerTipoContenido(XFile archivo) {
    final tipoInformado = archivo.mimeType?.toLowerCase();

    if (tipoInformado == 'image/jpeg' ||
        tipoInformado == 'image/png' ||
        tipoInformado == 'image/webp') {
      return tipoInformado!;
    }

    final nombre = archivo.name.toLowerCase();
    if (nombre.endsWith('.png')) {
      return 'image/png';
    }

    if (nombre.endsWith('.webp')) {
      return 'image/webp';
    }

    return 'image/jpeg';
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
