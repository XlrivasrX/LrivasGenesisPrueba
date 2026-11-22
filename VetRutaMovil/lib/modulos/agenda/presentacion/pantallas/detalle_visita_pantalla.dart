import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:vetruta_movil/modulos/agenda/datos/modelos/detalle_visita.dart';
import 'package:vetruta_movil/modulos/agenda/datos/modelos/evidencia_visita.dart';
import 'package:vetruta_movil/modulos/agenda/datos/servicios/agenda_servicio.dart';
import 'package:vetruta_movil/modulos/agenda/presentacion/controladores/detalle_visita_controlador.dart';
import 'package:vetruta_movil/modulos/agenda/presentacion/pantallas/registro_visita_pantalla.dart';

class DetalleVisitaPantalla extends StatelessWidget {
  const DetalleVisitaPantalla({
    required this.visitaId,
    super.key,
  });

  final int visitaId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DetalleVisitaControlador>(
      create: (context) => DetalleVisitaControlador(
        context.read<AgendaServicio>(),
      )..cargarDetalle(visitaId),
      child: _DetalleVisitaContenido(visitaId: visitaId),
    );
  }
}

class _DetalleVisitaContenido extends StatelessWidget {
  const _DetalleVisitaContenido({
    required this.visitaId,
  });

  final int visitaId;

