import 'package:flutter/foundation.dart';
import 'package:vetruta_movil/core/red/excepcion_api.dart';
import 'package:vetruta_movil/modulos/usuarios/datos/modelos/usuario_administracion.dart';
import 'package:vetruta_movil/modulos/usuarios/datos/servicios/usuario_administracion_servicio.dart';

class UsuariosControlador extends ChangeNotifier {
  UsuariosControlador(this._servicio);

  final UsuarioAdministracionServicio _servicio;

  List<UsuarioAdministracion> _usuarios = [];
  List<RolAdministracion> _roles = [];
  bool _cargando = false;
  int? _usuarioActualizandoId;
  String? _mensajeError;

  List<UsuarioAdministracion> get usuarios => _usuarios;
  List<RolAdministracion> get roles => _roles;
  bool get cargando => _cargando;
  int? get usuarioActualizandoId => _usuarioActualizandoId;
  String? get mensajeError => _mensajeError;

  Future<void> cargar() async {
    _cargando = true;
    _mensajeError = null;
    notifyListeners();

    try {
      final usuariosFuturos = _servicio.obtenerUsuarios();
      final rolesFuturos = _servicio.obtenerRoles();
      _usuarios = await usuariosFuturos;
      _roles = (await rolesFuturos)
          .where((rol) => rol.codigo.toUpperCase() != 'ROOT')
          .toList();
      _usuarios.sort(
        (primero, segundo) =>
            primero.nombreCompleto.compareTo(segundo.nombreCompleto),
      );
    } on ExcepcionApi catch (excepcion) {
      _mensajeError = excepcion.mensaje;
    } catch (_) {
      _mensajeError = 'No fue posible cargar los usuarios.';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<bool> crearUsuario({
    required int? rolId,
    required String nombreUsuario,
    required String contrasenaTemporal,
    required String nombres,
    required String apellidos,
    String? correo,
    String? telefono,
  }) async {
    if (rolId == null ||
        nombreUsuario.trim().isEmpty ||
        nombres.trim().isEmpty ||
        apellidos.trim().isEmpty ||
        contrasenaTemporal.length < 8) {
      _mensajeError =
          'Completa los campos requeridos y usa una contraseña de 8 caracteres.';
      notifyListeners();
      return false;
    }

    _cargando = true;
    _mensajeError = null;
    notifyListeners();

    try {
      await _servicio.crearUsuario(
        rolId: rolId,
        nombreUsuario: nombreUsuario,
        contrasenaTemporal: contrasenaTemporal,
        nombres: nombres,
        apellidos: apellidos,
        correo: correo,
        telefono: telefono,
      );
      await cargar();
      return true;
    } on ExcepcionApi catch (excepcion) {
      _mensajeError = excepcion.mensaje;
      return false;
    } catch (_) {
      _mensajeError = 'No fue posible crear el usuario.';
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<bool> cambiarEstado(UsuarioAdministracion usuario) async {
    _usuarioActualizandoId = usuario.usuarioId;
    _mensajeError = null;
    notifyListeners();

    try {
      await _servicio.cambiarEstado(usuario.usuarioId, !usuario.activo);
      await cargar();
      return true;
    } on ExcepcionApi catch (excepcion) {
      _mensajeError = excepcion.mensaje;
      return false;
    } catch (_) {
      _mensajeError = 'No fue posible cambiar el estado del usuario.';
      return false;
    } finally {
      _usuarioActualizandoId = null;
      notifyListeners();
    }
  }
}
