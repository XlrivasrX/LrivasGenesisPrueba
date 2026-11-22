import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:vetruta_movil/core/tema/colores_app.dart';
import 'package:vetruta_movil/modulos/agenda/datos/modelos/agenda_visita.dart';
import 'package:vetruta_movil/modulos/agenda/presentacion/controladores/agenda_controlador.dart';
import 'package:vetruta_movil/modulos/agenda/presentacion/pantallas/detalle_visita_pantalla.dart';
import 'package:vetruta_movil/modulos/agenda/presentacion/pantallas/mapa_pantalla.dart';
import 'package:vetruta_movil/modulos/agenda/presentacion/pantallas/pacientes_pantalla.dart';
import 'package:vetruta_movil/modulos/agenda/presentacion/pantallas/programar_visita_pantalla.dart';
import 'package:vetruta_movil/modulos/autenticacion/presentacion/controladores/autenticacion_controlador.dart';
import 'package:vetruta_movil/modulos/autenticacion/presentacion/pantallas/inicio_sesion_pantalla.dart';
import 'package:vetruta_movil/modulos/pacientes/presentacion/pantallas/crear_paciente_pantalla.dart';
import 'package:vetruta_movil/modulos/panel/presentacion/pantallas/panel_personal_pantalla.dart';
import 'package:vetruta_movil/modulos/panel/presentacion/pantallas/perfil_pantalla.dart';

class AgendaPantalla extends StatefulWidget {
  const AgendaPantalla({super.key});

  @override
  State<AgendaPantalla> createState() => _AgendaPantallaState();
}

