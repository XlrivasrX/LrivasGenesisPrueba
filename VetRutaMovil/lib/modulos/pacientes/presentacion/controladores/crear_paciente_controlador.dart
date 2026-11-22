import 'package:flutter/foundation.dart';
import 'package:vetruta_movil/core/red/excepcion_api.dart';
import 'package:vetruta_movil/modulos/jerarquia/datos/modelos/usuario_jerarquia.dart';
import 'package:vetruta_movil/modulos/pacientes/datos/modelos/catalogos_paciente.dart';
import 'package:vetruta_movil/modulos/pacientes/datos/servicios/paciente_servicio.dart';

class CrearPacienteControlador extends ChangeNotifier {
  CrearPacienteControlador(this._servicio);

  final PacienteServicio _servicio;

  List<EspecieCatalogo> _especies = [];
  List<RazaCatalogo> _razas = [];
  List<TecnicoAsignado> _tecnicos = [];
  int? _especieId;
  int? _razaId;
  int? _tecnicoUsuarioId;
  bool _cargando = false;
  bool _guardando = false;
  String? _mensajeError;

  List<EspecieCatalogo> get especies => _especies;
  List<RazaCatalogo> get razas => _razas;
  List<TecnicoAsignado> get tecnicos => _tecnicos;
  int? get especieId => _especieId;
  int? get razaId => _razaId;
  int? get tecnicoUsuarioId => _tecnicoUsuarioId;
  bool get cargando => _cargando;
  bool get guardando => _guardando;
  String? get mensajeError => _mensajeError;

  Future<void> cargarCatalogos() async {
    _cargando = true;
    _mensajeError = null;
    notifyListeners();

    try {
      _especies = await _servicio.obtenerEspecies();
      _tecnicos = await _servicio.obtenerMisTecnicos();

      _especies.sort(
        (primera, segunda) => primera.nombre.compareTo(segunda.nombre),
      );

      _tecnicos.sort(
        (primero, segundo) =>
            primero.nombreCompleto.compareTo(segundo.nombreCompleto),
      );

      if (_especies.isNotEmpty) {
        _especieId = _especies.first.especieId;
        await _cargarRazas(_especieId!);
      }
    } on ExcepcionApi catch (excepcion) {
      _mensajeError = excepcion.mensaje;
    } catch (_) {
      _mensajeError = 'No fue posible cargar los datos del formulario.';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> seleccionarEspecie(int? especieId) async {
    if (especieId == null || especieId == _especieId) {
      return;
    }

    _especieId = especieId;
    _razaId = null;
    _mensajeError = null;
    _cargando = true;

    try {
      await _cargarRazas(especieId);
    } on ExcepcionApi catch (excepcion) {
      _mensajeError = excepcion.mensaje;
    } catch (_) {
      _mensajeError = 'No fue posible cargar las razas.';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  void seleccionarRaza(int? razaId) {
    _razaId = razaId;
    _mensajeError = null;
  }

  void seleccionarTecnico(int? tecnicoUsuarioId) {
    _tecnicoUsuarioId = tecnicoUsuarioId;
    _mensajeError = null;
  }

  Future<bool> crearPaciente({
    required String nombresPropietario,
    required String apellidosPropietario,
    required String telefono,
    required String direccion,
    required String nombrePaciente,
    String? telefonoAlternativo,
    DateTime? fechaNacimiento,
    String? observaciones,
    double? latitud,
    double? longitud,
  }) async {
    final error = _validar(
      nombresPropietario: nombresPropietario,
      apellidosPropietario: apellidosPropietario,
      telefono: telefono,
      direccion: direccion,
      nombrePaciente: nombrePaciente,
    );

    if (error != null) {
      _mensajeError = error;
      notifyListeners();
      return false;
    }

    _guardando = true;
    _mensajeError = null;
    notifyListeners();

    try {
      await _servicio.crearPacienteAsignado(
        nombresPropietario: nombresPropietario,
        apellidosPropietario: apellidosPropietario,
        telefono: telefono,
        telefonoAlternativo: telefonoAlternativo,
        direccion: direccion,
        especieId: _especieId!,
        razaId: _razaId!,
        nombrePaciente: nombrePaciente,
        fechaNacimiento: fechaNacimiento,
        observaciones: observaciones,
        tecnicoUsuarioId: _tecnicoUsuarioId!,
        latitud: latitud,
        longitud: longitud,
      );

      return true;
    } on ExcepcionApi catch (excepcion) {
      _mensajeError = excepcion.mensaje;
      return false;
    } catch (_) {
      _mensajeError = 'No fue posible crear el paciente.';
      return false;
    } finally {
      _guardando = false;
      notifyListeners();
    }
  }

  Future<void> _cargarRazas(int especieId) async {
    _razas = await _servicio.obtenerRazas(especieId);

    _razas.sort((primera, segunda) => primera.nombre.compareTo(segunda.nombre));

    if (_razas.isNotEmpty) {
      _razaId = _razas.first.razaId;
    }
  }

  String? _validar({
    required String nombresPropietario,
    required String apellidosPropietario,
    required String telefono,
    required String direccion,
    required String nombrePaciente,
  }) {
    if (nombresPropietario.trim().isEmpty) {
      return 'Ingresa los nombres del propietario.';
    }

    if (apellidosPropietario.trim().isEmpty) {
      return 'Ingresa los apellidos del propietario.';
    }

    if (telefono.trim().isEmpty) {
      return 'Ingresa el teléfono del propietario.';
    }

    if (direccion.trim().isEmpty) {
      return 'Ingresa la dirección.';
    }

    if (nombrePaciente.trim().isEmpty) {
      return 'Ingresa el nombre del paciente.';
    }

    if (_especieId == null || _razaId == null) {
      return 'Selecciona la especie y raza.';
    }

    if (_tecnicoUsuarioId == null) {
      return 'Selecciona el técnico responsable.';
    }

    return null;
  }
}
