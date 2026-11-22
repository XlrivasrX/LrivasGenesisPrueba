class EvidenciaVisita {
  const EvidenciaVisita({
    required this.evidenciaVisitaId,
    required this.registroVisitaId,
    required this.visitaId,
    required this.nombreArchivo,
    required this.rutaArchivo,
    required this.tipoContenido,
    required this.fechaCreacion,
    this.fechaCaptura,
  });

  final int evidenciaVisitaId;
  final int registroVisitaId;
  final int visitaId;
  final String nombreArchivo;
  final String rutaArchivo;
  final String tipoContenido;
  final DateTime? fechaCaptura;
  final DateTime fechaCreacion;

  factory EvidenciaVisita.fromJson(Map<String, dynamic> json) {
    return EvidenciaVisita(
      evidenciaVisitaId: json['evidenciaVisitaId'] as int,
      registroVisitaId: json['registroVisitaId'] as int,
      visitaId: json['visitaId'] as int,
      nombreArchivo: json['nombreArchivo'] as String? ?? '',
      rutaArchivo: json['rutaArchivo'] as String? ?? '',
      tipoContenido: json['tipoContenido'] as String? ?? '',
      fechaCaptura: json['fechaCaptura'] == null
          ? null
          : DateTime.parse(json['fechaCaptura'] as String),
      fechaCreacion: DateTime.parse(json['fechaCreacion'] as String),
    );
  }
}