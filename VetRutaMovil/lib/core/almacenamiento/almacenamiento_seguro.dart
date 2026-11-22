import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AlmacenamientoSeguro {
  AlmacenamientoSeguro({FlutterSecureStorage? almacenamiento})
      : _almacenamiento = almacenamiento ?? const FlutterSecureStorage();

  static const String _claveTokenAcceso = 'token_acceso';
  static const String _claveTokenActualizacion = 'token_actualizacion';

  final FlutterSecureStorage _almacenamiento;

  Future<void> guardarTokens({
    required String tokenAcceso,
    required String tokenActualizacion,
  }) async {
    await _almacenamiento.write(
      key: _claveTokenAcceso,
      value: tokenAcceso,
    );

    await _almacenamiento.write(
      key: _claveTokenActualizacion,
      value: tokenActualizacion,
    );
  }

  Future<String?> obtenerTokenAcceso() {
    return _almacenamiento.read(key: _claveTokenAcceso);
  }

  Future<String?> obtenerTokenActualizacion() {
    return _almacenamiento.read(key: _claveTokenActualizacion);
  }

  Future<void> eliminarTokens() async {
    await _almacenamiento.delete(key: _claveTokenAcceso);
    await _almacenamiento.delete(key: _claveTokenActualizacion);
  }
}