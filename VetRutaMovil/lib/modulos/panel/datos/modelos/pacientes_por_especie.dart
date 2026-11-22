class PacientesPorEspecie {
  const PacientesPorEspecie({
    required this.especieId,
    required this.nombreEspecie,
    required this.cantidadPacientes,
  });

  final int especieId;
  final String nombreEspecie;
  final int cantidadPacientes;

  factory PacientesPorEspecie.fromJson(Map<String, dynamic> json) {
    return PacientesPorEspecie(
      especieId: (json['especieId'] as num?)?.toInt() ?? 0,
      nombreEspecie: json['nombreEspecie'] as String? ?? '',
      cantidadPacientes: (json['cantidadPacientes'] as num?)?.toInt() ?? 0,
    );
  }
}
