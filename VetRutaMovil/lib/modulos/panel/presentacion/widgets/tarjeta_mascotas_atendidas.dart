import 'package:material_ui/material_ui.dart';
import 'package:vetruta_movil/core/tema/colores_app.dart';
import 'package:vetruta_movil/modulos/panel/datos/modelos/mascotas_atendidas.dart';

class TarjetaMascotasAtendidas extends StatelessWidget {
  const TarjetaMascotasAtendidas({
    required this.datos,
    super.key,
  });

  final List<MascotasAtendidas> datos;

  @override
  Widget build(BuildContext context) {
    final perros = _sumarPorTipo(
      (nombre) => nombre.contains('perro') || nombre.contains('canino'),
    );
    final gatos = _sumarPorTipo(
      (nombre) => nombre.contains('gato') || nombre.contains('felino'),
    );
    final total = datos.fold<int>(
      0,
      (suma, elemento) => suma + elemento.cantidadMascotas,
    );
    final otros = total - perros - gatos;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColoresApp.superficie,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColoresApp.borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mascotas atendidas (total: $total)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: ColoresApp.azulOscuro,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _IndicadorMascota(
                  icono: Icons.pets_rounded,
                  etiqueta: 'Perros',
                  cantidad: perros,
                  color: ColoresApp.verdePrincipal,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _IndicadorMascota(
                  icono: Icons.cruelty_free_rounded,
                  etiqueta: 'Gatos',
                  cantidad: gatos,
                  color: ColoresApp.amarillo,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _IndicadorMascota(
                  icono: Icons.category_outlined,
                  etiqueta: 'Otros',
                  cantidad: otros,
                  color: ColoresApp.azulEncabezado,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _sumarPorTipo(bool Function(String) coincide) {
    return datos.fold<int>(0, (suma, elemento) {
      final nombre = elemento.nombreEspecie.toLowerCase();

      return coincide(nombre)
          ? suma + elemento.cantidadMascotas
          : suma;
    });
  }
}

class _IndicadorMascota extends StatelessWidget {
  const _IndicadorMascota({
    required this.icono,
    required this.etiqueta,
    required this.cantidad,
    required this.color,
  });

  final IconData icono;
  final String etiqueta;
  final int cantidad;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icono,
            size: 22,
            color: color,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  etiqueta,
                  style: const TextStyle(
                    color: ColoresApp.textoPrincipal,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  cantidad.toString(),
                  style: TextStyle(
                    color: color,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
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