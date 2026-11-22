import 'package:flutter/foundation.dart';
import 'package:vetruta_movil/core/red/excepcion_api.dart';
import 'package:vetruta_movil/modulos/agenda/datos/modelos/agenda_visita.dart';
import 'package:vetruta_movil/modulos/agenda/datos/servicios/agenda_servicio.dart';

class AgendaControlador extends ChangeNotifier {
  AgendaControlador(this._servicio)
      : _fechaSeleccionada = _soloFecha(DateTime.now());

  final AgendaServicio _servicio;

  List<AgendaVisita> _visitas = const [];
  DateTime _fechaSeleccionada;
  bool _cargando = false;
  String? _mensajeError;

  List<AgendaVisita> get visitas => _visitas;
  DateTime get fechaSeleccionada => _fechaSeleccionada;
  bool get cargando => _cargando;
  String? get mensajeError => _mensajeError;

  List<DateTime> get fechasSemana {
    final inicio = _inicioSemana(_fechaSeleccionada);

    return List.generate(
      7,
      (indice) => inicio.add(Duration(days: indice)),
    );
  }

  List<AgendaVisita> get visitasSeleccionadas {
    return _visitas.where((visita) {
      return _mismaFecha(
        visita.fechaProgramada,
        _fechaSeleccionada,
      );
    }).toList();
  }

  Future<void> cargarAgenda() async {
    if (_cargando) {
      return;
    }

    _cargando = true;
    _mensajeError = null;
    notifyListeners();

    try {
      final inicio = _inicioSemana(_fechaSeleccionada);
      final fin = inicio.add(const Duration(days: 6));

      _visitas = await _servicio.obtenerAgenda(
        fechaDesde: inicio,
        fechaHasta: fin,
      );
    } on ExcepcionApi catch (excepcion) {
      _mensajeError = excepcion.mensaje;
    } catch (_) {
      _mensajeError = 'Ocurrió un error inesperado al cargar la agenda.';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  void seleccionarFecha(DateTime fecha) {
    _fechaSeleccionada = _soloFecha(fecha);
    notifyListeners();
  }

  static DateTime _inicioSemana(DateTime fecha) {
    final soloFecha = _soloFecha(fecha);

    return soloFecha.subtract(
      Duration(days: soloFecha.weekday - DateTime.monday),
    );
  }

  static DateTime _soloFecha(DateTime fecha) {
    return DateTime(fecha.year, fecha.month, fecha.day);
  }

  static bool _mismaFecha(DateTime primera, DateTime segunda) {
    return primera.year == segunda.year &&
        primera.month == segunda.month &&
        primera.day == segunda.day;
  }
}