import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';
import 'package:vetruta_movil/core/tema/colores_app.dart';
import 'package:vetruta_movil/modulos/panel/datos/modelos/visitas_por_tecnico.dart';

class GraficaVisitasTecnico extends StatelessWidget {
  const GraficaVisitasTecnico({
    required this.datos,
    super.key,
  });

  final List<VisitasPorTecnico> datos;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: ColoresApp.superficie,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColoresApp.borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cumplimiento por técnico',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: ColoresApp.azulOscuro,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          if (datos.isEmpty)
            const SizedBox(
              height: 180,
              child: Center(
                child: Text(
                  'No hay visitas asignadas a técnicos.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            SizedBox(
              height: 210,
              child: BarChart(
                BarChartData(
                  maxY: 100,
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(enabled: true),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(
                    drawVerticalLine: false,
                    horizontalInterval: 25,
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 25,
                        reservedSize: 36,
                        getTitlesWidget: (valor, _) {
                          return Text(
                            '${valor.toInt()}%',
                            style: const TextStyle(
                              color: ColoresApp.textoSecundario,
                              fontSize: 11,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (valor, _) {
                          final indice = valor.toInt();

                          if (indice < 0 || indice >= datos.length) {
                            return const SizedBox.shrink();
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${_obtenerNombreCorto(datos[indice].nombreTecnico)}\n'
                              '${_calcularCumplimiento(datos[indice]).round()}%',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: ColoresApp.textoPrincipal,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(
                    datos.length,
                    (indice) => BarChartGroupData(
                      x: indice,
                      barRods: [
                        BarChartRodData(
                          toY: _calcularCumplimiento(datos[indice]),
                          width: 24,
                          color: ColoresApp.verdePrincipal,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  double _calcularCumplimiento(VisitasPorTecnico dato) {
    if (dato.cantidadVisitas == 0) {
      return 0;
    }

    return dato.completadas * 100 / dato.cantidadVisitas;
  }

  String _obtenerNombreCorto(String nombre) {
    final partes = nombre.trim().split(' ');
    return partes.isEmpty || partes.first.isEmpty ? 'Técnico' : partes.first;
  }
}
