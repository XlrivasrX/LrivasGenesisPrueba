import 'package:dio/dio.dart';
import 'package:vetruta_movil/core/almacenamiento/almacenamiento_seguro.dart';
import 'package:vetruta_movil/core/red/configuracion_api.dart';

class ClienteApi {
  ClienteApi(this._almacenamientoSeguro)
      : dio = Dio(
          BaseOptions(
            baseUrl: ConfiguracionApi.urlBase,
            connectTimeout: ConfiguracionApi.tiempoConexion,
            receiveTimeout: ConfiguracionApi.tiempoRespuesta,
            sendTimeout: ConfiguracionApi.tiempoRespuesta,
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (opciones, manejador) async {
          final token = await _almacenamientoSeguro.obtenerTokenAcceso();

          if (token != null && token.isNotEmpty) {
            opciones.headers['Authorization'] = 'Bearer $token';
          }

          manejador.next(opciones);
        },
      ),
    );
  }

  final AlmacenamientoSeguro _almacenamientoSeguro;
  final Dio dio;
}