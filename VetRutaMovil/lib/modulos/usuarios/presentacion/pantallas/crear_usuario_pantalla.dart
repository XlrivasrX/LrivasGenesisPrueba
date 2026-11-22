import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:vetruta_movil/core/tema/colores_app.dart';
import 'package:vetruta_movil/modulos/usuarios/presentacion/controladores/usuarios_controlador.dart';

class CrearUsuarioPantalla extends StatefulWidget {
  const CrearUsuarioPantalla({super.key});

  @override
  State<CrearUsuarioPantalla> createState() => _CrearUsuarioPantallaState();
}

class _CrearUsuarioPantallaState extends State<CrearUsuarioPantalla> {
  final _nombreUsuario = TextEditingController();
  final _contrasena = TextEditingController();
  final _nombres = TextEditingController();
  final _apellidos = TextEditingController();
  final _correo = TextEditingController();
  final _telefono = TextEditingController();
  int? _rolId;
  bool _ocultarContrasena = true;

  @override
  void dispose() {
    _nombreUsuario.dispose();
    _contrasena.dispose();
    _nombres.dispose();
    _apellidos.dispose();
    _correo.dispose();
    _telefono.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controlador = context.watch<UsuariosControlador>();

    return Scaffold(
      backgroundColor: ColoresApp.fondo,
      appBar: AppBar(title: const Text('Nuevo usuario')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          DropdownButtonFormField<int>(
            initialValue: _rolId,
            decoration: const InputDecoration(
              labelText: 'Rol',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
            items: controlador.roles
                .map(
                  (rol) => DropdownMenuItem<int>(
                    value: rol.rolId,
                    child: Text(rol.nombre),
                  ),
                )
                .toList(),
            onChanged: controlador.cargando
                ? null
                : (valor) => _rolId = valor,
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _nombreUsuario,
            enabled: !controlador.cargando,
            decoration: const InputDecoration(
              labelText: 'Nombre de usuario',
              prefixIcon: Icon(Icons.alternate_email_rounded),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _contrasena,
            enabled: !controlador.cargando,
            obscureText: _ocultarContrasena,
            decoration: InputDecoration(
              labelText: 'Contraseña temporal',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                onPressed: () {
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
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _nombres,
            enabled: !controlador.cargando,
            decoration: const InputDecoration(
              labelText: 'Nombres',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _apellidos,
            enabled: !controlador.cargando,
            decoration: const InputDecoration(
              labelText: 'Apellidos',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _correo,
            enabled: !controlador.cargando,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Correo (opcional)',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _telefono,
            enabled: !controlador.cargando,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Teléfono (opcional)',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          if (controlador.mensajeError != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: ColoresApp.coral.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                controlador.mensajeError!,
                style: const TextStyle(color: ColoresApp.coral),
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            height: 54,
            child: FilledButton.icon(
              onPressed: controlador.cargando
                  ? null
                  : () => _guardar(controlador),
              icon: controlador.cargando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('Crear usuario'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _guardar(UsuariosControlador controlador) async {
    final creado = await controlador.crearUsuario(
      rolId: _rolId,
      nombreUsuario: _nombreUsuario.text,
      contrasenaTemporal: _contrasena.text,
      nombres: _nombres.text,
      apellidos: _apellidos.text,
      correo: _correo.text,
      telefono: _telefono.text,
    );

    if (!mounted || !creado) {
      return;
    }

    Navigator.of(context).pop(true);
  }
}
