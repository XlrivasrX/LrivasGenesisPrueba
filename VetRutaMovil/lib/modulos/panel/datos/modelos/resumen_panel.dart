class ResumenPanel {
  const ResumenPanel({
    required this.propietariosActivos,
    required this.pacientesActivos,
    required this.visitasProgramadas,
    required this.visitasCompletadas,
    required this.visitasDeHoy,
  });

  final int propietariosActivos;
  final int pacientesActivos;
  final int visitasProgramadas;
  final int visitasCompletadas;
  final int visitasDeHoy;

  factory ResumenPanel.fromJson(Map<String, dynamic> json) {
    return ResumenPanel(
      propietariosActivos: (json['propietariosActivos'] as num?)?.toInt() ?? 0,
      pacientesActivos: (json['pacientesActivos'] as num?)?.toInt() ?? 0,
      visitasProgramadas: (json['visitasProgramadas'] as num?)?.toInt() ?? 0,
      visitasCompletadas: (json['visitasCompletadas'] as num?)?.toInt() ?? 0,
      visitasDeHoy: (json['visitasDeHoy'] as num?)?.toInt() ?? 0,
    );
  }
}