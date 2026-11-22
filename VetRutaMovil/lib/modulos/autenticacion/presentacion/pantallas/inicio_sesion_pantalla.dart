import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:vetruta_movil/core/tema/colores_app.dart';
import 'package:vetruta_movil/modulos/agenda/presentacion/pantallas/agenda_pantalla.dart';
import 'package:vetruta_movil/modulos/autenticacion/presentacion/controladores/autenticacion_controlador.dart';
import 'package:vetruta_movil/modulos/panel/presentacion/pantallas/panel_pantalla.dart';
import 'package:vetruta_movil/modulos/usuarios/presentacion/pantallas/usuarios_pantalla.dart';

class InicioSesionPantalla extends StatefulWidget {
  const InicioSesionPantalla({super.key});

  @override
  State<InicioSesionPantalla> createState() => _InicioSesionPantallaState();
}

class _InicioSesionPantallaState extends State<InicioSesionPantalla> {
  final _formularioKey = GlobalKey<FormState>();
  final _usuarioController = TextEditingController();
  final _contrasenaController = TextEditingController();

  bool _ocultarContrasena = true;

  @override
  void dispose() {
    _usuarioController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    if (_formularioKey.currentState?.validate() != true) {
      return;
    }

    FocusScope.of(context).unfocus();

    final controlador = context.read<AutenticacionControlador>();
    final inicioExitoso = await controlador.iniciarSesion(
      _usuarioController.text,
      _contrasenaController.text,
    );

    if (!mounted || !inicioExitoso) {
      return;
    }

    final usuario = controlador.usuario;
    if (usuario == null) {
      return;
    }

    final codigoRol = usuario.codigoRol.toUpperCase();

    if (codigoRol == 'ROOT') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const UsuariosPantalla()),
      );
      return;
    }

    if (codigoRol == 'DIRECTOR') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const PanelPantalla()),
      );
      return;
    }

    if (codigoRol == 'TECNICO' || codigoRol == 'MEDICO') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const AgendaPantalla(),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'La pantalla para el rol ${usuario.nombreRol} se implementará próximamente.',
        ),
      ),
    );
  }

  void _limpiarError(String _) {
    final controlador = context.read<AutenticacionControlador>();
    if (controlador.mensajeError != null) {
      controlador.limpiarError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controlador = context.watch<AutenticacionControlador>();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formularioKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32),
                    _construirLogo(),
                    const SizedBox(height: 32),
                    Text(
                      'Bienvenido',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: ColoresApp.azulOscuro,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Gestiona tus visitas veterinarias a domicilio',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ColoresApp.textoSecundario,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 36),
                    TextFormField(
                      controller: _usuarioController,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username],
                      decoration: _crearDecoracion(
                        etiqueta: 'Usuario',
                        icono: Icons.person_outline,
                      ),
                      validator: (valor) {
                        return valor == null || valor.trim().isEmpty
                            ? 'Ingresa tu usuario.'
                            : null;
                      },
                      onChanged: _limpiarError,
                      enabled: !controlador.cargando,
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _contrasenaController,
                      obscureText: _ocultarContrasena,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => _iniciarSesion(),
                      decoration: _crearDecoracion(
                        etiqueta: 'Contraseña',
                        icono: Icons.lock_outline,
                        sufijo: IconButton(
                          onPressed: controlador.cargando
                              ? null
                              : () {
                                  setState(() {
                                    _ocultarContrasena = !_ocultarContrasena;
                                  });
                                },
                          icon: Icon(
                            _ocultarContrasena
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (valor) {
                        return valor == null || valor.isEmpty
                            ? 'Ingresa tu contraseña.'
                            : null;
                      },
                      onChanged: _limpiarError,
                      enabled: !controlador.cargando,
                    ),
                    const SizedBox(height: 28),
                    if (controlador.mensajeError != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: ColoresApp.coral.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: ColoresApp.coral.withValues(alpha: 0.35),
                          ),
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
                                style: const TextStyle(
                                  color: ColoresApp.coral,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    FilledButton.icon(
                      onPressed: controlador.cargando ? null : _iniciarSesion,
                      icon: controlador.cargando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.login),
                      label: Text(
                        controlador.cargando
                            ? 'Ingresando...'
                            : 'Iniciar sesión',
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'VetRuta · Atención veterinaria en campo',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ColoresApp.textoSecundario,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirLogo() {
    return Column(
      children: [
        const SizedBox(
          width: 76,
          height: 76,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.location_on, size: 76, color: ColoresApp.coral),
              Positioned(
                top: 17,
                child: Icon(Icons.pets, size: 27, color: Colors.white),
              ),
            ],
          ),
        ),
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
            children: [
              TextSpan(
                text: 'Vet',
                style: TextStyle(color: ColoresApp.azulOscuro),
              ),
              TextSpan(
                text: 'Ruta',
                style: TextStyle(color: ColoresApp.verdePrincipal),
              ),
            ],
          ),
        ),
      ],
    );
  }

  InputDecoration _crearDecoracion({
    required String etiqueta,
    required IconData icono,
    Widget? sufijo,
  }) {
    return InputDecoration(
      labelText: etiqueta,
      prefixIcon: Icon(icono),
      suffixIcon: sufijo,
      filled: true,
      fillColor: ColoresApp.superficie,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: ColoresApp.borde),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: ColoresApp.borde),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: ColoresApp.verdePrincipal,
          width: 2,
        ),
      ),
    );
  }
}
