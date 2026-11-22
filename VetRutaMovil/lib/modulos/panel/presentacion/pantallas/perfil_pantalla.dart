import 'package:material_ui/material_ui.dart';
import 'package:vetruta_movil/core/tema/colores_app.dart';
import 'package:vetruta_movil/modulos/autenticacion/datos/modelos/usuario_sesion.dart';

class PerfilPantalla extends StatelessWidget {
  const PerfilPantalla({
    required this.usuario,
    required this.cerrandoSesion,
    required this.onCerrarSesion,
    super.key,
  });

  final UsuarioSesion usuario;
  final bool cerrandoSesion;
  final Future<void> Function() onCerrarSesion;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Perfil',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: ColoresApp.azulOscuro,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Información de la cuenta',
          style: TextStyle(
            color: ColoresApp.textoSecundario,
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: CircleAvatar(
            radius: 48,
            backgroundColor: ColoresApp.verdePrincipal.withValues(alpha: 0.12),
            child: Text(
              _obtenerIniciales(),
              style: const TextStyle(
                color: ColoresApp.verdePrincipal,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          usuario.nombreCompleto,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: ColoresApp.azulOscuro,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          usuario.nombreRol,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: ColoresApp.textoSecundario,
          ),
        ),
        const SizedBox(height: 24),
        _DatoPerfil(
          icono: Icons.person_outline_rounded,
          etiqueta: 'Usuario',
          valor: usuario.nombreUsuario,
        ),
        const SizedBox(height: 12),
        _DatoPerfil(
          icono: Icons.badge_outlined,
          etiqueta: 'Rol',
          valor: usuario.nombreRol,
        ),
        if (usuario.debeCambiarContrasena) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: ColoresApp.amarillo.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: ColoresApp.amarillo,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Debes cambiar tu contraseña.',
                    style: TextStyle(
                      color: ColoresApp.textoPrincipal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 32),
        OutlinedButton.icon(
          onPressed: cerrandoSesion
              ? null
              : () => _confirmarCerrarSesion(context),
          icon: cerrandoSesion
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.logout_rounded),
          label: Text(
            cerrandoSesion ? 'Cerrando sesión...' : 'Cerrar sesión',
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: ColoresApp.coral,
            side: const BorderSide(color: ColoresApp.coral),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }

  String _obtenerIniciales() {
    final partes = usuario.nombreCompleto
        .trim()
        .split(' ')
        .where((parte) => parte.isNotEmpty)
        .take(2)
        .toList();

    if (partes.isEmpty) {
      return 'U';
    }

    return partes.map((parte) => parte[0].toUpperCase()).join();
  }

  Future<void> _confirmarCerrarSesion(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text(
            '¿Deseas cerrar tu sesión en este dispositivo?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Cerrar sesión'),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      await onCerrarSesion();
    }
  }
}

class _DatoPerfil extends StatelessWidget {
  const _DatoPerfil({
    required this.icono,
    required this.etiqueta,
    required this.valor,
  });

  final IconData icono;
  final String etiqueta;
  final String valor;

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
          Icon(
            icono,
            color: ColoresApp.verdePrincipal,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  etiqueta,
                  style: const TextStyle(
                    color: ColoresApp.textoSecundario,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  valor,
                  style: const TextStyle(
                    color: ColoresApp.azulOscuro,
                    fontSize: 16,
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