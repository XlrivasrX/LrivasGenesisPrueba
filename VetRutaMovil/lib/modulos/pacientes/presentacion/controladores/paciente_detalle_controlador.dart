import 'package:flutter/foundation.dart';
import 'package:vetruta_movil/core/red/excepcion_api.dart';
import 'package:vetruta_movil/modulos/pacientes/datos/modelos/historial_clinico.dart';
import 'package:vetruta_movil/modulos/pacientes/datos/modelos/paciente_detalle.dart';
import 'package:vetruta_movil/modulos/pacientes/datos/servicios/paciente_servicio.dart';

class PacienteDetalleControlador extends ChangeNotifier {
  PacienteDetalleControlador(this._servicio);

  final PacienteServicio _servicio;

  PacienteDetalle? _paciente;
  List<HistorialClinico> _historial = [];
  bool _cargando = false;
  String? _mensajeError;

  PacienteDetalle? get paciente => _paciente;
  List<HistorialClinico> get historial => _historial;
  bool get cargando => _cargando;
  String? get mensajeError => _mensajeError;

  Future<void> cargarDetalle(int pacienteId) async {
    _cargando = true;
    _paciente = null;
    _historial = [];
    _mensajeError = null;
    notifyListeners();

    try {
      _paciente = await _servicio.obtenerDetalle(pacienteId);
      _historial = await _servicio.obtenerHistorial(pacienteId);
    } on ExcepcionApi catch (excepcion) {
      _mensajeError = excepcion.mensaje;
    } catch (_) {
      _mensajeError = 'No fue posible cargar el detalle del paciente.';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }
}
