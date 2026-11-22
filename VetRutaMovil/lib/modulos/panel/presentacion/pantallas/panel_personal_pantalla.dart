import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:vetruta_movil/core/tema/colores_app.dart';
import 'package:vetruta_movil/modulos/autenticacion/presentacion/controladores/autenticacion_controlador.dart';
import 'package:vetruta_movil/modulos/panel/presentacion/controladores/panel_controlador.dart';
import 'package:vetruta_movil/modulos/panel/presentacion/widgets/grafica_visitas_servicio.dart';
import 'package:vetruta_movil/modulos/panel/presentacion/widgets/grafica_visitas_tecnico.dart';
import 'package:vetruta_movil/modulos/panel/presentacion/widgets/tarjeta_cumplimiento.dart';
import 'package:vetruta_movil/modulos/panel/presentacion/widgets/tarjeta_pacientes_por_especie.dart';

class PanelPersonalPantalla extends StatefulWidget {
  const PanelPersonalPantalla({super.key});

  @override
  State<PanelPersonalPantalla> createState() =>
      _PanelPersonalPantallaState();
}

class _PanelPersonalPantallaState extends State<PanelPersonalPantalla> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PanelControlador>().cargarPanel();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controlador = context.watch<PanelControlador>();
    final usuario = context.watch<AutenticacionControlador>().usuario;
    final esMedico = usuario?.codigoRol.toUpperCase() == 'MEDICO';
    final resumen = controlador.resumen;

    return Scaffold(
      backgroundColor: ColoresApp.fondo,
      appBar: AppBar(title: Text(esMedico ? 'Tablero de mi equipo' : 'Mi tablero')),
      body: controlador.cargando && resumen == null
          ? const Center(child: CircularProgressIndicator())
          : resumen == null
          ? _EstadoPanel(
              mensaje: controlador.mensajeError ?? 'No hay datos disponibles.',
              onReintentar: controlador.cargarPanel,
            )
          : RefreshIndicator(
              onRefresh: controlador.cargarPanel,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    esMedico ? 'Actividad de mi equipo' : 'Mi actividad',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: ColoresApp.azulOscuro,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    esMedico
                        ? 'Resumen de las visitas bajo tu responsabilidad'
                        : 'Resumen de tus visitas asignadas',
                    style: const TextStyle(color: ColoresApp.textoSecundario),
                  ),
                  if (controlador.cargando) ...[
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(minHeight: 3),
                  ],
                  if (controlador.mensajeError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      controlador.mensajeError!,
                      style: const TextStyle(color: ColoresApp.coral),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _TarjetaMetrica(
                          icono: Icons.calendar_month_outlined,
                          valor: resumen.visitasProgramadas,
                          etiqueta: 'Pendientes',
                          color: ColoresApp.amarillo,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _TarjetaMetrica(
                          icono: Icons.check_circle_outline_rounded,
                          valor: resumen.visitasCompletadas,
                          etiqueta: 'Completadas',
                          color: ColoresApp.exito,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _TarjetaMetrica(
                          icono: Icons.today_outlined,
                          valor: resumen.visitasDeHoy,
                          etiqueta: 'De hoy',
                          color: ColoresApp.coral,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TarjetaCumplimiento(
                    programadas: resumen.visitasProgramadas,
                    completadas: resumen.visitasCompletadas,
                  ),
                  const SizedBox(height: 16),
                  _TarjetaDato(
                    titulo: 'Pacientes activos',
                    valor: resumen.pacientesActivos,
                  ),
                  const SizedBox(height: 16),
                  GraficaVisitasTecnico(datos: controlador.visitasPorTecnico),
                  const SizedBox(height: 16),
                  GraficaVisitasServicio(datos: controlador.visitasPorServicio),
                  const SizedBox(height: 16),
                  TarjetaPacientesPorEspecie(
                    datos: controlador.pacientesPorEspecie,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}

class _TarjetaMetrica extends StatelessWidget {
  const _TarjetaMetrica({
    required this.icono,
    required this.valor,
    required this.etiqueta,
    required this.color,
  });

  final IconData icono;
  final int valor;
  final String etiqueta;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icono, color: color),
          const SizedBox(height: 6),
          Text(
            valor.toString(),
            style: const TextStyle(
              color: ColoresApp.azulOscuro,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            etiqueta,
            maxLines: 1,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _TarjetaDato extends StatelessWidget {
  const _TarjetaDato({required this.titulo, required this.valor});

  final String titulo;
  final int valor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColoresApp.superficie,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColoresApp.borde),
      ),
      child: Row(
        children: [
          const Icon(Icons.pets_outlined, color: ColoresApp.verdePrincipal),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(
                color: ColoresApp.azulOscuro,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            valor.toString(),
            style: const TextStyle(
              color: ColoresApp.verdePrincipal,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _EstadoPanel extends StatelessWidget {
  const _EstadoPanel({required this.mensaje, required this.onReintentar});

  final String mensaje;
  final Future<void> Function() onReintentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: ColoresApp.coral,
              size: 46,
            ),
            const SizedBox(height: 12),
            Text(mensaje, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onReintentar,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
