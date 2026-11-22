import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:vetruta_movil/core/tema/colores_app.dart';
import 'package:vetruta_movil/modulos/autenticacion/presentacion/controladores/autenticacion_controlador.dart';
import 'package:vetruta_movil/modulos/autenticacion/presentacion/pantallas/inicio_sesion_pantalla.dart';
import 'package:vetruta_movil/modulos/usuarios/datos/modelos/usuario_administracion.dart';
import 'package:vetruta_movil/modulos/usuarios/datos/servicios/usuario_administracion_servicio.dart';
import 'package:vetruta_movil/modulos/usuarios/presentacion/controladores/usuarios_controlador.dart';
import 'package:vetruta_movil/modulos/usuarios/presentacion/pantallas/crear_usuario_pantalla.dart';

class UsuariosPantalla extends StatelessWidget {
  const UsuariosPantalla({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UsuariosControlador>(
      create: (context) =>
          UsuariosControlador(context.read<UsuarioAdministracionServicio>())
            ..cargar(),
      child: const _UsuariosContenido(),
    );
  }
}

class _UsuariosContenido extends StatelessWidget {
  const _UsuariosContenido();

  @override
  Widget build(BuildContext context) {
    final controlador = context.watch<UsuariosControlador>();

    return Scaffold(
      backgroundColor: ColoresApp.fondo,
      appBar: AppBar(
        title: const Text('Administración de usuarios'),
        actions: [
          IconButton(
            onPressed: () => _cerrarSesion(context),
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controlador.cargar,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Usuarios del sistema',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: ColoresApp.azulOscuro,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Crea usuarios y controla su acceso a VetRuta.',
              style: TextStyle(color: ColoresApp.textoSecundario),
            ),
            if (controlador.cargando) ...[
              const SizedBox(height: 14),
              const LinearProgressIndicator(minHeight: 3),
            ],
            if (controlador.mensajeError != null) ...[
              const SizedBox(height: 14),
              _MensajeError(mensaje: controlador.mensajeError!),
            ],
            const SizedBox(height: 18),
            if (!controlador.cargando && controlador.usuarios.isEmpty)
              const Center(child: Text('No hay usuarios registrados.'))
            else
              ...controlador.usuarios.map(
                (usuario) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TarjetaUsuario(
                    usuario: usuario,
                    actualizando:
                        controlador.usuarioActualizandoId == usuario.usuarioId,
                    onCambiarEstado: () =>
                        _confirmarEstado(context, controlador, usuario),
                  ),
                ),
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controlador.cargando
            ? null
            : () => _abrirCreacion(context),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Nuevo usuario'),
      ),
    );
  }

  Future<void> _abrirCreacion(BuildContext context) async {
    final controlador = context.read<UsuariosControlador>();
    final creado = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => ChangeNotifierProvider<UsuariosControlador>.value(
          value: controlador,
          child: const CrearUsuarioPantalla(),
        ),
      ),
    );

    if (!context.mounted || creado != true) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usuario creado correctamente.')),
    );
  }

  Future<void> _confirmarEstado(
    BuildContext context,
    UsuariosControlador controlador,
    UsuarioAdministracion usuario,
  ) async {
    final accion = usuario.activo ? 'desactivar' : 'activar';
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${usuario.activo ? 'Desactivar' : 'Activar'} usuario'),
        content: Text('¿Deseas $accion a ${usuario.nombreCompleto}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(usuario.activo ? 'Desactivar' : 'Activar'),
          ),
        ],
      ),
    );

    if (confirmado != true) {
      return;
    }

    final actualizado = await controlador.cambiarEstado(usuario);
    if (!context.mounted || !actualizado) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Usuario ${usuario.activo ? 'desactivado' : 'activado'} correctamente.',
        ),
      ),
    );
  }

  Future<void> _cerrarSesion(BuildContext context) async {
    final autenticacion = context.read<AutenticacionControlador>();
    await autenticacion.cerrarSesion();

    if (!context.mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const InicioSesionPantalla()),
      (_) => false,
    );
  }
}

class _TarjetaUsuario extends StatelessWidget {
  const _TarjetaUsuario({
    required this.usuario,
    required this.actualizando,
    required this.onCambiarEstado,
  });

  final UsuarioAdministracion usuario;
  final bool actualizando;
  final VoidCallback onCambiarEstado;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: ColoresApp.superficie,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColoresApp.borde),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: ColoresApp.verdePrincipal.withValues(alpha: 0.12),
            child: Text(
              _iniciales(usuario),
              style: const TextStyle(
                color: ColoresApp.verdePrincipal,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  usuario.nombreCompleto,
                  style: const TextStyle(
                    color: ColoresApp.azulOscuro,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${usuario.nombreUsuario} · ${usuario.nombreRol}',
                  style: const TextStyle(color: ColoresApp.textoSecundario),
                ),
              ],
            ),
          ),
          if (actualizando)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Switch(
              value: usuario.activo,
              onChanged: (_) => onCambiarEstado(),
            ),
        ],
      ),
    );
  }

  String _iniciales(UsuarioAdministracion usuario) {
    final primera = usuario.nombres.isEmpty ? '' : usuario.nombres[0];
    final segunda = usuario.apellidos.isEmpty ? '' : usuario.apellidos[0];
    return '$primera$segunda'.toUpperCase();
  }
}

class _MensajeError extends StatelessWidget {
  const _MensajeError({required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColoresApp.coral.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(mensaje, style: const TextStyle(color: ColoresApp.coral)),
    );
  }
}
