import 'dart:async';
import 'dart:typed_data';

import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:vetruta_movil/core/tema/colores_app.dart';
import 'package:vetruta_movil/modulos/pacientes/datos/servicios/paciente_servicio.dart';
import 'package:vetruta_movil/modulos/pacientes/presentacion/controladores/crear_paciente_controlador.dart';

class CrearPacientePantalla extends StatelessWidget {
  const CrearPacientePantalla({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CrearPacienteControlador>(
      create: (context) =>
          CrearPacienteControlador(context.read<PacienteServicio>())
            ..cargarCatalogos(),
      child: const _CrearPacienteFormulario(),
    );
  }
}

class _CrearPacienteFormulario extends StatefulWidget {
  const _CrearPacienteFormulario();

  @override
  State<_CrearPacienteFormulario> createState() =>
      _CrearPacienteFormularioState();
}

class _CrearPacienteFormularioState extends State<_CrearPacienteFormulario> {
  final _nombresPropietario = TextEditingController();
  final _apellidosPropietario = TextEditingController();
  final _telefono = TextEditingController();
  final _telefonoAlternativo = TextEditingController();
  final _direccion = TextEditingController();
  final _nombrePaciente = TextEditingController();
  final _observaciones = TextEditingController();
  final _selectorImagen = ImagePicker();

  DateTime? _fechaNacimiento;
  XFile? _fotoPaciente;
  Uint8List? _fotoPacienteBytes;
  double? _latitud;
  double? _longitud;
  bool _obteniendoUbicacion = false;

