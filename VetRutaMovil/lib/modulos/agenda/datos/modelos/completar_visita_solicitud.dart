class CompletarVisitaSolicitud {
  const CompletarVisitaSolicitud({
    required this.latitud,
    required this.longitud,
    this.pesoKg,
    this.alturaCm,
    this.temperaturaCelsius,
    this.condicionCorporal,
    this.observaciones,
  });

  final double? pesoKg;
  final double? alturaCm;
  final double? temperaturaCelsius;
  final String? condicionCorporal;
  final String? observaciones;
  final double latitud;
  final double longitud;

  Map<String, dynamic> toJson() {
    return {
      'pesoKg': pesoKg,
      'alturaCm': alturaCm,
      'temperaturaCelsius': temperaturaCelsius,
      'condicionCorporal': _limpiarTexto(condicionCorporal),
      'observaciones': _limpiarTexto(observaciones),
      'latitud': latitud,
      'longitud': longitud,
    };
  }

  String? _limpiarTexto(String? texto) {
    final textoLimpio = texto?.trim();

    if (textoLimpio == null || textoLimpio.isEmpty) {
      return null;
    }

    return textoLimpio;
  }
}