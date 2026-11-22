class MascotasAtendidas {
  const MascotasAtendidas({
    required this.especieId,
    required this.nombreEspecie,
    required this.cantidadMascotas,
  });

  final int especieId;
  final String nombreEspecie;
  final int cantidadMascotas;

  factory MascotasAtendidas.fromJson(Map<String, dynamic> json) {
    return MascotasAtendidas(
      especieId: (json['especieId'] as num?)?.toInt() ?? 0,
      nombreEspecie: json['nombreEspecie'] as String? ?? '',
      cantidadMascotas: (json['cantidadMascotas'] as num?)?.toInt() ?? 0,
    );
  }
}