  @override
  Widget build(BuildContext context) {
    final controlador = context.watch<DetalleVisitaControlador>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF073B61),
        foregroundColor: Colors.white,
        title: const Text(
          'Detalle de visita',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: _construirContenido(context, controlador),
    );
  }

  Widget _construirContenido(
    BuildContext context,
    DetalleVisitaControlador controlador,
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
                color: Color(0xFFFF5252),
              ),
              const SizedBox(height: 16),
              Text(
                controlador.mensajeError!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () => controlador.cargarDetalle(visitaId),
                icon: const Icon(Icons.refresh),
                label: const Text('Intentar nuevamente'),
              ),
            ],
          ),
        ),
      );
    }

    final detalle = controlador.detalle;

    if (detalle == null) {
      return const Center(
        child: Text('No se encontró la visita.'),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controlador.cargarDetalle(visitaId),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          _EncabezadoPaciente(detalle: detalle),
          const SizedBox(height: 18),
          _SeccionDetalle(
            titulo: 'Información de la visita',
            children: [
              _DatoDetalle(
                icono: Icons.medical_services_outlined,
                etiqueta: 'Servicio',
                valor: detalle.nombreServicio,
              ),
              _DatoDetalle(
                icono: Icons.calendar_today_outlined,
                etiqueta: 'Fecha programada',
                valor: _formatearFechaHora(detalle.fechaProgramada),
              ),
              _DatoDetalle(
                icono: Icons.payments_outlined,
                etiqueta: 'Precio programado',
                valor: 'Q${detalle.precioProgramado.toStringAsFixed(2)}',
              ),
              if (_tieneTexto(detalle.observacionesProgramacion))
                _DatoDetalle(
                  icono: Icons.notes_outlined,
                  etiqueta: 'Observaciones',
                  valor: detalle.observacionesProgramacion!,
                ),
            ],
          ),
          const SizedBox(height: 16),
          _SeccionDetalle(
            titulo: 'Propietario',
            children: [
              _DatoDetalle(
                icono: Icons.person_outline,
                etiqueta: 'Nombre',
                valor: detalle.nombrePropietario,
              ),
              _DatoDetalle(
                icono: Icons.phone_outlined,
                etiqueta: 'Teléfono',
                valor: detalle.telefonoPropietario,
              ),
              if (_tieneTexto(detalle.telefonoAlternativo))
                _DatoDetalle(
                  icono: Icons.phone_in_talk_outlined,
                  etiqueta: 'Teléfono alternativo',
                  valor: detalle.telefonoAlternativo!,
                ),
              _DatoDetalle(
                icono: Icons.home_outlined,
                etiqueta: 'Dirección',
                valor: detalle.direccion,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SeccionDetalle(
            titulo: 'Personal asignado',
            children: [
              if (_tieneTexto(detalle.nombreMedico))
                _DatoDetalle(
                  icono: Icons.health_and_safety_outlined,
                  etiqueta: 'Médico responsable',
                  valor: detalle.nombreMedico!,
                ),
              if (_tieneTexto(detalle.nombreTecnico))
                _DatoDetalle(
                  icono: Icons.badge_outlined,
                  etiqueta: 'Técnico',
                  valor: detalle.nombreTecnico!,
                ),
            ],
          ),
          if (detalle.completada) ...[
            const SizedBox(height: 16),
            _SeccionDetalle(
              titulo: 'Atención realizada',
              children: [
                if (detalle.pesoKg != null)
                  _DatoDetalle(
                    icono: Icons.monitor_weight_outlined,
                    etiqueta: 'Peso',
                    valor: '${detalle.pesoKg} kg',
                  ),
                if (detalle.alturaCm != null)
                  _DatoDetalle(
                    icono: Icons.height,
                    etiqueta: 'Altura',
                    valor: '${detalle.alturaCm} cm',
                  ),
                if (detalle.temperaturaCelsius != null)
                  _DatoDetalle(
                    icono: Icons.thermostat_outlined,
                    etiqueta: 'Temperatura',
                    valor: '${detalle.temperaturaCelsius} °C',
                  ),
                if (_tieneTexto(detalle.condicionCorporal))
                  _DatoDetalle(
                    icono: Icons.checklist_outlined,
                    etiqueta: 'Condición corporal',
                    valor: detalle.condicionCorporal!,
                  ),
                if (_tieneTexto(detalle.observacionesAtencion))
                  _DatoDetalle(
                    icono: Icons.description_outlined,
                    etiqueta: 'Observaciones de atención',
                    valor: detalle.observacionesAtencion!,
                  ),
              ],
            ),
          ],
          if (controlador.evidencias.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SeccionEvidencias(
              evidencias: controlador.evidencias,
              archivos: controlador.archivosEvidencia,
            ),
          ],
          if (!detalle.completada) ...[
            const SizedBox(height: 20),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: () async {
                  final registrada = await Navigator.of(context).push<bool>(
                    MaterialPageRoute<bool>(
                      builder: (_) => RegistroVisitaPantalla(
                        detalle: detalle,
                      ),
                    ),
                  );

                  if (!context.mounted || registrada != true) {
                    return;
                  }

                  await controlador.cargarDetalle(visitaId);

                  if (!context.mounted) {
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Visita registrada correctamente.',
                      ),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5252),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.add_rounded),
                label: const Text(
                  'Registrar visita',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  static bool _tieneTexto(String? valor) {
    return valor != null && valor.trim().isNotEmpty;
  }

  static String _formatearFechaHora(DateTime fecha) {
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

    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');

    return '${fecha.day} de ${meses[fecha.month - 1]} de ${fecha.year}, '
        '$hora:$minuto';
  }
}

class _EncabezadoPaciente extends StatelessWidget {
  const _EncabezadoPaciente({
    required this.detalle,
  });

  final DetalleVisita detalle;

  @override
  Widget build(BuildContext context) {
    final colorEstado = _obtenerColorEstado(detalle);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F7F3),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.pets,
              size: 38,
              color: Color(0xFF00A88F),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detalle.nombrePaciente,
                  style: const TextStyle(
                    color: Color(0xFF073B61),
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${detalle.nombreEspecie} · ${detalle.nombreRaza}',
                  style: const TextStyle(
                    color: Color(0xFF5F666D),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorEstado.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    detalle.estado,
                    style: TextStyle(
                      color: colorEstado,
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

  Color _obtenerColorEstado(DetalleVisita detalle) {
    final estado = detalle.estado.toUpperCase();

    if (detalle.completada ||
        estado == 'COMPLETADA' ||
        estado == 'REALIZADA') {
      return const Color(0xFF18A957);
    }

    if (estado == 'ATRASADA') {
      return const Color(0xFFFF5252);
    }

    return const Color(0xFFF2A900);
  }
}

class _SeccionDetalle extends StatelessWidget {
  const _SeccionDetalle({
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
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0E3E7)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: Color(0xFF073B61),
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

class _DatoDetalle extends StatelessWidget {
  const _DatoDetalle({
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
            color: const Color(0xFF00A88F),
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
                    color: Color(0xFF737A80),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  valor,
                  style: const TextStyle(
                    color: Color(0xFF073B61),
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

class _SeccionEvidencias extends StatelessWidget {
  const _SeccionEvidencias({
    required this.evidencias,
    required this.archivos,
  });

  final List<EvidenciaVisita> evidencias;
  final Map<int, Uint8List> archivos;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0E3E7)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Evidencia fotográfica',
            style: TextStyle(
              color: Color(0xFF073B61),
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 190,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: evidencias.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return _FotoEvidencia(
                  bytes: archivos[evidencias[index].evidenciaVisitaId],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FotoEvidencia extends StatelessWidget {
  const _FotoEvidencia({
    required this.bytes,
  });

  final Uint8List? bytes;

  @override
  Widget build(BuildContext context) {
    final archivo = bytes;

    if (archivo == null) {
      return _errorFotografia();
    }

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _mostrarFoto(context, archivo),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.memory(
          archivo,
          width: 230,
          height: 190,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _errorFotografia(),
        ),
      ),
    );
  }

  Widget _errorFotografia() {
    return Container(
      width: 230,
      height: 190,
      color: const Color(0xFFE9EEF2),
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.broken_image_outlined,
            color: Color(0xFF737A80),
            size: 42,
          ),
          SizedBox(height: 8),
          Text(
            'No fue posible cargar la fotografía',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _mostrarFoto(BuildContext context, Uint8List archivo) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              InteractiveViewer(
                minScale: 0.8,
                maxScale: 4,
                child: Image.memory(
                  archivo,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) {
                    return const SizedBox(
                      height: 300,
                      child: Center(
                        child: Text(
                          'No fue posible cargar la fotografía.',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton.filled(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
