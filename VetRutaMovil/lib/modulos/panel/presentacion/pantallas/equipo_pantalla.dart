import 'package:material_ui/material_ui.dart';
import 'package:vetruta_movil/core/tema/colores_app.dart';
import 'package:vetruta_movil/modulos/jerarquia/presentacion/pantallas/asignar_tecnicos_pantalla.dart';
import 'package:vetruta_movil/modulos/panel/datos/modelos/visitas_por_tecnico.dart';

class EquipoPantalla extends StatelessWidget {
  const EquipoPantalla({
    required this.tecnicos,
    required this.onActualizar,
    required this.puedeAdministrarJerarquia,
    super.key,
  });

  final List<VisitasPorTecnico> tecnicos;
  final Future<void> Function() onActualizar;
  final bool puedeAdministrarJerarquia;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onActualizar,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Equipo',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: ColoresApp.azulOscuro,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Rendimiento del equipo técnico',
            style: TextStyle(
              color: ColoresApp.textoSecundario,
            ),
          ),
          if (puedeAdministrarJerarquia) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          const AsignarTecnicosPantalla(),
                    ),
                  );

                  if (!context.mounted) {
                    return;
                  }

                  await onActualizar();
                },
                icon: const Icon(
                  Icons.manage_accounts_outlined,
                ),
                label: const Text(
                  'Administrar asignaciones',
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          if (tecnicos.isEmpty)
            const _EstadoVacio()
          else
            ...tecnicos.map(
              (tecnico) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TarjetaTecnico(tecnico: tecnico),
              ),
            ),
        ],
      ),
    );
  }
}

class _TarjetaTecnico extends StatelessWidget {
  const _TarjetaTecnico({
    required this.tecnico,
  });

  final VisitasPorTecnico tecnico;

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
          CircleAvatar(
            radius: 28,
            backgroundColor: ColoresApp.verdePrincipal.withValues(alpha: 0.12),
            child: Text(
              _obtenerIniciales(tecnico.nombreTecnico),
              style: const TextStyle(
                color: ColoresApp.verdePrincipal,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tecnico.nombreTecnico,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: ColoresApp.azulOscuro,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _IndicadorEstado(
                      texto: '${tecnico.completadas} completadas',
                      color: ColoresApp.exito,
                    ),
                    _IndicadorEstado(
                      texto: '${tecnico.programadas} programadas',
                      color: ColoresApp.amarillo,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              Text(
                tecnico.cantidadVisitas.toString(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: ColoresApp.azulOscuro,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Text(
                'visitas',
                style: TextStyle(
                  color: ColoresApp.textoSecundario,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _obtenerIniciales(String nombre) {
    final partes = nombre
        .trim()
        .split(' ')
        .where((parte) => parte.isNotEmpty)
        .take(2)
        .toList();

    if (partes.isEmpty) {
      return 'T';
    }

    return partes.map((parte) => parte[0].toUpperCase()).join();
  }
}

class _IndicadorEstado extends StatelessWidget {
  const _IndicadorEstado({
    required this.texto,
    required this.color,
  });

  final String texto;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
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
            Icons.groups_outlined,
            size: 54,
            color: ColoresApp.textoSecundario,
          ),
          SizedBox(height: 12),
          Text(
            'No hay actividad del equipo.',
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
