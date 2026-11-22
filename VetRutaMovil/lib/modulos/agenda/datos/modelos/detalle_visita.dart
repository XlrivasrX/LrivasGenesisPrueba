class DetalleVisita {
  const DetalleVisita({
    required this.visitaId,
    required this.fechaProgramada,
    required this.estado,
    required this.pacienteId,
    required this.nombrePaciente,
    required this.especieId,
    required this.nombreEspecie,
    required this.razaId,
    required this.nombreRaza,
    required this.propietarioId,
    required this.nombrePropietario,
    required this.telefonoPropietario,
    required this.direccion,
    required this.servicioId,
    required this.nombreServicio,
    required this.precioProgramado,
    this.rutaFoto,
    this.fechaNacimientoAproximada,
    this.observacionesPaciente,
    this.telefonoAlternativo,
    this.latitudPropietario,
    this.longitudPropietario,
    this.observacionesProgramacion,
    this.medicoResponsableUsuarioId,
    this.nombreMedico,
    this.tecnicoUsuarioId,
    this.nombreTecnico,
    this.registroVisitaId,
    this.pesoKg,
    this.alturaCm,
    this.temperaturaCelsius,
    this.condicionCorporal,
    this.observacionesAtencion,
    this.latitudAtencion,
    this.longitudAtencion,
    this.fechaRegistro,
  });

  final int visitaId;
  final DateTime fechaProgramada;
  final String estado;

  final int pacienteId;
  final String nombrePaciente;
  final String? rutaFoto;
  final DateTime? fechaNacimientoAproximada;
  final String? observacionesPaciente;

  final int especieId;
  final String nombreEspecie;
  final int razaId;
  final String nombreRaza;

  final int propietarioId;
  final String nombrePropietario;
  final String telefonoPropietario;
  final String? telefonoAlternativo;
  final String direccion;
  final double? latitudPropietario;
  final double? longitudPropietario;

  final int servicioId;
  final String nombreServicio;
  final double precioProgramado;
  final String? observacionesProgramacion;

  final int? medicoResponsableUsuarioId;
  final String? nombreMedico;
  final int? tecnicoUsuarioId;
  final String? nombreTecnico;

  final int? registroVisitaId;
  final double? pesoKg;
  final double? alturaCm;
  final double? temperaturaCelsius;
  final String? condicionCorporal;
  final String? observacionesAtencion;
  final double? latitudAtencion;
  final double? longitudAtencion;
  final DateTime? fechaRegistro;

  bool get completada => registroVisitaId != null;

  factory DetalleVisita.fromJson(Map<String, dynamic> json) {
    return DetalleVisita(
      visitaId: json['visitaId'] as int,
      fechaProgramada: DateTime.parse(json['fechaProgramada'] as String),
      estado: json['estado'] as String? ?? '',
      pacienteId: json['pacienteId'] as int,
      nombrePaciente: json['nombrePaciente'] as String? ?? '',
      rutaFoto: json['rutaFoto'] as String?,
      fechaNacimientoAproximada: _convertirFecha(
        json['fechaNacimientoAproximada'],
      ),
      observacionesPaciente: json['observacionesPaciente'] as String?,
      especieId: json['especieId'] as int,
      nombreEspecie: json['nombreEspecie'] as String? ?? '',
      razaId: json['razaId'] as int,
      nombreRaza: json['nombreRaza'] as String? ?? '',
      propietarioId: json['propietarioId'] as int,
      nombrePropietario: json['nombrePropietario'] as String? ?? '',
      telefonoPropietario: json['telefonoPropietario'] as String? ?? '',
      telefonoAlternativo: json['telefonoAlternativo'] as String?,
      direccion: json['direccion'] as String? ?? '',
      latitudPropietario: _convertirNumero(json['latitudPropietario']),
      longitudPropietario: _convertirNumero(json['longitudPropietario']),
      servicioId: json['servicioId'] as int,
      nombreServicio: json['nombreServicio'] as String? ?? '',
      precioProgramado:
          _convertirNumero(json['precioProgramado']) ?? 0,
      observacionesProgramacion:
          json['observacionesProgramacion'] as String?,
      medicoResponsableUsuarioId:
          json['medicoResponsableUsuarioId'] as int?,
      nombreMedico: json['nombreMedico'] as String?,
      tecnicoUsuarioId: json['tecnicoUsuarioId'] as int?,
      nombreTecnico: json['nombreTecnico'] as String?,
      registroVisitaId: json['registroVisitaId'] as int?,
      pesoKg: _convertirNumero(json['pesoKg']),
      alturaCm: _convertirNumero(json['alturaCm']),
      temperaturaCelsius:
          _convertirNumero(json['temperaturaCelsius']),
      condicionCorporal: json['condicionCorporal'] as String?,
      observacionesAtencion: json['observacionesAtencion'] as String?,
      latitudAtencion: _convertirNumero(json['latitudAtencion']),
      longitudAtencion: _convertirNumero(json['longitudAtencion']),
      fechaRegistro: _convertirFecha(json['fechaRegistro']),
    );
  }

  static double? _convertirNumero(dynamic valor) {
    return valor is num ? valor.toDouble() : null;
  }

  static DateTime? _convertirFecha(dynamic valor) {
    return valor is String ? DateTime.tryParse(valor) : null;
  }
}