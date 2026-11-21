import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:vetruta_movil/app.dart';

void main() {
  testWidgets('Muestra y valida la pantalla de inicio de sesión', (tester) async {
    await tester.pumpWidget(const VetRutaApp());
    await tester.pumpAndSettle();

    expect(find.text('Bienvenido'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Iniciar sesión'), findsOneWidget);

    await tester.tap(find.text('Iniciar sesión'));
    await tester.pump();

    expect(find.text('Ingresa tu usuario.'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña.'), findsOneWidget);
  });
}