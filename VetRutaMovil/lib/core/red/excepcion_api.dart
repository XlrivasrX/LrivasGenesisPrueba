class ExcepcionApi implements Exception {
  const ExcepcionApi(
    this.mensaje, {
    this.codigoEstado,
  });

  final String mensaje;
  final int? codigoEstado;

  @override
  String toString() => mensaje;
}