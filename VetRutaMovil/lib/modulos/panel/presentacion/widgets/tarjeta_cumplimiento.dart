import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';
import 'package:vetruta_movil/core/tema/colores_app.dart';

class TarjetaCumplimiento extends StatelessWidget {
  const TarjetaCumplimiento({
    required this.programadas,
    required this.completadas,
    super.key,
  });

  final int programadas;
  final int completadas;

  @override
  Widget build(BuildContext context) {
    final total = programadas + completadas;
    final porcentaje = total == 0 ? 0 : ((completadas / total) * 100).round();

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
          Text(
            'Cumplimiento',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: ColoresApp.azulOscuro,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        startDegreeOffset: -90,
                        centerSpaceRadius: 38,
                        sectionsSpace: 0,
                        sections: _crearSecciones(total),
                      ),
                    ),
                    Text(
                      '$porcentaje%',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: ColoresApp.azulOscuro,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  '$completadas de $total\nvisitas completadas',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: ColoresApp.textoPrincipal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _crearSecciones(int total) {
    if (total == 0) {
      return [
        PieChartSectionData(
          value: 1,
          color: ColoresApp.borde,
          radius: 12,
          showTitle: false,
        ),
      ];
    }

    return [
      PieChartSectionData(
        value: completadas.toDouble(),
        color: ColoresApp.verdePrincipal,
        radius: 12,
        showTitle: false,
      ),
      PieChartSectionData(
        value: programadas.toDouble(),
        color: ColoresApp.borde,
        radius: 12,
        showTitle: false,
      ),
    ];
  }
}