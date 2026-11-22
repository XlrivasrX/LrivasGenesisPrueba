class EspecieCatalogo {
  const EspecieCatalogo({
    required this.especieId,
    required this.nombre,
    required this.activo,
  });

  final int especieId;
  final String nombre;
  final bool activo;

  factory EspecieCatalogo.fromJson(Map<String, dynamic> json) {
    return EspecieCatalogo(
      especieId: json['especieId'] as int,
      nombre: json['nombre'] as String? ?? '',
      activo: json['activo'] as bool? ?? false,
    );
  }
}

class RazaCatalogo {
  const RazaCatalogo({
    required this.razaId,
    required this.especieId,
    required this.nombreEspecie,
    required this.nombre,
    required this.activo,
  });

  final int razaId;
  final int especieId;
  final String nombreEspecie;
  final String nombre;
  final bool activo;

  factory RazaCatalogo.fromJson(Map<String, dynamic> json) {
    return RazaCatalogo(
      razaId: json['razaId'] as int,
      especieId: json['especieId'] as int,
      nombreEspecie: json['nombreEspecie'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
      activo: json['activo'] as bool? ?? false,
    );
  }
}