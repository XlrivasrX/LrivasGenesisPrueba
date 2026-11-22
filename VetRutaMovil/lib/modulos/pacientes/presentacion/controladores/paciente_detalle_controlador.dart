import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vetruta_movil/core/red/excepcion_api.dart';
import 'package:vetruta_movil/modulos/pacientes/datos/modelos/historial_clinico.dart';
import 'package:vetruta_movil/modulos/pacientes/datos/modelos/paciente_detalle.dart';
import 'package:vetruta_movil/modulos/pacientes/datos/servicios/paciente_servicio.dart';

class PacienteDetalleControlador extends ChangeNotifier {
  PacienteDetalleControlador(this._servicio);

  final PacienteServicio _servicio;

  PacienteDetalle? _paciente;
  Uint8List? _fotoPaciente;
  List<HistorialClinico> _historial = [];
  bool _cargando = false;
  bool _actualizandoUbicacion = false;
  String? _mensajeError;
  String? _mensajeUbicacion;

  PacienteDetalle? get paciente => _paciente;
  Uint8List? get fotoPaciente => _fotoPaciente;
  List<HistorialClinico> get historial => _historial;
  bool get cargando => _cargando;
  bool get actualizandoUbicacion => _actualizandoUbicacion;
  String? get mensajeError => _mensajeError;
  String? get mensajeUbicacion => _mensajeUbicacion;

  Future<void> cargarDetalle(int pacienteId) async {
    _cargando = true;
    _paciente = null;
    _fotoPaciente = null;
    _historial = [];
    _mensajeError = null;
    notifyListeners();

    try {
      _paciente = await _servicio.obtenerDetalle(pacienteId);

      if (_paciente?.rutaFoto?.trim().isNotEmpty ?? false) {
        try {
          _fotoPaciente = await _servicio.obtenerFoto(pacienteId);
        } catch (_) {
          // El resto del expediente puede mostrarse sin la fotografía.
        }
      }

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

  Future<bool> actualizarUbicacion() async {
    final pacienteActual = _paciente;
    if (pacienteActual == null || _actualizandoUbicacion) {
      return false;
    }

    _actualizandoUbicacion = true;
    _mensajeUbicacion = null;
    notifyListeners();

    try {
      final servicioHabilitado = await Geolocator.isLocationServiceEnabled();

      if (!servicioHabilitado) {
        _mensajeUbicacion = 'Activa la ubicación del dispositivo.';
        return false;
      }

      var permiso = await Geolocator.checkPermission();

      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }

      if (permiso == LocationPermission.denied) {
        _mensajeUbicacion = 'Debes permitir el acceso a la ubicación.';
        return false;
      }

      if (permiso == LocationPermission.deniedForever) {
        _mensajeUbicacion =
            'El permiso está bloqueado. Habilítalo desde la configuración.';
        return false;
      }

      final posicion = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );

      await _servicio.actualizarUbicacionPropietario(
        propietarioId: pacienteActual.propietarioId,
        latitud: posicion.latitude,
        longitud: posicion.longitude,
      );

      _mensajeUbicacion = 'Ubicación actualizada correctamente.';
      await cargarDetalle(pacienteActual.pacienteId);
      return true;
    } on TimeoutException {
      _mensajeUbicacion = 'No fue posible obtener la ubicación a tiempo.';
      return false;
    } on ExcepcionApi catch (excepcion) {
      _mensajeUbicacion = excepcion.mensaje;
      return false;
    } catch (_) {
      _mensajeUbicacion = 'No fue posible actualizar la ubicación.';
      return false;
    } finally {
      _actualizandoUbicacion = false;
      notifyListeners();
    }
  }
}
