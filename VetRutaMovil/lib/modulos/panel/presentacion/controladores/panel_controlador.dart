import 'package:flutter/foundation.dart';
import 'package:vetruta_movil/core/red/excepcion_api.dart';
import 'package:vetruta_movil/modulos/panel/datos/modelos/mascotas_atendidas.dart';
import 'package:vetruta_movil/modulos/panel/datos/modelos/resumen_panel.dart';
import 'package:vetruta_movil/modulos/panel/datos/modelos/visitas_por_fecha.dart';
import 'package:vetruta_movil/modulos/panel/datos/modelos/visitas_por_servicio.dart';
import 'package:vetruta_movil/modulos/panel/datos/servicios/panel_servicio.dart';
import 'package:vetruta_movil/modulos/panel/datos/modelos/visitas_por_tecnico.dart';

class PanelControlador extends ChangeNotifier {
  PanelControlador(this._servicio);

  final PanelServicio _servicio;

  ResumenPanel? _resumen;
  List<VisitasPorServicio> _visitasPorServicio = const [];
  List<VisitasPorFecha> _visitasPorFecha = const [];
  List<MascotasAtendidas> _mascotasAtendidas = const [];
  List<VisitasPorTecnico> _visitasPorTecnico = const [];
  bool _cargando = false;
  String? _mensajeError;

  ResumenPanel? get resumen => _resumen;
  List<VisitasPorServicio> get visitasPorServicio => _visitasPorServicio;
  List<VisitasPorFecha> get visitasPorFecha => _visitasPorFecha;
  List<MascotasAtendidas> get mascotasAtendidas => _mascotasAtendidas;
  List<VisitasPorTecnico> get visitasPorTecnico => _visitasPorTecnico;
  bool get cargando => _cargando;
  String? get mensajeError => _mensajeError;

  Future<void> cargarPanel() async {
    if (_cargando) {
      return;
    }

    _cargando = true;
    _mensajeError = null;
    notifyListeners();

    try {
      _resumen = await _servicio.obtenerResumen();
      final servicios = await _servicio.obtenerVisitasPorServicio();

      _visitasPorServicio = servicios
          .where((servicio) => servicio.cantidadVisitas > 0)
          .toList();
      _visitasPorFecha = await _servicio.obtenerVisitasPorFecha();
      _mascotasAtendidas = await _servicio.obtenerMascotasAtendidas();
      _visitasPorTecnico = await _servicio.obtenerVisitasPorTecnico();
    } on ExcepcionApi catch (excepcion) {
      _mensajeError = excepcion.mensaje;
    } catch (_) {
      _mensajeError = 'Ocurrió un error inesperado al cargar el panel.';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }
}
