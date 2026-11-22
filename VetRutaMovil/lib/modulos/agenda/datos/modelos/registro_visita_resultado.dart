class RegistroVisitaResultado {
  const RegistroVisitaResultado({
    required this.registroVisitaId,
    required this.mensaje,
  });

  final int registroVisitaId;
  final String mensaje;

  factory RegistroVisitaResultado.fromJson(
    Map<String, dynamic> json,
  ) {
    return RegistroVisitaResultado(
      registroVisitaId: json['registroVisitaId'] as int,
      mensaje: json['mensaje'] as String? ??
          'Visita completada correctamente.',
    );
  }
}