class PacienteProgramacion {
  const PacienteProgramacion({
    required this.pacienteId,
    required this.nombrePaciente,
    required this.nombreEspecie,
    required this.nombreRaza,
    required this.nombrePropietario,
    required this.telefonoPropietario,
    required this.tecnicoUsuarioId,
    required this.nombreTecnico,
    required this.asignadoPorUsuarioId,
    required this.nombreMedico,
  });

  final int pacienteId;
  final String nombrePaciente;
  final String nombreEspecie;
  final String nombreRaza;
  final String nombrePropietario;
  final String telefonoPropietario;
  final int tecnicoUsuarioId;
  final String nombreTecnico;
  final int asignadoPorUsuarioId;
  final String nombreMedico;

  factory PacienteProgramacion.fromJson(Map<String, dynamic> json) {
    return PacienteProgramacion(
      pacienteId: (json['pacienteId'] as num?)?.toInt() ?? 0,
      nombrePaciente: json['nombrePaciente'] as String? ?? '',
      nombreEspecie: json['nombreEspecie'] as String? ?? '',
      nombreRaza: json['nombreRaza'] as String? ?? '',
      nombrePropietario: json['nombrePropietario'] as String? ?? '',
      telefonoPropietario: json['telefonoPropietario'] as String? ?? '',
      tecnicoUsuarioId:
          (json['tecnicoUsuarioId'] as num?)?.toInt() ?? 0,
      nombreTecnico: json['nombreTecnico'] as String? ?? '',
      asignadoPorUsuarioId:
          (json['asignadoPorUsuarioId'] as num?)?.toInt() ?? 0,
      nombreMedico: json['nombreMedico'] as String? ?? '',
    );
  }
}

class ServicioProgramacion {
  const ServicioProgramacion({
    required this.servicioId,
    required this.nombre,
    required this.precio,
  });

  final int servicioId;
  final String nombre;
  final double precio;

  factory ServicioProgramacion.fromJson(Map<String, dynamic> json) {
    return ServicioProgramacion(
      servicioId: (json['servicioId'] as num?)?.toInt() ?? 0,
      nombre: json['nombre'] as String? ?? '',
      precio: (json['precio'] as num?)?.toDouble() ?? 0,
    );
  }
}
