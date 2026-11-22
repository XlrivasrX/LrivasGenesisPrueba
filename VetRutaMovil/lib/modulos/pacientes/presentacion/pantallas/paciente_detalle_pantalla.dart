import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:vetruta_movil/core/red/configuracion_api.dart';
import 'package:vetruta_movil/core/tema/colores_app.dart';
import 'package:vetruta_movil/modulos/agenda/presentacion/pantallas/detalle_visita_pantalla.dart';
import 'package:vetruta_movil/modulos/pacientes/datos/modelos/historial_clinico.dart';
import 'package:vetruta_movil/modulos/pacientes/datos/modelos/paciente_detalle.dart';
import 'package:vetruta_movil/modulos/pacientes/datos/servicios/paciente_servicio.dart';
import 'package:vetruta_movil/modulos/pacientes/presentacion/controladores/paciente_detalle_controlador.dart';

class PacienteDetallePantalla extends StatelessWidget {
  const PacienteDetallePantalla({
    required this.pacienteId,
    super.key,
  });

  final int pacienteId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PacienteDetalleControlador>(
      create: (context) => PacienteDetalleControlador(
        context.read<PacienteServicio>(),
      )..cargarDetalle(pacienteId),
      child: _PacienteDetalleContenido(
        pacienteId: pacienteId,
      ),
    );
  }
}

class _PacienteDetalleContenido extends StatelessWidget {
  const _PacienteDetalleContenido({
    required this.pacienteId,
  });

  final int pacienteId;

  @override
  Widget build(BuildContext context) {
    final controlador = context.watch<PacienteDetalleControlador>();

    return Scaffold(
      backgroundColor: ColoresApp.fondo,
      appBar: AppBar(
        title: const Text('Detalle del paciente'),
      ),
      body: _construirContenido(context, controlador),
    );
  }

