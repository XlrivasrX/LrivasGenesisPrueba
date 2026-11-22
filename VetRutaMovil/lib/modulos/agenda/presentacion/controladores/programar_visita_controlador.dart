import 'package:flutter/foundation.dart';
import 'package:vetruta_movil/core/red/excepcion_api.dart';
import 'package:vetruta_movil/modulos/agenda/datos/modelos/opciones_programacion.dart';
import 'package:vetruta_movil/modulos/agenda/datos/servicios/agenda_servicio.dart';

class ProgramarVisitaControlador extends ChangeNotifier {
  ProgramarVisitaControlador(this._servicio);

  final AgendaServicio _servicio;

  List<PacienteProgramacion> _pacientes = [];
  List<ServicioProgramacion> _servicios = [];
  int? _pacienteId;
  int? _servicioId;
  bool _cargando = false;
  bool _guardando = false;
  String? _mensajeError;

  List<PacienteProgramacion> get pacientes => _pacientes;
  List<ServicioProgramacion> get servicios => _servicios;
  int? get pacienteId => _pacienteId;
  int? get servicioId => _servicioId;
  bool get cargando => _cargando;
  bool get guardando => _guardando;
  String? get mensajeError => _mensajeError;

  PacienteProgramacion? get pacienteSeleccionado {
    return _buscarPaciente(_pacienteId);
  }

  ServicioProgramacion? get servicioSeleccionado {
    return _buscarServicio(_servicioId);
  }

  Future<void> cargarOpciones() async {
    _cargando = true;
    _mensajeError = null;
    notifyListeners();

    try {
      final resultados = await Future.wait([
        _servicio.obtenerPacientesProgramacion(),
        _servicio.obtenerServiciosProgramacion(),
      ]);

      _pacientes = resultados[0] as List<PacienteProgramacion>;
      _servicios = resultados[1] as List<ServicioProgramacion>;
      _pacientes.sort(
        (primero, segundo) =>
            primero.nombrePaciente.compareTo(segundo.nombrePaciente),
      );
      _servicios.sort(
        (primero, segundo) => primero.nombre.compareTo(segundo.nombre),
      );

      if (_pacientes.isNotEmpty) {
        _pacienteId = _pacientes.first.pacienteId;
      }
      if (_servicios.isNotEmpty) {
        _servicioId = _servicios.first.servicioId;
      }
    } on ExcepcionApi catch (excepcion) {
      _mensajeError = excepcion.mensaje;
    } catch (_) {
      _mensajeError = 'No fue posible cargar los datos de programación.';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  void seleccionarPaciente(int? pacienteId) {
    _pacienteId = pacienteId;
  }

  void seleccionarServicio(int? servicioId) {
    _servicioId = servicioId;
  }

  Future<bool> programar({
    required DateTime fechaProgramada,
    required String precio,
    String? observaciones,
  }) async {
    final paciente = pacienteSeleccionado;
    final servicio = servicioSeleccionado;
    final precioNumero = double.tryParse(precio.replaceAll(',', '.').trim());

    if (paciente == null || servicio == null) {
      _mostrarError('Selecciona el paciente y el servicio.');
      return false;
    }
    if (!fechaProgramada.isAfter(DateTime.now())) {
      _mostrarError('La fecha y hora deben ser posteriores a la actual.');
      return false;
    }
    if (precioNumero == null || precioNumero < 0) {
      _mostrarError('Ingresa un precio válido.');
      return false;
    }

    _guardando = true;
    _mensajeError = null;
    notifyListeners();

    try {
      await _servicio.programarVisita(
        paciente: paciente,
        servicio: servicio,
        fechaProgramada: fechaProgramada,
        precioProgramado: precioNumero,
        observaciones: observaciones,
      );
      return true;
    } on ExcepcionApi catch (excepcion) {
      _mensajeError = excepcion.mensaje;
      return false;
    } catch (_) {
      _mensajeError = 'No fue posible programar la visita.';
      return false;
    } finally {
      _guardando = false;
      notifyListeners();
    }
  }

  PacienteProgramacion? _buscarPaciente(int? id) {
    for (final paciente in _pacientes) {
      if (paciente.pacienteId == id) {
        return paciente;
      }
    }
    return null;
  }

  ServicioProgramacion? _buscarServicio(int? id) {
    for (final servicio in _servicios) {
      if (servicio.servicioId == id) {
        return servicio;
      }
    }
    return null;
  }

  void _mostrarError(String mensaje) {
    _mensajeError = mensaje;
    notifyListeners();
  }
}
