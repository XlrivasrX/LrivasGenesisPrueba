class PacienteDetalle {
  const PacienteDetalle({
    required this.pacienteId,
    required this.propietarioId,
    required this.nombrePropietario,
    required this.telefonoPropietario,
    required this.direccion,
    required this.especieId,
    required this.nombreEspecie,
    required this.razaId,
    required this.nombreRaza,
    required this.nombre,
    required this.creadoPorUsuarioId,
    required this.activo,
    required this.fechaCreacion,
    this.telefonoAlternativo,
    this.latitud,
    this.longitud,
    this.zonaId,
    this.nombreZona,
    this.fechaNacimientoAproximada,
    this.rutaFoto,
    this.observaciones,
    this.fechaActualizacion,
  });

  final int pacienteId;
  final int propietarioId;
  final String nombrePropietario;
  final String telefonoPropietario;
  final String? telefonoAlternativo;
  final String direccion;
  final double? latitud;
  final double? longitud;
  final int? zonaId;
  final String? nombreZona;

  final int especieId;
  final String nombreEspecie;
  final int razaId;
  final String nombreRaza;
  final String nombre;
  final DateTime? fechaNacimientoAproximada;
  final String? rutaFoto;
  final String? observaciones;

  final int creadoPorUsuarioId;
  final bool activo;
  final DateTime fechaCreacion;
  final DateTime? fechaActualizacion;

  factory PacienteDetalle.fromJson(Map<String, dynamic> json) {
    return PacienteDetalle(
      pacienteId: (json['pacienteId'] as num?)?.toInt() ?? 0,
      propietarioId:
          (json['propietarioId'] as num?)?.toInt() ?? 0,
      nombrePropietario:
          json['nombrePropietario'] as String? ?? '',
      telefonoPropietario:
          json['telefonoPropietario'] as String? ?? '',
      telefonoAlternativo:
          json['telefonoAlternativo'] as String?,
      direccion: json['direccion'] as String? ?? '',
      latitud: _convertirNumero(json['latitud']),
      longitud: _convertirNumero(json['longitud']),
      zonaId: (json['zonaId'] as num?)?.toInt(),
      nombreZona: json['nombreZona'] as String?,
      especieId: (json['especieId'] as num?)?.toInt() ?? 0,
      nombreEspecie: json['nombreEspecie'] as String? ?? '',
      razaId: (json['razaId'] as num?)?.toInt() ?? 0,
      nombreRaza: json['nombreRaza'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
      fechaNacimientoAproximada:
          _convertirFecha(json['fechaNacimientoAproximada']),
      rutaFoto: json['rutaFoto'] as String?,
      observaciones: json['observaciones'] as String?,
      creadoPorUsuarioId:
          (json['creadoPorUsuarioId'] as num?)?.toInt() ?? 0,
      activo: json['activo'] as bool? ?? false,
      fechaCreacion:
          _convertirFecha(json['fechaCreacion']) ?? DateTime(1970),
      fechaActualizacion:
          _convertirFecha(json['fechaActualizacion']),
    );
  }

  static double? _convertirNumero(dynamic valor) {
    return valor is num ? valor.toDouble() : null;
  }

  static DateTime? _convertirFecha(dynamic valor) {
    return valor is String ? DateTime.tryParse(valor) : null;
  }
}