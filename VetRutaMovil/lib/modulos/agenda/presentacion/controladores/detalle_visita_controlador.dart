import 'package:flutter/foundation.dart';
import 'package:vetruta_movil/core/red/excepcion_api.dart';
import 'package:vetruta_movil/modulos/agenda/datos/modelos/detalle_visita.dart';
import 'package:vetruta_movil/modulos/agenda/datos/modelos/evidencia_visita.dart';
import 'package:vetruta_movil/modulos/agenda/datos/servicios/agenda_servicio.dart';

class DetalleVisitaControlador extends ChangeNotifier {
  DetalleVisitaControlador(this._servicio);

  final AgendaServicio _servicio;

  DetalleVisita? _detalle;
  List<EvidenciaVisita> _evidencias = [];
  Map<int, Uint8List> _archivosEvidencia = {};
  bool _cargando = false;
  String? _mensajeError;

  DetalleVisita? get detalle => _detalle;
  List<EvidenciaVisita> get evidencias => _evidencias;
  Map<int, Uint8List> get archivosEvidencia => _archivosEvidencia;
  bool get cargando => _cargando;
  String? get mensajeError => _mensajeError;

  Future<void> cargarDetalle(int visitaId) async {
    _cargando = true;
    _detalle = null;
    _evidencias = [];
    _archivosEvidencia = {};
    _mensajeError = null;
    notifyListeners();

    try {
      _detalle = await _servicio.obtenerDetalle(visitaId);
      _evidencias = await _servicio.obtenerEvidencias(visitaId);

      for (final evidencia in _evidencias) {
        try {
          _archivosEvidencia[evidencia.evidenciaVisitaId] = await _servicio
              .obtenerArchivoEvidencia(
                visitaId,
                evidencia.evidenciaVisitaId,
              );
        } catch (_) {
          // El detalle puede mostrarse aunque una fotografía no esté disponible.
        }
      }
    } on ExcepcionApi catch (excepcion) {
      _mensajeError = excepcion.mensaje;
    } catch (_) {
      _mensajeError = 'No fue posible cargar el detalle de la visita.';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }
}
