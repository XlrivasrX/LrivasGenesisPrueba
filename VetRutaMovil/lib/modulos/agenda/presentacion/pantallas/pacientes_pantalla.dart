import 'package:material_ui/material_ui.dart';
import 'package:vetruta_movil/core/tema/colores_app.dart';
import 'package:vetruta_movil/modulos/agenda/datos/modelos/agenda_visita.dart';
import 'package:vetruta_movil/modulos/pacientes/presentacion/pantallas/paciente_detalle_pantalla.dart';

class PacientesPantalla extends StatelessWidget {
  const PacientesPantalla({
    required this.visitas,
    required this.onActualizar,
    super.key,
  });

  final List<AgendaVisita> visitas;
  final Future<void> Function() onActualizar;

  @override
  Widget build(BuildContext context) {
    final pacientes = _obtenerPacientes();

    return RefreshIndicator(
      onRefresh: onActualizar,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Pacientes',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: ColoresApp.azulOscuro,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Mascotas incluidas en tu agenda semanal',
            style: TextStyle(color: ColoresApp.textoSecundario),
          ),
          const SizedBox(height: 20),
          if (pacientes.isEmpty)
            const _EstadoVacio()
          else
            ...pacientes.map(
              (paciente) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TarjetaPaciente(visita: paciente),
              ),
            ),
        ],
      ),
    );
  }

  List<AgendaVisita> _obtenerPacientes() {
    final pacientesUnicos = <int, AgendaVisita>{};

    for (final visita in visitas) {
      pacientesUnicos.putIfAbsent(visita.pacienteId, () => visita);
    }

    final pacientes = pacientesUnicos.values.toList();

    pacientes.sort((primero, segundo) {
      return primero.nombrePaciente.compareTo(segundo.nombrePaciente);
    });

    return pacientes;
  }
}

class _TarjetaPaciente extends StatelessWidget {
  const _TarjetaPaciente({required this.visita});

  final AgendaVisita visita;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                PacienteDetallePantalla(pacienteId: visita.pacienteId),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ColoresApp.superficie,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ColoresApp.borde),
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: ColoresApp.verdePrincipal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.pets_rounded,
                size: 30,
                color: ColoresApp.verdePrincipal,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    visita.nombrePaciente,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: ColoresApp.azulOscuro,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${visita.nombreEspecie} · ${visita.nombreRaza}',
                    style: const TextStyle(color: ColoresApp.textoSecundario),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline_rounded,
                        size: 17,
                        color: ColoresApp.textoSecundario,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          visita.nombrePropietario,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: ColoresApp.textoPrincipal,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 17,
                        color: ColoresApp.textoSecundario,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        visita.telefonoPropietario,
                        style: const TextStyle(
                          color: ColoresApp.textoPrincipal,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: ColoresApp.textoSecundario,
            ),
          ],
        ),
      ),
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
            Icons.pets_outlined,
            size: 54,
            color: ColoresApp.textoSecundario,
          ),
          SizedBox(height: 12),
          Text(
            'No hay pacientes en la agenda.',
            style: TextStyle(color: ColoresApp.textoSecundario, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
