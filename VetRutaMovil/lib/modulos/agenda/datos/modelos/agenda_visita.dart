class AgendaVisita {
  const AgendaVisita({
    required this.visitaId,
    required this.fechaProgramada,
    required this.estado,
    required this.pacienteId,
    required this.nombrePaciente,
    required this.nombreEspecie,
    required this.nombreRaza,
    required this.propietarioId,
    required this.nombrePropietario,
    required this.telefonoPropietario,
    required this.direccion,
    required this.latitud,
    required this.longitud,
    required this.servicioId,
    required this.nombreServicio,
    required this.precioProgramado,
    required this.medicoResponsableUsuarioId,
    required this.nombreMedico,
    required this.tecnicoUsuarioId,
    required this.nombreTecnico,
  });

  final int visitaId;
  final DateTime fechaProgramada;
  final String estado;
  final int pacienteId;
  final String nombrePaciente;
  final String nombreEspecie;
  final String nombreRaza;
  final int propietarioId;
  final String nombrePropietario;
  final String telefonoPropietario;
  final String direccion;
  final double? latitud;
  final double? longitud;
  final int servicioId;
  final String nombreServicio;
  final double precioProgramado;
  final int medicoResponsableUsuarioId;
  final String nombreMedico;
  final int tecnicoUsuarioId;
  final String nombreTecnico;

  bool get completada => estado.toUpperCase() == 'COMPLETADA';

  bool get atrasada {
    return !completada && fechaProgramada.isBefore(DateTime.now());
  }

  factory AgendaVisita.fromJson(Map<String, dynamic> json) {
    return AgendaVisita(
      visitaId: (json['visitaId'] as num?)?.toInt() ?? 0,
      fechaProgramada: DateTime.tryParse(
            json['fechaProgramada'] as String? ?? '',
          ) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      estado: json['estado'] as String? ?? '',
      pacienteId: (json['pacienteId'] as num?)?.toInt() ?? 0,
      nombrePaciente: json['nombrePaciente'] as String? ?? '',
      nombreEspecie: json['nombreEspecie'] as String? ?? '',
      nombreRaza: json['nombreRaza'] as String? ?? '',
      propietarioId: (json['propietarioId'] as num?)?.toInt() ?? 0,
      nombrePropietario: json['nombrePropietario'] as String? ?? '',
      telefonoPropietario: json['telefonoPropietario'] as String? ?? '',
      direccion: json['direccion'] as String? ?? '',
      latitud: (json['latitud'] as num?)?.toDouble(),
      longitud: (json['longitud'] as num?)?.toDouble(),
      servicioId: (json['servicioId'] as num?)?.toInt() ?? 0,
      nombreServicio: json['nombreServicio'] as String? ?? '',
      precioProgramado: (json['precioProgramado'] as num?)?.toDouble() ?? 0,
      medicoResponsableUsuarioId:
          (json['medicoResponsableUsuarioId'] as num?)?.toInt() ?? 0,
      nombreMedico: json['nombreMedico'] as String? ?? '',
      tecnicoUsuarioId:
          (json['tecnicoUsuarioId'] as num?)?.toInt() ?? 0,
      nombreTecnico: json['nombreTecnico'] as String? ?? '',
    );
  }
}