  @override
  void dispose() {
    _nombresPropietario.dispose();
    _apellidosPropietario.dispose();
    _telefono.dispose();
    _telefonoAlternativo.dispose();
    _direccion.dispose();
    _nombrePaciente.dispose();
    _observaciones.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controlador = context.watch<CrearPacienteControlador>();

    return Scaffold(
      backgroundColor: ColoresApp.fondo,
      appBar: AppBar(title: const Text('Nuevo paciente')),
      body: controlador.cargando && controlador.especies.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(18),
              children: [
                _SeccionFormulario(
                  titulo: 'Datos del propietario',
                  children: [
                    TextField(
                      controller: _nombresPropietario,
                      enabled: !controlador.guardando,
                      decoration: const InputDecoration(
                        labelText: 'Nombres',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _apellidosPropietario,
                      enabled: !controlador.guardando,
                      decoration: const InputDecoration(
                        labelText: 'Apellidos',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _telefono,
                      enabled: !controlador.guardando,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _telefonoAlternativo,
                      enabled: !controlador.guardando,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono alternativo',
                        prefixIcon: Icon(Icons.phone_in_talk_outlined),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _direccion,
                      enabled: !controlador.guardando,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Dirección',
                        prefixIcon: Icon(Icons.home_outlined),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: controlador.guardando || _obteniendoUbicacion
                            ? null
                            : _obtenerUbicacion,
                        icon: _obteniendoUbicacion
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                _latitud == null
                                    ? Icons.my_location_outlined
                                    : Icons.location_on,
                              ),
                        label: Text(
                          _obteniendoUbicacion
                              ? 'Obteniendo ubicación...'
                              : _latitud == null
                              ? 'Usar ubicación actual'
                              : 'Ubicación registrada',
                        ),
                      ),
                    ),
                    if (_latitud != null && _longitud != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        '${_latitud!.toStringAsFixed(6)}, '
                        '${_longitud!.toStringAsFixed(6)}',
                        style: const TextStyle(
                          color: ColoresApp.textoSecundario,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                _SeccionFormulario(
                  titulo: 'Datos del paciente',
                  children: [
                    _SelectorFotoPaciente(
                      bytes: _fotoPacienteBytes,
                      habilitado: !controlador.guardando,
                      onCamara: () => _seleccionarFoto(ImageSource.camera),
                      onGaleria: () => _seleccionarFoto(ImageSource.gallery),
                      onQuitar: _quitarFoto,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nombrePaciente,
                      enabled: !controlador.guardando,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la mascota',
                        prefixIcon: Icon(Icons.pets_outlined),
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<int>(
                      initialValue: controlador.especieId,
                      decoration: const InputDecoration(
                        labelText: 'Especie',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: controlador.especies
                          .map(
                            (especie) => DropdownMenuItem<int>(
                              value: especie.especieId,
                              child: Text(especie.nombre),
                            ),
                          )
                          .toList(),
                      onChanged: controlador.guardando
                          ? null
                          : controlador.seleccionarEspecie,
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<int>(
                      key: ValueKey('razas-${controlador.especieId}'),
                      initialValue: controlador.razaId,
                      decoration: const InputDecoration(
                        labelText: 'Raza',
                        prefixIcon: Icon(Icons.pets_rounded),
                      ),
                      items: controlador.razas
                          .map(
                            (raza) => DropdownMenuItem<int>(
                              value: raza.razaId,
                              child: Text(raza.nombre),
                            ),
                          )
                          .toList(),
                      onChanged: controlador.guardando
                          ? null
                          : controlador.seleccionarRaza,
                    ),
                    const SizedBox(height: 14),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.cake_outlined,
                        color: ColoresApp.verdePrincipal,
                      ),
                      title: const Text('Fecha de nacimiento aproximada'),
                      subtitle: Text(
                        _fechaNacimiento == null
                            ? 'No seleccionada'
                            : _formatearFecha(_fechaNacimiento!),
                      ),
                      trailing: const Icon(Icons.calendar_month_outlined),
                      onTap: controlador.guardando ? null : _seleccionarFecha,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _observaciones,
                      enabled: !controlador.guardando,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Observaciones',
                        prefixIcon: Icon(Icons.notes_outlined),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SeccionFormulario(
                  titulo: 'Técnico responsable',
                  children: [
                    if (controlador.tecnicos.isEmpty)
                      const Text(
                        'No tienes técnicos asignados. Solicita al '
                        'director que configure tu equipo.',
                        style: TextStyle(color: ColoresApp.coral),
                      )
                    else
                      DropdownButtonFormField<int>(
                        initialValue: controlador.tecnicoUsuarioId,
                        decoration: const InputDecoration(
                          labelText: 'Técnico',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        items: controlador.tecnicos
                            .map(
                              (tecnico) => DropdownMenuItem<int>(
                                value: tecnico.usuarioSubordinadoId,
                                child: Text(tecnico.nombreCompleto),
                              ),
                            )
                            .toList(),
                        onChanged: controlador.guardando
                            ? null
                            : controlador.seleccionarTecnico,
                      ),
                  ],
                ),
                if (controlador.mensajeError != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: ColoresApp.coral.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: ColoresApp.coral,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            controlador.mensajeError!,
                            style: const TextStyle(color: ColoresApp.coral),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  height: 54,
                  child: FilledButton.icon(
                    onPressed:
                        controlador.guardando || controlador.tecnicos.isEmpty
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
                        : const Icon(Icons.save_outlined),
                    label: Text(
                      controlador.guardando
                          ? 'Guardando...'
                          : 'Crear y asignar paciente',
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }

  Future<void> _seleccionarFecha() async {
    final ahora = DateTime.now();

    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? ahora,
      firstDate: DateTime(1990),
      lastDate: ahora,
    );

    if (fecha != null) {
      setState(() {
        _fechaNacimiento = fecha;
      });
    }
  }

  Future<void> _guardar(CrearPacienteControlador controlador) async {
    if (_latitud == null || _longitud == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Registra la ubicación para que las visitas aparezcan en el mapa.',
          ),
        ),
      );
      return;
    }

    final creado = await controlador.crearPaciente(
      nombresPropietario: _nombresPropietario.text,
      apellidosPropietario: _apellidosPropietario.text,
      telefono: _telefono.text,
      telefonoAlternativo: _telefonoAlternativo.text,
      direccion: _direccion.text,
      nombrePaciente: _nombrePaciente.text,
      fechaNacimiento: _fechaNacimiento,
      observaciones: _observaciones.text,
      latitud: _latitud,
      longitud: _longitud,
      fotoPaciente: _fotoPaciente,
    );

    if (!mounted || !creado) {
      return;
    }

    Navigator.of(context).pop(true);
  }

  String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');

    return '$dia/$mes/${fecha.year}';
  }

  Future<void> _seleccionarFoto(ImageSource origen) async {
    try {
      final foto = await _selectorImagen.pickImage(
        source: origen,
        imageQuality: 85,
        maxWidth: 1600,
      );

      if (foto == null) {
        return;
      }

      final bytes = await foto.readAsBytes();
      if (bytes.isEmpty || bytes.length > 10 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Selecciona una imagen válida de máximo 10 MB.'),
            ),
          );
        }
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _fotoPaciente = foto;
        _fotoPacienteBytes = bytes;
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No fue posible seleccionar la fotografía.'),
          ),
        );
      }
    }
  }

  void _quitarFoto() {
    setState(() {
      _fotoPaciente = null;
      _fotoPacienteBytes = null;
    });
  }

  Future<void> _obtenerUbicacion() async {
    if (_obteniendoUbicacion) {
      return;
    }

    setState(() {
      _obteniendoUbicacion = true;
    });

    String? mensajeError;

    try {
      final servicioHabilitado = await Geolocator.isLocationServiceEnabled();

      if (!servicioHabilitado) {
        mensajeError = 'Activa la ubicación del dispositivo.';
      } else {
        var permiso = await Geolocator.checkPermission();

        if (permiso == LocationPermission.denied) {
          permiso = await Geolocator.requestPermission();
        }

        if (permiso == LocationPermission.denied) {
          mensajeError = 'Debes permitir el acceso a la ubicación.';
        } else if (permiso == LocationPermission.deniedForever) {
          mensajeError =
              'El permiso está bloqueado. Habilítalo desde la configuración.';
        } else {
          final posicion = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 20),
            ),
          );

          if (mounted) {
            setState(() {
              _latitud = posicion.latitude;
              _longitud = posicion.longitude;
            });
          }
        }
      }
    } on TimeoutException {
      mensajeError = 'No fue posible obtener la ubicación a tiempo.';
    } catch (_) {
      mensajeError = 'No fue posible obtener la ubicación.';
    } finally {
      if (mounted) {
        setState(() {
          _obteniendoUbicacion = false;
        });
      }
    }

    if (mounted && mensajeError != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(mensajeError)));
    }
  }
}

