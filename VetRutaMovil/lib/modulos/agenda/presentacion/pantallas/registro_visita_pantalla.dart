import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:vetruta_movil/core/tema/colores_app.dart';
import 'package:vetruta_movil/modulos/agenda/datos/modelos/detalle_visita.dart';
import 'package:vetruta_movil/modulos/agenda/datos/servicios/agenda_servicio.dart';
import 'package:vetruta_movil/modulos/agenda/presentacion/controladores/agenda_controlador.dart';
import 'package:vetruta_movil/modulos/agenda/presentacion/controladores/registro_visita_controlador.dart';

class RegistroVisitaPantalla extends StatelessWidget {
  const RegistroVisitaPantalla({
    required this.detalle,
    super.key,
  });

  final DetalleVisita detalle;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RegistroVisitaControlador>(
      create: (context) => RegistroVisitaControlador(
        context.read<AgendaServicio>(),
      ),
      child: _RegistroVisitaContenido(detalle: detalle),
    );
  }
}

class _RegistroVisitaContenido extends StatefulWidget {
  const _RegistroVisitaContenido({
    required this.detalle,
  });

  final DetalleVisita detalle;

  @override
  State<_RegistroVisitaContenido> createState() =>
      _RegistroVisitaContenidoState();
}

class _RegistroVisitaContenidoState
    extends State<_RegistroVisitaContenido> {
  final _formularioClave = GlobalKey<FormState>();
  final _pesoControlador = TextEditingController();
  final _alturaControlador = TextEditingController();
  final _temperaturaControlador = TextEditingController();
  final _observacionesControlador = TextEditingController();

  String? _condicionCorporal;

  @override
  void dispose() {
    _pesoControlador.dispose();
    _alturaControlador.dispose();
    _temperaturaControlador.dispose();
    _observacionesControlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controlador = context.watch<RegistroVisitaControlador>();

    return Scaffold(
      backgroundColor: ColoresApp.fondo,
      appBar: AppBar(
        title: const Text('Registrar visita'),
      ),
      body: Form(
        key: _formularioClave,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            _EncabezadoRegistro(detalle: widget.detalle),
            const SizedBox(height: 18),
            _SeccionFormulario(
              titulo: 'Datos de la atención',
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _campoDecimal(
                        controlador: _pesoControlador,
                        etiqueta: 'Peso',
                        sufijo: 'kg',
                        icono: Icons.monitor_weight_outlined,
                        mayorQueCero: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _campoDecimal(
                        controlador: _alturaControlador,
                        etiqueta: 'Altura',
                        sufijo: 'cm',
                        icono: Icons.height,
                        mayorQueCero: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _campoDecimal(
                  controlador: _temperaturaControlador,
                  etiqueta: 'Temperatura',
                  sufijo: '°C',
                  icono: Icons.thermostat_outlined,
                  valorMinimo: 0,
                  valorMaximo: 100,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _condicionCorporal,
                  decoration: _decoracionCampo(
                    etiqueta: 'Condición corporal',
                    icono: Icons.checklist_outlined,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Muy delgada',
                      child: Text('Muy delgada'),
                    ),
                    DropdownMenuItem(
                      value: 'Delgada',
                      child: Text('Delgada'),
                    ),
                    DropdownMenuItem(
                      value: 'Normal',
                      child: Text('Normal'),
                    ),
                    DropdownMenuItem(
                      value: 'Buena',
                      child: Text('Buena'),
                    ),
                    DropdownMenuItem(
                      value: 'Sobrepeso',
                      child: Text('Sobrepeso'),
                    ),
                    DropdownMenuItem(
                      value: 'Obesa',
                      child: Text('Obesa'),
                    ),
                  ],
                  onChanged: controlador.guardando
                      ? null
                      : (valor) {
                          setState(() {
                            _condicionCorporal = valor;
                          });
                        },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _observacionesControlador,
                  enabled: !controlador.guardando,
                  maxLines: 4,
                  maxLength: 1000,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _decoracionCampo(
                    etiqueta: 'Observaciones',
                    icono: Icons.notes_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SeccionFormulario(
              titulo: 'Evidencia y ubicación',
              children: [
                _FotografiaEvidencia(controlador: controlador),
                const SizedBox(height: 16),
                _UbicacionEvidencia(controlador: controlador),
              ],
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
                    : () => _finalizarVisita(controlador),
                style: FilledButton.styleFrom(
                  backgroundColor: ColoresApp.coral,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: controlador.guardando
                    ? const SizedBox(
                        width: 21,
                        height: 21,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text(
                  controlador.guardando
                      ? 'Guardando...'
                      : 'Finalizar visita',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 17,
                  color: ColoresApp.textoSecundario,
                ),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'La visita quedará guardada en el historial.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ColoresApp.textoSecundario,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _campoDecimal({
    required TextEditingController controlador,
    required String etiqueta,
    required IconData icono,
    String? sufijo,
    bool mayorQueCero = false,
    double? valorMinimo,
    double? valorMaximo,
  }) {
    return TextFormField(
      controller: controlador,
      enabled: !context.watch<RegistroVisitaControlador>().guardando,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ),
      decoration: _decoracionCampo(
        etiqueta: etiqueta,
        icono: icono,
        sufijo: sufijo,
      ),
      validator: (valor) {
        final texto = valor?.trim();

        if (texto == null || texto.isEmpty) {
          return null;
        }

        final numero = double.tryParse(
          texto.replaceAll(',', '.'),
        );

        if (numero == null) {
          return 'Valor inválido';
        }

        if (mayorQueCero && numero <= 0) {
          return 'Debe ser mayor que 0';
        }

        if (valorMinimo != null && numero < valorMinimo) {
          return 'Mínimo $valorMinimo';
        }

        if (valorMaximo != null && numero > valorMaximo) {
          return 'Máximo $valorMaximo';
        }

        return null;
      },
    );
  }

  InputDecoration _decoracionCampo({
    required String etiqueta,
    required IconData icono,
    String? sufijo,
  }) {
    return InputDecoration(
      labelText: etiqueta,
      suffixText: sufijo,
      prefixIcon: Icon(icono),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  double? _convertirNumero(TextEditingController controlador) {
    final texto = controlador.text.trim();

    if (texto.isEmpty) {
      return null;
    }

    return double.tryParse(texto.replaceAll(',', '.'));
  }

  Future<void> _finalizarVisita(
    RegistroVisitaControlador controlador,
  ) async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!(_formularioClave.currentState?.validate() ?? false)) {
      return;
    }

    final exito = await controlador.registrarVisita(
      visitaId: widget.detalle.visitaId,
      pesoKg: _convertirNumero(_pesoControlador),
      alturaCm: _convertirNumero(_alturaControlador),
      temperaturaCelsius:
          _convertirNumero(_temperaturaControlador),
      condicionCorporal: _condicionCorporal,
      observaciones: _observacionesControlador.text,
    );

    if (!mounted || !exito) {
      return;
    }

    await context.read<AgendaControlador>().cargarAgenda();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop(true);
  }
}

class _EncabezadoRegistro extends StatelessWidget {
  const _EncabezadoRegistro({
    required this.detalle,
  });

  final DetalleVisita detalle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColoresApp.verdePrincipal.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
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
              Icons.pets_rounded,
              size: 38,
              color: ColoresApp.verdePrincipal,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detalle.nombrePaciente,
                  style: const TextStyle(
                    color: ColoresApp.azulOscuro,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${detalle.nombreEspecie} · '
                  '${detalle.nombreRaza}',
                  style: const TextStyle(
                    color: ColoresApp.textoSecundario,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detalle.nombreServicio,
                  style: const TextStyle(
                    color: ColoresApp.verdePrincipal,
                    fontWeight: FontWeight.w700,
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

class _SeccionFormulario extends StatelessWidget {
  const _SeccionFormulario({
    required this.titulo,
    required this.children,
  });

  final String titulo;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
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
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _FotografiaEvidencia extends StatelessWidget {
  const _FotografiaEvidencia({
    required this.controlador,
  });

  final RegistroVisitaControlador controlador;

  @override
  Widget build(BuildContext context) {
    final fotografia = controlador.fotografia;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (fotografia != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: FutureBuilder<Uint8List>(
              future: fotografia.readAsBytes(),
              builder: (context, resultado) {
                if (!resultado.hasData) {
                  return const SizedBox(
                    height: 180,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                return Image.memory(
                  resultado.data!,
                  height: 180,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          const SizedBox(height: 10),
        ],
        OutlinedButton.icon(
          onPressed: controlador.tomandoFotografia ||
                  controlador.guardando
              ? null
              : controlador.tomarFotografia,
          icon: controlador.tomandoFotografia
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : Icon(
                  fotografia == null
                      ? Icons.camera_alt_outlined
                      : Icons.refresh_rounded,
                ),
          label: Text(
            fotografia == null
                ? 'Tomar fotografía'
                : 'Tomar otra fotografía',
          ),
        ),
        if (fotografia != null)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: ColoresApp.exito,
                  size: 19,
                ),
                SizedBox(width: 6),
                Text(
                  'Fotografía agregada',
                  style: TextStyle(
                    color: ColoresApp.exito,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _UbicacionEvidencia extends StatelessWidget {
  const _UbicacionEvidencia({
    required this.controlador,
  });

  final RegistroVisitaControlador controlador;

  @override
  Widget build(BuildContext context) {
    final posicion = controlador.posicion;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: controlador.obteniendoUbicacion ||
                  controlador.guardando
              ? null
              : controlador.obtenerUbicacion,
          icon: controlador.obteniendoUbicacion
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : Icon(
                  posicion == null
                      ? Icons.location_on_outlined
                      : Icons.refresh_rounded,
                ),
          label: Text(
            posicion == null
                ? 'Verificar ubicación'
                : 'Actualizar ubicación',
          ),
        ),
        if (posicion != null)
          Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColoresApp.exito.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: ColoresApp.exito,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Ubicación verificada\n'
                    '${posicion.latitude.toStringAsFixed(6)}, '
                    '${posicion.longitude.toStringAsFixed(6)}',
                    style: const TextStyle(
                      color: ColoresApp.exito,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _MensajeError extends StatelessWidget {
  const _MensajeError({
    required this.mensaje,
  });

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: ColoresApp.coral.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline,
            color: ColoresApp.coral,
          ),
          const SizedBox(width: 9),
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