class _AgendaPantallaState extends State<AgendaPantalla> {
  int _indiceSeleccionado = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AgendaControlador>().cargarAgenda();
    });
  }

  Future<void> _cerrarSesion() async {
    await context.read<AutenticacionControlador>().cerrarSesion();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const InicioSesionPantalla()),
      (_) => false,
    );
  }

  Future<void> _seleccionarVisitaParaRegistrar(
    AgendaControlador controlador,
  ) async {
    final pendientes = controlador.visitasSeleccionadas
        .where((visita) => !visita.completada)
        .toList();

    if (pendientes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No hay visitas pendientes para la fecha seleccionada.',
          ),
        ),
      );
      return;
    }

    AgendaVisita? visitaSeleccionada;

    if (pendientes.length == 1) {
      visitaSeleccionada = pendientes.first;
    } else {
      visitaSeleccionada = await showModalBottomSheet<AgendaVisita>(
        context: context,
        showDragHandle: true,
        builder: (context) {
          return SafeArea(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 16),
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Text(
                    'Selecciona una visita',
                    style: TextStyle(
                      color: ColoresApp.azulOscuro,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                ...pendientes.map(
                  (visita) => ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.pets_rounded),
                    ),
                    title: Text(visita.nombrePaciente),
                    subtitle: Text(visita.nombreServicio),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.of(context).pop(visita);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    if (!mounted || visitaSeleccionada == null) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            DetalleVisitaPantalla(visitaId: visitaSeleccionada!.visitaId),
      ),
    );
  }

  Future<void> _abrirCrearPaciente() async {
    final creado = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (_) => const CrearPacientePantalla()),
    );

    if (!mounted || creado != true) {
      return;
    }

    await context.read<AgendaControlador>().cargarAgenda();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Paciente creado y asignado correctamente.'),
      ),
    );
  }

  Future<void> _abrirProgramarVisita(
    AgendaControlador controlador,
  ) async {
    final fecha = await Navigator.of(context).push<DateTime>(
      MaterialPageRoute<DateTime>(
        builder: (_) => const ProgramarVisitaPantalla(),
      ),
    );

    if (!mounted || fecha == null) {
      return;
    }

    controlador.seleccionarFecha(fecha);
    await controlador.cargarAgenda();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Visita programada correctamente.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controlador = context.watch<AgendaControlador>();
    final autenticacion = context.watch<AutenticacionControlador>();
    final codigoRol = autenticacion.usuario?.codigoRol.toUpperCase();

    return Scaffold(
      backgroundColor: ColoresApp.fondo,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(_iconoSeccion()),
            const SizedBox(width: 10),
            Text(_tituloSeccion()),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const PanelPersonalPantalla(),
                ),
              );
            },
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'Ver tablero',
          ),
        ],
      ),
      body: _construirSeccion(context, controlador, autenticacion),
      floatingActionButton: _construirBotonesFlotantes(
        codigoRol,
        controlador,
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
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today_rounded),
            label: 'Agenda',
          ),
          NavigationDestination(
            icon: Icon(Icons.location_on_outlined),
            selectedIcon: Icon(Icons.location_on_rounded),
            label: 'Mapa',
          ),
          NavigationDestination(
            icon: Icon(Icons.pets_outlined),
            selectedIcon: Icon(Icons.pets_rounded),
            label: 'Pacientes',
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

  Widget? _construirBotonesFlotantes(
    String? codigoRol,
    AgendaControlador controlador,
  ) {
    if (codigoRol == 'MEDICO' && _indiceSeleccionado == 2) {
      return FloatingActionButton.extended(
        heroTag: 'nuevo-paciente',
        onPressed: _abrirCrearPaciente,
        backgroundColor: ColoresApp.verdePrincipal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text(
          'Nuevo paciente',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      );
    }

    if (_indiceSeleccionado != 0 ||
        (codigoRol != 'MEDICO' && codigoRol != 'TECNICO')) {
      return null;
    }

    final botonProgramar = FloatingActionButton.extended(
      heroTag: 'programar-visita',
      onPressed: controlador.cargando
          ? null
          : () => _abrirProgramarVisita(controlador),
      backgroundColor: ColoresApp.verdePrincipal,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.event_available_outlined),
      label: const Text(
        'Programar visita',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
    );

    if (codigoRol == 'MEDICO') {
      return botonProgramar;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        botonProgramar,
        const SizedBox(height: 10),
        FloatingActionButton.extended(
          heroTag: 'registrar-visita',
          onPressed: controlador.cargando
              ? null
              : () => _seleccionarVisitaParaRegistrar(controlador),
          backgroundColor: ColoresApp.verdePrincipal,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            'Registrar visita',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _construirSeccion(
    BuildContext context,
    AgendaControlador controlador,
    AutenticacionControlador autenticacion,
  ) {
    if (_indiceSeleccionado == 1) {
      return MapaPantalla(
        visitas: controlador.visitas,
        onActualizar: controlador.cargarAgenda,
      );
    }

    if (_indiceSeleccionado == 2) {
      return PacientesPantalla(
        pacientes: controlador.pacientes,
        onActualizar: controlador.cargarAgenda,
      );
    }

    if (_indiceSeleccionado == 3) {
      final usuario = autenticacion.usuario;

      if (usuario == null) {
        return const SizedBox.shrink();
      }

      return PerfilPantalla(
        usuario: usuario,
        cerrandoSesion: autenticacion.cargando,
        onCerrarSesion: _cerrarSesion,
      );
    }

    return Column(
      children: [
        if (controlador.cargando) const LinearProgressIndicator(minHeight: 3),
        Expanded(child: _construirContenido(context, controlador)),
      ],
    );
  }

  String _tituloSeccion() {
    return switch (_indiceSeleccionado) {
      1 => 'Mi ruta',
      2 => 'Pacientes',
      3 => 'Perfil',
      _ => 'Mi agenda',
    };
  }

  IconData _iconoSeccion() {
    return switch (_indiceSeleccionado) {
      1 => Icons.route_outlined,
      2 => Icons.pets_outlined,
      3 => Icons.person_outline_rounded,
      _ => Icons.calendar_month_outlined,
    };
  }

  Widget _construirContenido(
    BuildContext context,
    AgendaControlador controlador,
  ) {
    if (controlador.cargando && controlador.visitas.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controlador.mensajeError != null && controlador.visitas.isEmpty) {
      return _EstadoError(
        mensaje: controlador.mensajeError!,
        onReintentar: controlador.cargarAgenda,
      );
    }

    return RefreshIndicator(
      onRefresh: controlador.cargarAgenda,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: ColoresApp.azulOscuro,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _formatearFecha(controlador.fechaSeleccionada),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: ColoresApp.azulOscuro,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _seleccionarFecha(context, controlador),
                icon: const Icon(Icons.date_range_outlined),
                tooltip: 'Seleccionar fecha',
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SelectorSemana(controlador: controlador),
          const SizedBox(height: 20),
          if (controlador.mensajeError != null) ...[
            _MensajeError(mensaje: controlador.mensajeError!),
            const SizedBox(height: 14),
          ],
          if (controlador.visitasSeleccionadas.isEmpty)
            const _AgendaVacia()
          else
            ...controlador.visitasSeleccionadas.map(
              (visita) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TarjetaVisita(visita: visita),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _seleccionarFecha(
    BuildContext context,
    AgendaControlador controlador,
  ) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: controlador.fechaSeleccionada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (fecha == null) {
      return;
    }

    final semanaAnterior = controlador.fechasSemana.first;
    controlador.seleccionarFecha(fecha);
    final semanaNueva = controlador.fechasSemana.first;

    if (!_mismaFecha(semanaAnterior, semanaNueva)) {
      await controlador.cargarAgenda();
    }
  }

  String _formatearFecha(DateTime fecha) {
    const dias = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];

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

    return '${dias[fecha.weekday - 1]} ${fecha.day} de ${meses[fecha.month - 1]}';
  }

  bool _mismaFecha(DateTime primera, DateTime segunda) {
    return primera.year == segunda.year &&
        primera.month == segunda.month &&
        primera.day == segunda.day;
  }
}

class _SelectorSemana extends StatelessWidget {
  const _SelectorSemana({required this.controlador});

  final AgendaControlador controlador;

  @override
  Widget build(BuildContext context) {
    const nombresDias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

    return Row(
      children: List.generate(controlador.fechasSemana.length, (indice) {
        final fecha = controlador.fechasSemana[indice];
        final seleccionada = _mismaFecha(fecha, controlador.fechaSeleccionada);

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: indice == 6 ? 0 : 5),
            child: InkWell(
              onTap: () => controlador.seleccionarFecha(fecha),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: seleccionada
                      ? ColoresApp.verdePrincipal
                      : ColoresApp.superficie,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: seleccionada
                        ? ColoresApp.verdePrincipal
                        : ColoresApp.borde,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      nombresDias[indice],
                      style: TextStyle(
                        color: seleccionada
                            ? Colors.white
                            : ColoresApp.textoSecundario,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fecha.day.toString(),
                      style: TextStyle(
                        color: seleccionada
                            ? Colors.white
                            : ColoresApp.azulOscuro,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  bool _mismaFecha(DateTime primera, DateTime segunda) {
    return primera.year == segunda.year &&
        primera.month == segunda.month &&
        primera.day == segunda.day;
  }
}

class _TarjetaVisita extends StatelessWidget {
  const _TarjetaVisita({required this.visita});

  final AgendaVisita visita;

  @override
  Widget build(BuildContext context) {
    final colorEstado = visita.completada
        ? ColoresApp.exito
        : visita.atrasada
        ? ColoresApp.coral
        : ColoresApp.amarillo;

    final textoEstado = visita.completada
        ? 'Realizada'
        : visita.atrasada
        ? 'Atrasada'
        : 'Pendiente';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => DetalleVisitaPantalla(visitaId: visita.visitaId),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: ColoresApp.superficie,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ColoresApp.borde),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: colorEstado,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(16),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: colorEstado.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(Icons.pets_rounded, color: colorEstado),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              visita.nombrePaciente,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: ColoresApp.azulOscuro,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              visita.nombreServicio,
                              style: const TextStyle(
                                color: ColoresApp.textoSecundario,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Row(
                              children: [
                                const Icon(
                                  Icons.schedule_outlined,
                                  size: 16,
                                  color: ColoresApp.textoSecundario,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatearHora(visita.fechaProgramada),
                                  style: const TextStyle(
                                    color: ColoresApp.textoPrincipal,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: colorEstado.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              textoEstado,
                              style: TextStyle(
                                color: colorEstado,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: ColoresApp.textoSecundario,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatearHora(DateTime fecha) {
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minutos = fecha.minute.toString().padLeft(2, '0');

    return '$hora:$minutos';
  }
}

class _MensajeError extends StatelessWidget {
  const _MensajeError({required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColoresApp.coral.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: ColoresApp.coral),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mensaje,
              style: const TextStyle(
                color: ColoresApp.coral,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AgendaVacia extends StatelessWidget {
  const _AgendaVacia();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 80),
      child: Column(
        children: [
          Icon(
            Icons.event_available_outlined,
            size: 54,
            color: ColoresApp.textoSecundario,
          ),
          SizedBox(height: 12),
          Text(
            'No hay visitas programadas para este día.',
            textAlign: TextAlign.center,
            style: TextStyle(color: ColoresApp.textoSecundario, fontSize: 16),
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
