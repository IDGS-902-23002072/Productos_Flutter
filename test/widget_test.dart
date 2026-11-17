import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:productos_app/pages/productos_page.dart';
import 'package:productos_app/pages/usuarios_page.dart';

Widget _app(Widget dialogo) => MaterialApp(home: Scaffold(body: dialogo));

void main() {
  testWidgets('Formulario de producto muestra errores si está vacío',
      (WidgetTester tester) async {
    await tester.pumpWidget(_app(const ProductoFormDialog()));

    await tester.tap(find.text('Guardar'));
    await tester.pump();

    expect(find.text('Ingresa el nombre del producto'), findsOneWidget);
    expect(find.text('Ingresa el precio'), findsOneWidget);
    expect(find.text('Ingresa las existencias'), findsOneWidget);
  });

  testWidgets('Precio convierte la coma en punto',
      (WidgetTester tester) async {
    await tester.pumpWidget(_app(const ProductoFormDialog()));

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Precio unitario'),
      '12,5',
    );
    await tester.pump();

    expect(find.text('12.5'), findsOneWidget);
  });

  testWidgets('Formulario de usuario exige datos y contraseña',
      (WidgetTester tester) async {
    await tester.pumpWidget(_app(const UsuarioFormDialog()));

    await tester.tap(find.text('Guardar'));
    await tester.pump();

    expect(find.text('Ingresa el nombre del usuario'), findsOneWidget);
    expect(find.text('Ingresa el correo electrónico'), findsOneWidget);
    expect(find.text('Ingresa el teléfono'), findsOneWidget);
    expect(find.text('Ingresa una contraseña'), findsOneWidget);
  });

  testWidgets('Formulario de usuario detecta correo repetido',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      _app(const UsuarioFormDialog(correosExistentes: ['ana@correo.com'])),
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Correo electrónico'),
      'ANA@correo.com',
    );
    await tester.tap(find.text('Guardar'));
    await tester.pump();

    expect(find.text('Este correo ya está registrado'), findsOneWidget);
  });
}
