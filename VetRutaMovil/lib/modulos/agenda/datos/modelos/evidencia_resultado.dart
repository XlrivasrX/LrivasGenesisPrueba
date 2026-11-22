class EvidenciaResultado {
  const EvidenciaResultado({
    required this.evidenciaVisitaId,
    required this.mensaje,
  });

  final int evidenciaVisitaId;
  final String mensaje;

  factory EvidenciaResultado.fromJson(Map<String, dynamic> json) {
    return EvidenciaResultado(
      evidenciaVisitaId: json['evidenciaVisitaId'] as int,
      mensaje: json['mensaje'] as String? ??
          'Evidencia registrada correctamente.',
    );
  }
}