import 'package:flutter/foundation.dart';
import 'package:vetruta_movil/core/red/excepcion_api.dart';
import 'package:vetruta_movil/modulos/jerarquia/datos/modelos/usuario_jerarquia.dart';
import 'package:vetruta_movil/modulos/jerarquia/datos/servicios/jerarquia_servicio.dart';

class JerarquiaControlador extends ChangeNotifier {
  JerarquiaControlador(this._servicio);

  final JerarquiaServicio _servicio;

  List<UsuarioJerarquia> _medicos = [];
  List<UsuarioJerarquia> _tecnicos = [];
  List<TecnicoAsignado> _tecnicosAsignados = [];
  int? _medicoSeleccionadoId;
  int? _tecnicoSeleccionadoId;
  bool _cargando = false;
  bool _guardando = false;
  String? _mensajeError;
  String? _mensajeExito;

  List<UsuarioJerarquia> get medicos => _medicos;
  List<UsuarioJerarquia> get tecnicos => _tecnicos;
  List<TecnicoAsignado> get tecnicosAsignados => _tecnicosAsignados;

  int? get medicoSeleccionadoId => _medicoSeleccionadoId;
  int? get tecnicoSeleccionadoId => _tecnicoSeleccionadoId;
  bool get cargando => _cargando;
  bool get guardando => _guardando;
  String? get mensajeError => _mensajeError;
  String? get mensajeExito => _mensajeExito;

  Future<void> cargar() async {
    _cargando = true;
    _mensajeError = null;
    _mensajeExito = null;
    notifyListeners();

    try {
      final usuarios = await _servicio.obtenerUsuariosActivos();

      _medicos =
          usuarios.where((usuario) => usuario.codigoRol == 'MEDICO').toList()
            ..sort(
              (primero, segundo) =>
                  primero.nombreCompleto.compareTo(segundo.nombreCompleto),
            );

      _tecnicos =
          usuarios.where((usuario) => usuario.codigoRol == 'TECNICO').toList()
            ..sort(
              (primero, segundo) =>
                  primero.nombreCompleto.compareTo(segundo.nombreCompleto),
            );

      if (_medicos.isNotEmpty) {
        _medicoSeleccionadoId ??= _medicos.first.usuarioId;

        _tecnicosAsignados = await _servicio.obtenerTecnicosMedico(
          _medicoSeleccionadoId!,
        );
      }
    } on ExcepcionApi catch (excepcion) {
      _mensajeError = excepcion.mensaje;
    } catch (_) {
      _mensajeError = 'No fue posible cargar la jerarquía.';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> seleccionarMedico(int? medicoUsuarioId) async {
    if (medicoUsuarioId == null || medicoUsuarioId == _medicoSeleccionadoId) {
      return;
    }

    _medicoSeleccionadoId = medicoUsuarioId;
    _tecnicosAsignados = [];
    _mensajeError = null;
    _mensajeExito = null;
    _cargando = true;
    notifyListeners();

    try {
      _tecnicosAsignados = await _servicio.obtenerTecnicosMedico(
        medicoUsuarioId,
      );
    } on ExcepcionApi catch (excepcion) {
      _mensajeError = excepcion.mensaje;
    } catch (_) {
      _mensajeError = 'No fue posible cargar los técnicos asignados.';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  void seleccionarTecnico(int? tecnicoUsuarioId) {
    _tecnicoSeleccionadoId = tecnicoUsuarioId;
    _mensajeError = null;
    _mensajeExito = null;
    notifyListeners();
  }

  Future<bool> asignarTecnico() async {
    final medicoUsuarioId = _medicoSeleccionadoId;
    final tecnicoUsuarioId = _tecnicoSeleccionadoId;

    if (medicoUsuarioId == null) {
      _mensajeError = 'Selecciona un médico.';
      notifyListeners();
      return false;
    }

    if (tecnicoUsuarioId == null) {
      _mensajeError = 'Selecciona un técnico.';
      notifyListeners();
      return false;
    }

    _guardando = true;
    _mensajeError = null;
    _mensajeExito = null;
    notifyListeners();

    try {
      await _servicio.asignarTecnico(
        medicoUsuarioId: medicoUsuarioId,
        tecnicoUsuarioId: tecnicoUsuarioId,
      );

      _tecnicosAsignados = await _servicio.obtenerTecnicosMedico(
        medicoUsuarioId,
      );

      _tecnicoSeleccionadoId = null;
      _mensajeExito = 'Técnico asignado correctamente.';
      return true;
    } on ExcepcionApi catch (excepcion) {
      _mensajeError = excepcion.mensaje;
      return false;
    } catch (_) {
      _mensajeError = 'No fue posible asignar el técnico.';
      return false;
    } finally {
      _guardando = false;
      notifyListeners();
    }
  }

  void limpiarMensajes() {
    _mensajeError = null;
    _mensajeExito = null;
    notifyListeners();
  }
}
