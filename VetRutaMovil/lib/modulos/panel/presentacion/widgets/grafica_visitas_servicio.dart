import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';
import 'package:vetruta_movil/core/tema/colores_app.dart';
import 'package:vetruta_movil/modulos/panel/datos/modelos/visitas_por_servicio.dart';

class GraficaVisitasServicio extends StatelessWidget {
  const GraficaVisitasServicio({
    required this.datos,
    super.key,
  });

  final List<VisitasPorServicio> datos;

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
            'Visitas por servicio',
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
                  'No hay visitas registradas por servicio.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            SizedBox(
              height: 210,
              child: BarChart(
                BarChartData(
                  maxY: _obtenerMaximo(),
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(enabled: true),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(
                    drawVerticalLine: false,
                    horizontalInterval: 1,
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
                        interval: 1,
                        reservedSize: 28,
                        getTitlesWidget: (valor, _) {
                          return Text(
                            valor.toInt().toString(),
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
                        reservedSize: 42,
                        getTitlesWidget: (valor, _) {
                          final indice = valor.toInt();

                          if (indice < 0 || indice >= datos.length) {
                            return const SizedBox.shrink();
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _etiquetaServicio(datos[indice]),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: ColoresApp.textoPrincipal,
                                fontSize: 10,
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
                          toY: datos[indice].cantidadVisitas.toDouble(),
                          width: 22,
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

  double _obtenerMaximo() {
    final cantidadMayor = datos.fold<int>(
      0,
      (mayor, elemento) {
        return elemento.cantidadVisitas > mayor
            ? elemento.cantidadVisitas
            : mayor;
      },
    );

    return cantidadMayor == 0 ? 1 : (cantidadMayor + 1).toDouble();
  }

  String _etiquetaServicio(VisitasPorServicio servicio) {
    final codigo = servicio.codigo.toUpperCase();

    if (codigo.contains('VAC')) {
      return 'Vac';
    }

    if (codigo.contains('DESPAR')) {
      return 'Desp';
    }

    if (codigo.contains('CUR')) {
      return 'Cur';
    }

    if (codigo.contains('PESO')) {
      return 'Ctrl Pes';
    }

    if (codigo.contains('DESARROLLO')) {
      return 'Ctrl Desa';
    }

    return 'Otro';
  }
}