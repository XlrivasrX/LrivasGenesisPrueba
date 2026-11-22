class ConfiguracionApi {
  ConfiguracionApi._();

  static const String urlBase = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://127.0.0.1:5172',
  );

  static const Duration tiempoConexion = Duration(seconds: 15);
  static const Duration tiempoRespuesta = Duration(seconds: 30);
}