  Widget _construirContenido(
    BuildContext context,
    PacienteDetalleControlador controlador,
  ) {
    if (controlador.cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controlador.mensajeError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 52,
                color: ColoresApp.coral,
              ),
              const SizedBox(height: 14),
              Text(
                controlador.mensajeError!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: () {
                  controlador.cargarDetalle(pacienteId);
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Intentar nuevamente'),
              ),
            ],
          ),
        ),
      );
    }

    final paciente = controlador.paciente;

    if (paciente == null) {
      return const Center(
        child: Text('No se encontró el paciente.'),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controlador.cargarDetalle(pacienteId),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(18),
        children: [
          _EncabezadoPaciente(paciente: paciente),
          const SizedBox(height: 16),
          _SeccionPaciente(
            titulo: 'Información del paciente',
            children: [
              _DatoPaciente(
                icono: Icons.pets_outlined,
                etiqueta: 'Especie y raza',
                valor:
                    '${paciente.nombreEspecie} · ${paciente.nombreRaza}',
              ),
              if (paciente.fechaNacimientoAproximada != null)
                _DatoPaciente(
                  icono: Icons.cake_outlined,
                  etiqueta: 'Nacimiento aproximado',
                  valor: _formatearFecha(
                    paciente.fechaNacimientoAproximada!,
                  ),
                ),
              if (_tieneTexto(paciente.observaciones))
                _DatoPaciente(
                  icono: Icons.notes_outlined,
                  etiqueta: 'Observaciones',
                  valor: paciente.observaciones!,
                ),
              _DatoPaciente(
                icono: paciente.activo
                    ? Icons.check_circle_outline
                    : Icons.cancel_outlined,
                etiqueta: 'Estado',
                valor: paciente.activo ? 'Activo' : 'Inactivo',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SeccionPaciente(
            titulo: 'Propietario',
            children: [
              _DatoPaciente(
                icono: Icons.person_outline,
                etiqueta: 'Nombre',
                valor: paciente.nombrePropietario,
              ),
              _DatoPaciente(
                icono: Icons.phone_outlined,
                etiqueta: 'Teléfono',
                valor: paciente.telefonoPropietario,
              ),
              if (_tieneTexto(paciente.telefonoAlternativo))
                _DatoPaciente(
                  icono: Icons.phone_in_talk_outlined,
                  etiqueta: 'Teléfono alternativo',
                  valor: paciente.telefonoAlternativo!,
                ),
              _DatoPaciente(
                icono: Icons.home_outlined,
                etiqueta: 'Dirección',
                valor: paciente.direccion,
              ),
              if (_tieneTexto(paciente.nombreZona))
                _DatoPaciente(
                  icono: Icons.location_city_outlined,
                  etiqueta: 'Zona',
                  valor: paciente.nombreZona!,
                ),
              if (paciente.latitud != null &&
                  paciente.longitud != null)
                _DatoPaciente(
                  icono: Icons.location_on_outlined,
                  etiqueta: 'Ubicación',
                  valor:
                      '${paciente.latitud!.toStringAsFixed(6)}, '
                      '${paciente.longitud!.toStringAsFixed(6)}',
                ),
            ],
          ),
          const SizedBox(height: 16),
          _HistorialPaciente(
            historial: controlador.historial,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  static bool _tieneTexto(String? valor) {
    return valor != null && valor.trim().isNotEmpty;
  }

  static String _formatearFecha(DateTime fecha) {
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

    return '${fecha.day} de ${meses[fecha.month - 1]} '
        'de ${fecha.year}';
  }
}

class _EncabezadoPaciente extends StatelessWidget {
  const _EncabezadoPaciente({
    required this.paciente,
  });

  final PacienteDetalle paciente;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ColoresApp.verdePrincipal.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          _FotoPaciente(paciente: paciente),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  paciente.nombre,
                  style: const TextStyle(
                    color: ColoresApp.azulOscuro,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${paciente.nombreEspecie} · '
                  '${paciente.nombreRaza}',
                  style: const TextStyle(
                    color: ColoresApp.textoSecundario,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 9),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: paciente.activo
                        ? ColoresApp.exito.withValues(alpha: 0.12)
                        : ColoresApp.coral.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    paciente.activo ? 'ACTIVO' : 'INACTIVO',
                    style: TextStyle(
                      color: paciente.activo
                          ? ColoresApp.exito
                          : ColoresApp.coral,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FotoPaciente extends StatelessWidget {
  const _FotoPaciente({
    required this.paciente,
  });

  final PacienteDetalle paciente;

  @override
  Widget build(BuildContext context) {
    final rutaFoto = paciente.rutaFoto;

    if (rutaFoto == null || rutaFoto.trim().isEmpty) {
      return _fotoPredeterminada();
    }

    final url = rutaFoto.startsWith('http://') ||
            rutaFoto.startsWith('https://')
        ? rutaFoto
        : '${ConfiguracionApi.urlBase}'
            '${rutaFoto.startsWith('/') ? '' : '/'}'
            '$rutaFoto';

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.network(
        url,
        width: 82,
        height: 82,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _fotoPredeterminada(),
      ),
    );
  }

  Widget _fotoPredeterminada() {
    return Container(
      width: 82,
      height: 82,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Icon(
        Icons.pets_rounded,
        size: 42,
        color: ColoresApp.verdePrincipal,
      ),
    );
  }
}

class _SeccionPaciente extends StatelessWidget {
  const _SeccionPaciente({
    required this.titulo,
    required this.children,
  });

  final String titulo;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      decoration: BoxDecoration(
        color: ColoresApp.superficie,
        border: Border.all(color: ColoresApp.borde),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: ColoresApp.azulOscuro,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _DatoPaciente extends StatelessWidget {
  const _DatoPaciente({
    required this.icono,
    required this.etiqueta,
    required this.valor,
  });

  final IconData icono;
  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icono,
            color: ColoresApp.verdePrincipal,
            size: 24,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  etiqueta,
                  style: const TextStyle(
                    color: ColoresApp.textoSecundario,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  valor,
                  style: const TextStyle(
                    color: ColoresApp.azulOscuro,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistorialPaciente extends StatelessWidget {
  const _HistorialPaciente({
    required this.historial,
  });

  final List<HistorialClinico> historial;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Historial clínico',
            style: TextStyle(
              color: ColoresApp.azulOscuro,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          if (historial.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: Text(
                  'Este paciente todavía no tiene atenciones registradas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ColoresApp.textoSecundario,
                  ),
                ),
              ),
            )
          else
            ...historial.map(
              (atencion) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TarjetaHistorial(
                  atencion: atencion,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TarjetaHistorial extends StatelessWidget {
  const _TarjetaHistorial({
    required this.atencion,
  });

  final HistorialClinico atencion;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColoresApp.verdePrincipal.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => DetalleVisitaPantalla(
                visitaId: atencion.visitaId,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: ColoresApp.verdePrincipal.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.medical_services_outlined,
                  color: ColoresApp.verdePrincipal,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      atencion.nombreServicio,
                      style: const TextStyle(
                        color: ColoresApp.azulOscuro,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _formatearFechaHora(atencion.fechaRegistro),
                      style: const TextStyle(
                        color: ColoresApp.textoSecundario,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Médico: ${atencion.nombreMedico}',
                      style: const TextStyle(
                        color: ColoresApp.azulOscuro,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Técnico: ${atencion.nombreTecnico}',
                      style: const TextStyle(
                        color: ColoresApp.textoSecundario,
                      ),
                    ),
                    if (atencion.temperaturaCelsius != null)
                      Text(
                        'Temperatura: '
                        '${atencion.temperaturaCelsius} °C',
                        style: const TextStyle(
                          color: ColoresApp.textoSecundario,
                        ),
                      ),
                    if (atencion.cantidadEvidencias > 0) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.photo_camera_outlined,
                            size: 18,
                            color: ColoresApp.verdePrincipal,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${atencion.cantidadEvidencias} '
                            '${atencion.cantidadEvidencias == 1 ? 'evidencia' : 'evidencias'}',
                            style: const TextStyle(
                              color: ColoresApp.verdePrincipal,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: ColoresApp.textoSecundario,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatearFechaHora(DateTime fecha) {
    const meses = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];

    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');

    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}'
        ' · $hora:$minuto';
  }
}
