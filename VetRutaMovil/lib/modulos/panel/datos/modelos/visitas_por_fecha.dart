class VisitasPorFecha {
  const VisitasPorFecha({
    required this.fecha,
    required this.cantidadVisitas,
    required this.completadas,
    required this.programadas,
    required this.totalProgramado,
  });

  final DateTime fecha;
  final int cantidadVisitas;
  final int completadas;
  final int programadas;
  final double totalProgramado;

  factory VisitasPorFecha.fromJson(Map<String, dynamic> json) {
    return VisitasPorFecha(
      fecha: DateTime.tryParse(json['fecha'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      cantidadVisitas: (json['cantidadVisitas'] as num?)?.toInt() ?? 0,
      completadas: (json['completadas'] as num?)?.toInt() ?? 0,
      programadas: (json['programadas'] as num?)?.toInt() ?? 0,
      totalProgramado: (json['totalProgramado'] as num?)?.toDouble() ?? 0,
    );
  }
}