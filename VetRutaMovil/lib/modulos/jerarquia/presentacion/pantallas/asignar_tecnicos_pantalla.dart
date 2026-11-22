import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:vetruta_movil/core/tema/colores_app.dart';
import 'package:vetruta_movil/modulos/jerarquia/datos/modelos/usuario_jerarquia.dart';
import 'package:vetruta_movil/modulos/jerarquia/datos/servicios/jerarquia_servicio.dart';
import 'package:vetruta_movil/modulos/jerarquia/presentacion/controladores/jerarquia_controlador.dart';

class AsignarTecnicosPantalla extends StatelessWidget {
  const AsignarTecnicosPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<JerarquiaControlador>(
      create: (context) =>
          JerarquiaControlador(context.read<JerarquiaServicio>())..cargar(),
      child: const _AsignarTecnicosContenido(),
    );
  }
}

class _AsignarTecnicosContenido extends StatelessWidget {
  const _AsignarTecnicosContenido();

  @override
  Widget build(BuildContext context) {
    final controlador = context.watch<JerarquiaControlador>();

    return Scaffold(
      backgroundColor: ColoresApp.fondo,
      appBar: AppBar(title: const Text('Asignar técnicos')),
      body: controlador.cargando && controlador.medicos.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: controlador.cargar,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(18),
                children: [
                  const Text(
                    'Jerarquía del equipo',
                    style: TextStyle(
                      color: ColoresApp.azulOscuro,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Asigna o reasigna técnicos a los médicos.',
                    style: TextStyle(color: ColoresApp.textoSecundario),
                  ),
                  const SizedBox(height: 20),
                  _FormularioAsignacion(controlador: controlador),
                  if (controlador.mensajeError != null) ...[
                    const SizedBox(height: 14),
                    _Mensaje(
                      mensaje: controlador.mensajeError!,
                      color: ColoresApp.coral,
                      icono: Icons.error_outline,
                    ),
                  ],
                  if (controlador.mensajeExito != null) ...[
                    const SizedBox(height: 14),
                    _Mensaje(
                      mensaje: controlador.mensajeExito!,
                      color: ColoresApp.exito,
                      icono: Icons.check_circle_outline,
                    ),
                  ],
                  const SizedBox(height: 22),
                  const Text(
                    'Técnicos asignados',
                    style: TextStyle(
                      color: ColoresApp.azulOscuro,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (controlador.cargando)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (controlador.tecnicosAsignados.isEmpty)
                    const _EstadoVacio()
                  else
                    ...controlador.tecnicosAsignados.map(
                      (tecnico) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _TarjetaTecnico(tecnico: tecnico),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _FormularioAsignacion extends StatelessWidget {
  const _FormularioAsignacion({required this.controlador});

  final JerarquiaControlador controlador;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ColoresApp.superficie,
        border: Border.all(color: ColoresApp.borde),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          DropdownButtonFormField<int>(
            key: ValueKey(
              'medico-${controlador.medicoSeleccionadoId}',
            ),
            initialValue: controlador.medicoSeleccionadoId,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Médico',
              prefixIcon: Icon(Icons.medical_services_outlined),
            ),
            items: controlador.medicos
                .map(
                  (medico) => DropdownMenuItem<int>(
                    value: medico.usuarioId,
                    child: Text(
                      medico.nombreCompleto,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: controlador.cargando
                ? null
                : controlador.seleccionarMedico,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            key: ValueKey(
              'tecnico-${controlador.tecnicoSeleccionadoId}',
            ),
            initialValue: controlador.tecnicoSeleccionadoId,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Técnico',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
            items: controlador.tecnicos
                .map(
                  (tecnico) => DropdownMenuItem<int>(
                    value: tecnico.usuarioId,
                    child: Text(
                      tecnico.nombreCompleto,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: controlador.guardando
                ? null
                : controlador.seleccionarTecnico,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: controlador.guardando
                  ? null
                  : controlador.asignarTecnico,
              icon: controlador.guardando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.person_add_alt_1),
              label: Text(
                controlador.guardando ? 'Asignando...' : 'Asignar técnico',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaTecnico extends StatelessWidget {
  const _TarjetaTecnico({required this.tecnico});

  final TecnicoAsignado tecnico;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: ColoresApp.superficie,
        border: Border.all(color: ColoresApp.borde),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: ColoresApp.verdePrincipal.withValues(alpha: 0.12),
            child: Text(
              _obtenerIniciales(tecnico.nombreCompleto),
              style: const TextStyle(
                color: ColoresApp.verdePrincipal,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tecnico.nombreCompleto,
                  style: const TextStyle(
                    color: ColoresApp.azulOscuro,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  tecnico.nombreUsuario,
                  style: const TextStyle(color: ColoresApp.textoSecundario),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: ColoresApp.exito),
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

class _Mensaje extends StatelessWidget {
  const _Mensaje({
    required this.mensaje,
    required this.color,
    required this.icono,
  });

  final String mensaje;
  final Color color;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icono, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mensaje,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _EstadoVacio extends StatelessWidget {
  const _EstadoVacio();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 36),
      child: Center(
        child: Text(
          'El médico seleccionado no tiene técnicos asignados.',
          textAlign: TextAlign.center,
          style: TextStyle(color: ColoresApp.textoSecundario),
        ),
      ),
    );
  }
}
