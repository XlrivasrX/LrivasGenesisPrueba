import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';
import 'package:vetruta_movil/core/tema/colores_app.dart';
import 'package:vetruta_movil/modulos/agenda/datos/modelos/agenda_visita.dart';
import 'package:vetruta_movil/modulos/agenda/presentacion/pantallas/detalle_visita_pantalla.dart';

enum _FiltroMapa { todos, pendientes, atrasadas }

class MapaPantalla extends StatefulWidget {
  const MapaPantalla({
    required this.visitas,
    required this.onActualizar,
    super.key,
  });

  final List<AgendaVisita> visitas;
  final Future<void> Function() onActualizar;

  @override
  State<MapaPantalla> createState() => _MapaPantallaState();
}

class _MapaPantallaState extends State<MapaPantalla> {
  _FiltroMapa _filtro = _FiltroMapa.todos;

  @override
  Widget build(BuildContext context) {
    final visitas = _obtenerVisitasFiltradas();
    final visitasConUbicacion = visitas.where(_tieneUbicacion).toList();

    if (visitasConUbicacion.isEmpty) {
      return _MapaVacio(onActualizar: widget.onActualizar);
    }

    final puntos = visitasConUbicacion
        .map((visita) => LatLng(visita.latitud!, visita.longitud!))
        .toList();

    final proximaVisita = _obtenerProximaVisita(visitasConUbicacion);

    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(initialCenter: puntos.first, initialZoom: 14),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.lrivas.vetruta_movil',
            ),
            if (puntos.length > 1)
              PolylineLayer(
                polylines: [
                  Polyline(points: puntos, strokeWidth: 5, color: Colors.blue),
                ],
              ),
            MarkerLayer(
              markers: visitasConUbicacion.map((visita) {
                final color = visita.completada
                    ? ColoresApp.exito
                    : visita.atrasada
                    ? ColoresApp.coral
                    : ColoresApp.amarillo;

                return Marker(
                  point: LatLng(visita.latitud!, visita.longitud!),
                  width: 52,
                  height: 52,
                  child: Tooltip(
                    message: visita.nombrePaciente,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => DetalleVisitaPantalla(
                              visitaId: visita.visitaId,
                            ),
                          ),
                        );
                      },
                      customBorder: const CircleBorder(),
                      child: Icon(
                        Icons.location_on_rounded,
                        size: 48,
                        color: color,
                        shadows: const [
                          Shadow(color: Colors.black26, blurRadius: 6),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            RichAttributionWidget(
              attributions: const [
                TextSourceAttribution('OpenStreetMap contributors'),
              ],
            ),
          ],
        ),
        Positioned(
          top: 16,
          left: 12,
          right: 12,
          child: Material(
            color: ColoresApp.superficie,
            elevation: 3,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: _FiltroBoton(
                      texto: 'Todos',
                      seleccionado: _filtro == _FiltroMapa.todos,
                      onTap: () {
                        setState(() {
                          _filtro = _FiltroMapa.todos;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: _FiltroBoton(
                      texto: 'Pendientes',
                      seleccionado: _filtro == _FiltroMapa.pendientes,
                      color: ColoresApp.amarillo,
                      onTap: () {
                        setState(() {
                          _filtro = _FiltroMapa.pendientes;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: _FiltroBoton(
                      texto: 'Atrasadas',
                      seleccionado: _filtro == _FiltroMapa.atrasadas,
                      color: ColoresApp.coral,
                      onTap: () {
                        setState(() {
                          _filtro = _FiltroMapa.atrasadas;
                        });
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onActualizar,
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'Actualizar',
                  ),
                ],
              ),
            ),
          ),
        ),
        if (proximaVisita != null)
          Positioned(
            left: 12,
            right: 12,
            bottom: 16,
            child: _TarjetaProximaVisita(visita: proximaVisita),
          ),
      ],
    );
  }

  List<AgendaVisita> _obtenerVisitasFiltradas() {
    switch (_filtro) {
      case _FiltroMapa.todos:
        return widget.visitas;
      case _FiltroMapa.pendientes:
        return widget.visitas.where((visita) {
          return !visita.completada && !visita.atrasada;
        }).toList();
      case _FiltroMapa.atrasadas:
        return widget.visitas.where((visita) {
          return visita.atrasada;
        }).toList();
    }
  }

  AgendaVisita? _obtenerProximaVisita(List<AgendaVisita> visitas) {
    final pendientes = visitas.where((visita) {
      return !visita.completada;
    }).toList();

    if (pendientes.isNotEmpty) {
      pendientes.sort((primera, segunda) {
        return primera.fechaProgramada.compareTo(segunda.fechaProgramada);
      });

      return pendientes.first;
    }

    return visitas.isEmpty ? null : visitas.first;
  }

  bool _tieneUbicacion(AgendaVisita visita) {
    return visita.latitud != null && visita.longitud != null;
  }
}

class _FiltroBoton extends StatelessWidget {
  const _FiltroBoton({
    required this.texto,
    required this.seleccionado,
    required this.onTap,
    this.color = ColoresApp.verdePrincipal,
  });

  final String texto;
  final bool seleccionado;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: seleccionado
              ? color.withValues(alpha: 0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          texto,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: seleccionado ? color : ColoresApp.textoPrincipal,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _TarjetaProximaVisita extends StatelessWidget {
  const _TarjetaProximaVisita({required this.visita});

  final AgendaVisita visita;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ColoresApp.superficie,
      elevation: 4,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => DetalleVisitaPantalla(visitaId: visita.visitaId),
            ),
          );
        },
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: ColoresApp.amarillo.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.pets_rounded,
                  color: ColoresApp.amarillo,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Próxima visita',
                      style: TextStyle(
                        color: ColoresApp.textoSecundario,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      visita.nombrePaciente,
                      style: const TextStyle(
                        color: ColoresApp.azulOscuro,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${visita.nombreServicio} · ${visita.direccion}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: ColoresApp.textoSecundario,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: ColoresApp.textoSecundario,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapaVacio extends StatelessWidget {
  const _MapaVacio({required this.onActualizar});

  final Future<void> Function() onActualizar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_off_outlined,
              size: 56,
              color: ColoresApp.textoSecundario,
            ),
            const SizedBox(height: 12),
            const Text(
              'No hay visitas con ubicación disponible.',
              textAlign: TextAlign.center,
              style: TextStyle(color: ColoresApp.textoSecundario, fontSize: 16),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onActualizar,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Actualizar'),
            ),
          ],
        ),
      ),
    );
  }
}
