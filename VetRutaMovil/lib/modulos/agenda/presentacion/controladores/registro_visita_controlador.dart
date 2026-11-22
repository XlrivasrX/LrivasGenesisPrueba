import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vetruta_movil/core/red/excepcion_api.dart';
import 'package:vetruta_movil/modulos/agenda/datos/modelos/completar_visita_solicitud.dart';
import 'package:vetruta_movil/modulos/agenda/datos/servicios/agenda_servicio.dart';

class RegistroVisitaControlador extends ChangeNotifier {
  RegistroVisitaControlador(this._servicio);

  final AgendaServicio _servicio;
  final ImagePicker _selectorImagen = ImagePicker();

  XFile? _fotografia;
  Position? _posicion;
  bool _tomandoFotografia = false;
  bool _obteniendoUbicacion = false;
  bool _guardando = false;
  bool _visitaCompletada = false;
  String? _mensajeError;
  String? _mensajeExito;

  XFile? get fotografia => _fotografia;
  Position? get posicion => _posicion;
  bool get tomandoFotografia => _tomandoFotografia;
  bool get obteniendoUbicacion => _obteniendoUbicacion;
  bool get guardando => _guardando;
  bool get ubicacionVerificada => _posicion != null;
  bool get fotografiaAgregada => _fotografia != null;
  String? get mensajeError => _mensajeError;
  String? get mensajeExito => _mensajeExito;

  Future<bool> tomarFotografia() async {
    if (_tomandoFotografia) {
      return false;
    }

    _tomandoFotografia = true;
    _mensajeError = null;
    notifyListeners();

    try {
      final fotografia = await _selectorImagen.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1600,
      );

      if (fotografia == null) {
        return false;
      }

      _fotografia = fotografia;
      return true;
    } catch (_) {
      _mensajeError = 'No fue posible tomar la fotografía.';
      return false;
    } finally {
      _tomandoFotografia = false;
      notifyListeners();
    }
  }

  Future<bool> obtenerUbicacion() async {
    if (_obteniendoUbicacion) {
      return false;
    }

    _obteniendoUbicacion = true;
    _mensajeError = null;
    notifyListeners();

    try {
      final servicioHabilitado =
          await Geolocator.isLocationServiceEnabled();

      if (!servicioHabilitado) {
        _mensajeError = 'Activa la ubicación del dispositivo.';
        return false;
      }

      var permiso = await Geolocator.checkPermission();

      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }

      if (permiso == LocationPermission.denied) {
        _mensajeError =
            'Debes permitir el acceso a la ubicación.';
        return false;
      }

      if (permiso == LocationPermission.deniedForever) {
        _mensajeError =
            'El permiso de ubicación está bloqueado. '
            'Habilítalo desde la configuración del dispositivo.';
        return false;
      }

      _posicion = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );

      return true;
    } on TimeoutException {
      _mensajeError =
          'No fue posible obtener la ubicación a tiempo.';
      return false;
    } catch (_) {
      _mensajeError = 'No fue posible obtener la ubicación.';
      return false;
    } finally {
      _obteniendoUbicacion = false;
      notifyListeners();
    }
  }

  Future<bool> registrarVisita({
    required int visitaId,
    double? pesoKg,
    double? alturaCm,
    double? temperaturaCelsius,
    String? condicionCorporal,
    String? observaciones,
  }) async {
    if (_guardando) {
      return false;
    }

    final mensajeValidacion = _validarDatos(
      pesoKg: pesoKg,
      alturaCm: alturaCm,
      temperaturaCelsius: temperaturaCelsius,
      condicionCorporal: condicionCorporal,
      observaciones: observaciones,
    );

    if (mensajeValidacion != null) {
      _mensajeError = mensajeValidacion;
      notifyListeners();
      return false;
    }

    _guardando = true;
    _mensajeError = null;
    _mensajeExito = null;
    notifyListeners();

    try {
      if (!_visitaCompletada) {
        await _servicio.completarVisita(
          visitaId,
          CompletarVisitaSolicitud(
            pesoKg: pesoKg,
            alturaCm: alturaCm,
            temperaturaCelsius: temperaturaCelsius,
            condicionCorporal: condicionCorporal,
            observaciones: observaciones,
            latitud: _posicion!.latitude,
            longitud: _posicion!.longitude,
          ),
        );

        _visitaCompletada = true;
      }

      await _servicio.agregarEvidencia(
        visitaId,
        _fotografia!,
      );

      _mensajeExito =
          'Visita y evidencia registradas correctamente.';
      return true;
    } on ExcepcionApi catch (excepcion) {
      if (_visitaCompletada) {
        _mensajeError =
            'La visita quedó completada, pero no fue posible '
            'subir la fotografía. Intenta nuevamente. '
            '${excepcion.mensaje}';
      } else {
        _mensajeError = excepcion.mensaje;
      }

      return false;
    } catch (_) {
      _mensajeError = _visitaCompletada
          ? 'La visita quedó completada, pero no fue posible '
              'subir la fotografía. Intenta nuevamente.'
          : 'No fue posible registrar la visita.';

      return false;
    } finally {
      _guardando = false;
      notifyListeners();
    }
  }

  String? _validarDatos({
    required double? pesoKg,
    required double? alturaCm,
    required double? temperaturaCelsius,
    required String? condicionCorporal,
    required String? observaciones,
  }) {
    if (_fotografia == null) {
      return 'Debes tomar una fotografía de evidencia.';
    }

    if (_posicion == null) {
      return 'Debes verificar la ubicación de la visita.';
    }

    if (pesoKg != null && pesoKg <= 0) {
      return 'El peso debe ser mayor que cero.';
    }

    if (alturaCm != null && alturaCm <= 0) {
      return 'La altura debe ser mayor que cero.';
    }

    if (temperaturaCelsius != null &&
        (temperaturaCelsius < 0 ||
            temperaturaCelsius > 100)) {
      return 'La temperatura debe estar entre 0 y 100 °C.';
    }

    if ((condicionCorporal?.trim().length ?? 0) > 100) {
      return 'La condición corporal no puede superar '
          'los 100 caracteres.';
    }

    if ((observaciones?.trim().length ?? 0) > 1000) {
      return 'Las observaciones no pueden superar '
          'los 1000 caracteres.';
    }

    return null;
  }

  void limpiarError() {
    _mensajeError = null;
    notifyListeners();
  }
}