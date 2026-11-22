class VisitasPorServicio {
  const VisitasPorServicio({
    required this.servicioId,
    required this.codigo,
    required this.nombreServicio,
    required this.cantidadVisitas,
    required this.completadas,
    required this.programadas,
    required this.totalProgramado,
  });

  final int servicioId;
  final String codigo;
  final String nombreServicio;
  final int cantidadVisitas;
  final int completadas;
  final int programadas;
  final double totalProgramado;

  factory VisitasPorServicio.fromJson(Map<String, dynamic> json) {
    return VisitasPorServicio(
      servicioId: (json['servicioId'] as num?)?.toInt() ?? 0,
      codigo: json['codigo'] as String? ?? '',
      nombreServicio: json['nombreServicio'] as String? ?? '',
      cantidadVisitas: (json['cantidadVisitas'] as num?)?.toInt() ?? 0,
      completadas: (json['completadas'] as num?)?.toInt() ?? 0,
      programadas: (json['programadas'] as num?)?.toInt() ?? 0,
      totalProgramado: (json['totalProgramado'] as num?)?.toDouble() ?? 0,
    );
  }
}