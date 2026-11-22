import 'package:material_ui/material_ui.dart';
import 'package:vetruta_movil/core/tema/colores_app.dart';
import 'package:vetruta_movil/modulos/panel/datos/modelos/visitas_por_fecha.dart';

class ActividadPantalla extends StatelessWidget {
  const ActividadPantalla({
    required this.datos,
    required this.onActualizar,
    super.key,
  });

  final List<VisitasPorFecha> datos;
  final Future<void> Function() onActualizar;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onActualizar,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Actividad',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: ColoresApp.azulOscuro,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Resumen de visitas registradas por fecha',
            style: TextStyle(
              color: ColoresApp.textoSecundario,
            ),
          ),
          const SizedBox(height: 20),
          if (datos.isEmpty)
            const _EstadoVacio()
          else
            ...datos.map(
              (actividad) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TarjetaActividad(actividad: actividad),
              ),
            ),
        ],
      ),
    );
  }
}

class _TarjetaActividad extends StatelessWidget {
  const _TarjetaActividad({
    required this.actividad,
  });

  final VisitasPorFecha actividad;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColoresApp.superficie,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColoresApp.borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: ColoresApp.verdePrincipal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_today_outlined,
                  color: ColoresApp.verdePrincipal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _formatearFecha(actividad.fecha),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: ColoresApp.azulOscuro,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                actividad.cantidadVisitas.toString(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: ColoresApp.azulOscuro,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _DatoActividad(
                  etiqueta: 'Completadas',
                  valor: actividad.completadas.toString(),
                  color: ColoresApp.exito,
                ),
              ),
              Expanded(
                child: _DatoActividad(
                  etiqueta: 'Programadas',
                  valor: actividad.programadas.toString(),
                  color: ColoresApp.amarillo,
                ),
              ),
              Expanded(
                child: _DatoActividad(
                  etiqueta: 'Total',
                  valor: 'Q${actividad.totalProgramado.toStringAsFixed(0)}',
                  color: ColoresApp.azulEncabezado,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    const meses = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];

    return '${fecha.day} de ${meses[fecha.month - 1]} de ${fecha.year}';
  }
}

class _DatoActividad extends StatelessWidget {
  const _DatoActividad({
    required this.etiqueta,
    required this.valor,
    required this.color,
  });

  final String etiqueta;
  final String valor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          valor,
          style: TextStyle(
            color: color,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          child: Text(
            etiqueta,
            style: const TextStyle(
              color: ColoresApp.textoSecundario,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

class _EstadoVacio extends StatelessWidget {
  const _EstadoVacio();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 80),
      child: Column(
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 54,
            color: ColoresApp.textoSecundario,
          ),
          SizedBox(height: 12),
          Text(
            'No hay actividad registrada.',
            style: TextStyle(
              color: ColoresApp.textoSecundario,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}