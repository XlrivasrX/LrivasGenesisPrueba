import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:vetruta_movil/core/tema/colores_app.dart';
import 'package:vetruta_movil/modulos/panel/presentacion/controladores/panel_controlador.dart';
import 'package:vetruta_movil/modulos/panel/presentacion/widgets/grafica_visitas_servicio.dart';
import 'package:vetruta_movil/modulos/panel/presentacion/widgets/tarjeta_cumplimiento.dart';
import 'package:vetruta_movil/modulos/panel/presentacion/widgets/tarjeta_mascotas_atendidas.dart';
import 'package:vetruta_movil/modulos/panel/presentacion/widgets/grafica_visitas_tecnico.dart';

class PanelPantalla extends StatefulWidget {
  const PanelPantalla({super.key});

  @override
  State<PanelPantalla> createState() => _PanelPantallaState();
}

class _PanelPantallaState extends State<PanelPantalla> {
  int _indiceSeleccionado = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PanelControlador>().cargarPanel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.fondo,
      appBar: AppBar(
        title: const Text('VetRuta'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
            tooltip: 'Notificaciones',
          ),
        ],
      ),
      body: Consumer<PanelControlador>(
        builder: (context, controlador, _) {
          final resumen = controlador.resumen;

          if (controlador.cargando && resumen == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controlador.mensajeError != null && resumen == null) {
            return _EstadoError(
              mensaje: controlador.mensajeError!,
              onReintentar: controlador.cargarPanel,
            );
          }

          if (resumen == null) {
            return const SizedBox.shrink();
          }

          return RefreshIndicator(
            onRefresh: controlador.cargarPanel,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Panel del director',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: ColoresApp.azulOscuro,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Resumen de visitas veterinarias a domicilio',
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: ColoresApp.textoSecundario),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _TarjetaResumen(
                        icono: Icons.calendar_month_outlined,
                        valor: resumen.visitasProgramadas,
                        etiqueta: 'Programadas',
                        color: ColoresApp.verdePrincipal,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _TarjetaResumen(
                        icono: Icons.check_circle_outline_rounded,
                        valor: resumen.visitasCompletadas,
                        etiqueta: 'Completadas',
                        color: ColoresApp.exito,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _TarjetaResumen(
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
                  icono: Icons.people_outline_rounded,
                  titulo: 'Propietarios activos',
                  valor: resumen.propietariosActivos,
                  color: ColoresApp.azulEncabezado,
                ),
                const SizedBox(height: 12),
                _TarjetaDato(
                  icono: Icons.pets_outlined,
                  titulo: 'Pacientes activos',
                  valor: resumen.pacientesActivos,
                  color: ColoresApp.verdePrincipal,
                ),
                const SizedBox(height: 16),
                GraficaVisitasTecnico(
                  datos: controlador.visitasPorTecnico,
                ),
                const SizedBox(height: 16),
                GraficaVisitasServicio(
                  datos: controlador.visitasPorServicio,
                ),
                const SizedBox(height: 16),
                TarjetaMascotasAtendidas(
                  datos: controlador.mascotasAtendidas,
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indiceSeleccionado,
        onDestinationSelected: (indice) {
          setState(() {
            _indiceSeleccionado = indice;
          });
        },
        backgroundColor: ColoresApp.superficie,
        indicatorColor: ColoresApp.verdePrincipal.withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt_rounded),
            label: 'Actividad',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups_rounded),
            label: 'Equipo',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class _TarjetaResumen extends StatelessWidget {
  const _TarjetaResumen({
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icono, color: color),
          const SizedBox(height: 8),
          Text(
            valor.toString(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: ColoresApp.azulOscuro,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            child: Text(
              etiqueta,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: ColoresApp.textoPrincipal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaDato extends StatelessWidget {
  const _TarjetaDato({
    required this.icono,
    required this.titulo,
    required this.valor,
    required this.color,
  });

  final IconData icono;
  final String titulo;
  final int valor;
  final Color color;

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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icono, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              titulo,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: ColoresApp.azulOscuro,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            valor.toString(),
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(color: color, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _EstadoError extends StatelessWidget {
  const _EstadoError({required this.mensaje, required this.onReintentar});

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
              size: 48,
              color: ColoresApp.coral,
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
