import 'package:flutter/foundation.dart';
import 'package:vetruta_movil/core/red/excepcion_api.dart';
import 'package:vetruta_movil/modulos/autenticacion/datos/modelos/usuario_sesion.dart';
import 'package:vetruta_movil/modulos/autenticacion/datos/servicios/autenticacion_servicio.dart';

class AutenticacionControlador extends ChangeNotifier {
  AutenticacionControlador(this._servicio);

  final AutenticacionServicio _servicio;

  UsuarioSesion? _usuario;
  bool _cargando = false;
  String? _mensajeError;

  UsuarioSesion? get usuario => _usuario;
  bool get cargando => _cargando;
  String? get mensajeError => _mensajeError;
  bool get autenticado => _usuario != null;

  Future<bool> iniciarSesion(String nombreUsuario, String contrasena) async {
    _cargando = true;
    _mensajeError = null;
    notifyListeners();

    try {
      final sesion = await _servicio.iniciarSesion(
        nombreUsuario,
        contrasena,
      );

      _usuario = sesion.usuario;
      return true;
    } on ExcepcionApi catch (excepcion) {
      _mensajeError = excepcion.mensaje;
      return false;
    } catch (_) {
      _mensajeError = 'Ocurrió un error inesperado.';
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> cerrarSesion() async {
  _cargando = true;
  notifyListeners();

    try {
      await _servicio.cerrarSesion();
    } catch (_) {
    // La sesión local se elimina aunque el servidor no esté disponible.
    } finally {
      _usuario = null;
      _mensajeError = null;
      _cargando = false;
      notifyListeners();
    }
  }

  void limpiarError() {
    _mensajeError = null;
    notifyListeners();
  }
}