class _SelectorFotoPaciente extends StatelessWidget {
  const _SelectorFotoPaciente({
    required this.bytes,
    required this.habilitado,
    required this.onCamara,
    required this.onGaleria,
    required this.onQuitar,
  });

  final Uint8List? bytes;
  final bool habilitado;
  final VoidCallback onCamara;
  final VoidCallback onGaleria;
  final VoidCallback onQuitar;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: bytes == null
              ? Container(
                  width: 112,
                  height: 112,
                  color: ColoresApp.verdePrincipal.withValues(alpha: 0.1),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.pets_rounded,
                    size: 54,
                    color: ColoresApp.verdePrincipal,
                  ),
                )
              : Image.memory(
                  bytes!,
                  width: 112,
                  height: 112,
                  fit: BoxFit.cover,
                ),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: habilitado ? onCamara : null,
              icon: const Icon(Icons.photo_camera_outlined),
              label: const Text('Cámara'),
            ),
            OutlinedButton.icon(
              onPressed: habilitado ? onGaleria : null,
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Galería'),
            ),
            if (bytes != null)
              IconButton.outlined(
                onPressed: habilitado ? onQuitar : null,
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Quitar fotografía',
              ),
          ],
        ),
      ],
    );
  }
}

class _SeccionFormulario extends StatelessWidget {
  const _SeccionFormulario({required this.titulo, required this.children});

  final String titulo;
  final List<Widget> children;

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
          Text(
            titulo,
            style: const TextStyle(
              color: ColoresApp.azulOscuro,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}
