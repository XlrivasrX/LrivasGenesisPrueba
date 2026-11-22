import 'package:dio/dio.dart';
import 'package:vetruta_movil/core/red/cliente_api.dart';
import 'package:vetruta_movil/core/red/excepcion_api.dart';
import 'package:vetruta_movil/modulos/usuarios/datos/modelos/usuario_administracion.dart';

class UsuarioAdministracionServicio {
  UsuarioAdministracionServicio(this._clienteApi);

  final ClienteApi _clienteApi;

  Future<List<UsuarioAdministracion>> obtenerUsuarios() async {
    try {
      final respuesta = await _clienteApi.dio.get<List<dynamic>>('/usuarios');
      final datos = respuesta.data;
      if (datos == null) {
        throw const ExcepcionApi('La respuesta del servidor no es válida.');
      }

      return datos
          .map(
            (elemento) => UsuarioAdministracion.fromJson(
              Map<String, dynamic>.from(elemento as Map),
            ),
          )
          .toList();
    } on DioException catch (excepcion) {
      throw _convertirExcepcion(excepcion);
    }
  }

  Future<List<RolAdministracion>> obtenerRoles() async {
    try {
      final respuesta = await _clienteApi.dio.get<List<dynamic>>('/roles');
      final datos = respuesta.data;
      if (datos == null) {
        throw const ExcepcionApi('La respuesta del servidor no es válida.');
      }

      return datos
          .map(
            (elemento) => RolAdministracion.fromJson(
              Map<String, dynamic>.from(elemento as Map),
            ),
          )
          .toList();
    } on DioException catch (excepcion) {
      throw _convertirExcepcion(excepcion);
    }
  }

  Future<void> crearUsuario({
    required int rolId,
    required String nombreUsuario,
    required String contrasenaTemporal,
    required String nombres,
    required String apellidos,
    String? correo,
    String? telefono,
  }) async {
    try {
      await _clienteApi.dio.post<Map<String, dynamic>>(
        '/usuarios',
        data: {
          'rolId': rolId,
          'nombreUsuario': nombreUsuario.trim(),
          'contrasenaTemporal': contrasenaTemporal,
          'nombres': nombres.trim(),
          'apellidos': apellidos.trim(),
          'correo': _textoOpcional(correo),
          'telefono': _textoOpcional(telefono),
        },
      );
    } on DioException catch (excepcion) {
      throw _convertirExcepcion(excepcion);
    }
  }

  Future<void> cambiarEstado(int usuarioId, bool activo) async {
    try {
      await _clienteApi.dio.patch<Map<String, dynamic>>(
        '/usuarios/$usuarioId/estado',
        data: {'activo': activo},
      );
    } on DioException catch (excepcion) {
      throw _convertirExcepcion(excepcion);
    }
  }

  ExcepcionApi _convertirExcepcion(DioException excepcion) {
    final datos = excepcion.response?.data;
    var mensaje = 'No fue posible completar la operación.';

    if (datos is Map && datos['mensaje'] is String) {
      mensaje = datos['mensaje'] as String;
    } else if (excepcion.type == DioExceptionType.connectionError) {
      mensaje = 'No fue posible conectarse con el servidor.';
    }

    return ExcepcionApi(
      mensaje,
      codigoEstado: excepcion.response?.statusCode,
    );
  }

  String? _textoOpcional(String? texto) {
    final valor = texto?.trim();
    return valor == null || valor.isEmpty ? null : valor;
  }
}
