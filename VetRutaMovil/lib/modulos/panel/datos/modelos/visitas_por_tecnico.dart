class VisitasPorTecnico {
  const VisitasPorTecnico({
    required this.tecnicoUsuarioId,
    required this.nombreTecnico,
    required this.cantidadVisitas,
    required this.completadas,
    required this.programadas,
  });

  final int tecnicoUsuarioId;
  final String nombreTecnico;
  final int cantidadVisitas;
  final int completadas;
  final int programadas;

  factory VisitasPorTecnico.fromJson(Map<String, dynamic> json) {
    return VisitasPorTecnico(
      tecnicoUsuarioId: (json['tecnicoUsuarioId'] as num?)?.toInt() ?? 0,
      nombreTecnico: json['nombreTecnico'] as String? ?? '',
      cantidadVisitas: (json['cantidadVisitas'] as num?)?.toInt() ?? 0,
      completadas: (json['completadas'] as num?)?.toInt() ?? 0,
      programadas: (json['programadas'] as num?)?.toInt() ?? 0,
    );
  }
}