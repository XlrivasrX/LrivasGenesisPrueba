import 'package:material_ui/material_ui.dart';

import 'colores_app.dart';

class TemaApp {
  TemaApp._();

  static ThemeData get claro {
    final esquemaColores = ColorScheme.fromSeed(
      seedColor: ColoresApp.verdePrincipal,
      brightness: Brightness.light,
    ).copyWith(
      primary: ColoresApp.verdePrincipal,
      secondary: ColoresApp.azulOscuro,
      error: ColoresApp.coral,
      surface: ColoresApp.superficie,
    );

    return ThemeData(
      colorScheme: esquemaColores,
      scaffoldBackgroundColor: ColoresApp.fondo,
      appBarTheme: const AppBarTheme(
        backgroundColor: ColoresApp.azulOscuro,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ColoresApp.verdePrincipal,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}