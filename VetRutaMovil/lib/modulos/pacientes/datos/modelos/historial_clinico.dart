class HistorialClinico {
  const HistorialClinico({
    required this.registroVisitaId,
    required this.visitaId,
    required this.pacienteId,
    required this.nombrePaciente,
    required this.fechaProgramada,
    required this.fechaRegistro,
    required this.servicioId,
    required this.nombreServicio,
    required this.precioProgramado,
    required this.medicoResponsableUsuarioId,
    required this.nombreMedico,
    required this.tecnicoUsuarioId,
    required this.nombreTecnico,
    required this.latitud,
    required this.longitud,
    required this.registradoPorUsuarioId,
    required this.registradoPor,
    required this.cantidadEvidencias,
    this.pesoKg,
    this.alturaCm,
    this.temperaturaCelsius,
    this.condicionCorporal,
    this.observaciones,
  });

  final int registroVisitaId;
  final int visitaId;
  final int pacienteId;
  final String nombrePaciente;
  final DateTime fechaProgramada;
  final DateTime fechaRegistro;
  final int servicioId;
  final String nombreServicio;
  final double precioProgramado;
  final int medicoResponsableUsuarioId;
  final String nombreMedico;
  final int tecnicoUsuarioId;
  final String nombreTecnico;
  final double? pesoKg;
  final double? alturaCm;
  final double? temperaturaCelsius;
  final String? condicionCorporal;
  final String? observaciones;
  final double latitud;
  final double longitud;
  final int registradoPorUsuarioId;
  final String registradoPor;
  final int cantidadEvidencias;

  factory HistorialClinico.fromJson(Map<String, dynamic> json) {
    return HistorialClinico(
      registroVisitaId: json['registroVisitaId'] as int,
      visitaId: json['visitaId'] as int,
      pacienteId: json['pacienteId'] as int,
      nombrePaciente: json['nombrePaciente'] as String? ?? '',
      fechaProgramada: DateTime.parse(
        json['fechaProgramada'] as String,
      ),
      fechaRegistro: DateTime.parse(
        json['fechaRegistro'] as String,
      ),
      servicioId: json['servicioId'] as int,
      nombreServicio: json['nombreServicio'] as String? ?? '',
      precioProgramado:
          (json['precioProgramado'] as num).toDouble(),
      medicoResponsableUsuarioId:
          json['medicoResponsableUsuarioId'] as int,
      nombreMedico: json['nombreMedico'] as String? ?? '',
      tecnicoUsuarioId: json['tecnicoUsuarioId'] as int,
      nombreTecnico: json['nombreTecnico'] as String? ?? '',
      pesoKg: (json['pesoKg'] as num?)?.toDouble(),
      alturaCm: (json['alturaCm'] as num?)?.toDouble(),
      temperaturaCelsius:
          (json['temperaturaCelsius'] as num?)?.toDouble(),
      condicionCorporal: json['condicionCorporal'] as String?,
      observaciones: json['observaciones'] as String?,
      latitud: (json['latitud'] as num).toDouble(),
      longitud: (json['longitud'] as num).toDouble(),
      registradoPorUsuarioId:
          json['registradoPorUsuarioId'] as int,
      registradoPor: json['registradoPor'] as String? ?? '',
      cantidadEvidencias: json['cantidadEvidencias'] as int,
    );
  }
}