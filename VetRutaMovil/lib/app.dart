import 'package:material_ui/material_ui.dart';
import 'package:vetruta_movil/core/tema/tema_app.dart';
import 'package:vetruta_movil/modulos/autenticacion/presentacion/pantallas/inicio_sesion_pantalla.dart';

class VetRutaApp extends StatelessWidget {
  const VetRutaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
    );
  }
}