import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:vetruta_movil/core/almacenamiento/almacenamiento_seguro.dart';
import 'package:vetruta_movil/core/red/cliente_api.dart';
import 'package:vetruta_movil/core/tema/tema_app.dart';
import 'package:vetruta_movil/modulos/autenticacion/datos/servicios/autenticacion_servicio.dart';
import 'package:vetruta_movil/modulos/autenticacion/presentacion/controladores/autenticacion_controlador.dart';
import 'package:vetruta_movil/modulos/autenticacion/presentacion/pantallas/inicio_sesion_pantalla.dart';
import 'package:vetruta_movil/modulos/panel/datos/servicios/panel_servicio.dart';
import 'package:vetruta_movil/modulos/panel/presentacion/controladores/panel_controlador.dart';
import 'package:vetruta_movil/modulos/agenda/datos/servicios/agenda_servicio.dart';
import 'package:vetruta_movil/modulos/agenda/presentacion/controladores/agenda_controlador.dart';
import 'package:vetruta_movil/modulos/pacientes/datos/servicios/paciente_servicio.dart';

class VetRutaApp extends StatelessWidget {
  const VetRutaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AlmacenamientoSeguro>(
          create: (_) => AlmacenamientoSeguro(),
        ),
        Provider<ClienteApi>(
          create: (context) => ClienteApi(
            context.read<AlmacenamientoSeguro>(),
          ),
          dispose: (_, clienteApi) => clienteApi.dio.close(),
        ),
        Provider<AutenticacionServicio>(
          create: (context) => AutenticacionServicio(
            context.read<ClienteApi>(),
            context.read<AlmacenamientoSeguro>(),
          ),
        ),
        ChangeNotifierProvider<AutenticacionControlador>(
          create: (context) => AutenticacionControlador(
            context.read<AutenticacionServicio>(),
          ),
        ),
        Provider<PanelServicio>(
          create: (context) => PanelServicio(
            context.read<ClienteApi>(),
          ),
        ),
        ChangeNotifierProvider<PanelControlador>(
          create: (context) => PanelControlador(
            context.read<PanelServicio>(),
          ),
        ),
        Provider<AgendaServicio>(
          create: (context) => AgendaServicio(
            context.read<ClienteApi>(),
          ),
        ),
        // Proporciona las consultas de información detallada de pacientes.
        Provider<PacienteServicio>(
          create: (context) => PacienteServicio(
            context.read<ClienteApi>(),
          ),
        ),
        ChangeNotifierProvider<AgendaControlador>(
          create: (context) => AgendaControlador(
            context.read<AgendaServicio>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'VetRuta',
        debugShowCheckedModeBanner: false,
        theme: TemaApp.claro,
        locale: const Locale('es', 'GT'),
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const [
          Locale('es', 'GT'),
          Locale('es'),
        ],
        home: const InicioSesionPantalla(),
      ),
    );
  }
}