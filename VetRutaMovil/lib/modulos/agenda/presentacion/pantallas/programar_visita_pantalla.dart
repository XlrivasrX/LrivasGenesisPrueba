import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:vetruta_movil/core/tema/colores_app.dart';
import 'package:vetruta_movil/modulos/agenda/datos/servicios/agenda_servicio.dart';
import 'package:vetruta_movil/modulos/agenda/presentacion/controladores/programar_visita_controlador.dart';

class ProgramarVisitaPantalla extends StatelessWidget {
  const ProgramarVisitaPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProgramarVisitaControlador>(
      create: (context) =>
          ProgramarVisitaControlador(context.read<AgendaServicio>())
            ..cargarOpciones(),
      child: const _ProgramarVisitaFormulario(),
    );
  }
}

class _ProgramarVisitaFormulario extends StatefulWidget {
  const _ProgramarVisitaFormulario();

  @override
  State<_ProgramarVisitaFormulario> createState() =>
      _ProgramarVisitaFormularioState();
}

class _ProgramarVisitaFormularioState
    extends State<_ProgramarVisitaFormulario> {
  final _precio = TextEditingController();
  final _observaciones = TextEditingController();
  late DateTime _fechaProgramada;
  bool _precioInicializado = false;

  @override
  void initState() {
    super.initState();
    final ahora = DateTime.now();
    _fechaProgramada = DateTime(
      ahora.year,
      ahora.month,
      ahora.day + 1,
      9,
    );
  }

  @override
  void dispose() {
    _precio.dispose();
    _observaciones.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controlador = context.watch<ProgramarVisitaControlador>();
    final paciente = controlador.pacienteSeleccionado;
    final servicio = controlador.servicioSeleccionado;

    if (!_precioInicializado && servicio != null) {
      _precio.text = servicio.precio.toStringAsFixed(2);
      _precioInicializado = true;
    }

    return Scaffold(
      backgroundColor: ColoresApp.fondo,
      appBar: AppBar(title: const Text('Programar visita')),
      body: controlador.cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(18),
              children: [
                if (controlador.pacientes.isEmpty)
                  const _MensajeInformativo(
                    mensaje:
                        'No hay pacientes con una asignación activa para programar.',
                  )
                else ...[
                  const _TituloSeccion(titulo: 'Paciente y responsables'),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: controlador.pacienteId,
                    decoration: const InputDecoration(
                      labelText: 'Paciente',
                      prefixIcon: Icon(Icons.pets_outlined),
                    ),
                    items: controlador.pacientes
                        .map(
                          (opcion) => DropdownMenuItem<int>(
                            value: opcion.pacienteId,
                            child: Text(opcion.nombrePaciente),
                          ),
                        )
                        .toList(),
                    onChanged: controlador.guardando
                        ? null
                        : (valor) {
                            controlador.seleccionarPaciente(valor);
                            setState(() {});
                          },
                  ),
                  if (paciente != null) ...[
                    const SizedBox(height: 12),
                    _ResumenResponsables(
                      propietario: paciente.nombrePropietario,
                      medico: paciente.nombreMedico,
                      tecnico: paciente.nombreTecnico,
                    ),
                  ],
                  const SizedBox(height: 22),
                  const _TituloSeccion(titulo: 'Datos de la visita'),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: controlador.servicioId,
                    decoration: const InputDecoration(
                      labelText: 'Servicio',
                      prefixIcon: Icon(Icons.medical_services_outlined),
                    ),
                    items: controlador.servicios
                        .map(
                          (opcion) => DropdownMenuItem<int>(
                            value: opcion.servicioId,
                            child: Text(opcion.nombre),
                          ),
                        )
                        .toList(),
                    onChanged: controlador.guardando
                        ? null
                        : (valor) {
                            controlador.seleccionarServicio(valor);
                            final seleccionado = controlador
                                .servicioSeleccionado;
                            if (seleccionado != null) {
                              _precio.text = seleccionado.precio
                                  .toStringAsFixed(2);
                            }
                          },
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: controlador.guardando
                              ? null
                              : _seleccionarFecha,
                          icon: const Icon(Icons.calendar_month_outlined),
                          label: Text(_formatearFecha(_fechaProgramada)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: controlador.guardando
                              ? null
                              : _seleccionarHora,
                          icon: const Icon(Icons.schedule_outlined),
                          label: Text(_formatearHora(_fechaProgramada)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _precio,
                    enabled: !controlador.guardando,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Precio programado',
                      prefixText: 'Q ',
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _observaciones,
                    enabled: !controlador.guardando,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Observaciones',
                      prefixIcon: Icon(Icons.notes_outlined),
                    ),
                  ),
                  if (controlador.mensajeError != null) ...[
                    const SizedBox(height: 16),
                    _MensajeError(mensaje: controlador.mensajeError!),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: controlador.guardando
                          ? null
                          : () => _guardar(controlador),
                      icon: controlador.guardando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.event_available_outlined),
                      label: Text(
                        controlador.guardando
                            ? 'Programando...'
                            : 'Programar visita',
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
    );
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaProgramada,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (fecha == null) {
      return;
    }

    setState(() {
      _fechaProgramada = DateTime(
        fecha.year,
        fecha.month,
        fecha.day,
        _fechaProgramada.hour,
        _fechaProgramada.minute,
      );
    });
  }

  Future<void> _seleccionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_fechaProgramada),
    );

    if (hora == null) {
      return;
    }

    setState(() {
      _fechaProgramada = DateTime(
        _fechaProgramada.year,
        _fechaProgramada.month,
        _fechaProgramada.day,
        hora.hour,
        hora.minute,
      );
    });
  }

  Future<void> _guardar(ProgramarVisitaControlador controlador) async {
    final guardada = await controlador.programar(
      fechaProgramada: _fechaProgramada,
      precio: _precio.text,
      observaciones: _observaciones.text,
    );

    if (!mounted || !guardada) {
      return;
    }

    Navigator.of(context).pop(_fechaProgramada);
  }

  String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    return '$dia/$mes/${fecha.year}';
  }

  String _formatearHora(DateTime fecha) {
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');
    return '$hora:$minuto';
  }
}

class _TituloSeccion extends StatelessWidget {
  const _TituloSeccion({required this.titulo});

  final String titulo;

  @override
  Widget build(BuildContext context) {
    return Text(
      titulo,
      style: const TextStyle(
        color: ColoresApp.azulOscuro,
        fontSize: 19,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _ResumenResponsables extends StatelessWidget {
  const _ResumenResponsables({
    required this.propietario,
    required this.medico,
    required this.tecnico,
  });

  final String propietario;
  final String medico;
  final String tecnico;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColoresApp.verdePrincipal.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Propietario: $propietario'),
          const SizedBox(height: 5),
          Text('Médico: $medico'),
          const SizedBox(height: 5),
          Text('Técnico: $tecnico'),
        ],
      ),
    );
  }
}

class _MensajeInformativo extends StatelessWidget {
  const _MensajeInformativo({required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(mensaje, textAlign: TextAlign.center),
      ),
    );
  }
}

class _MensajeError extends StatelessWidget {
  const _MensajeError({required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColoresApp.coral.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(mensaje, style: const TextStyle(color: ColoresApp.coral)),
    );
  }
}
