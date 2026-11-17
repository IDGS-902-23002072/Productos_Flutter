import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:productos_app/utils/formatos_entrada.dart';
import 'package:productos_app/utils/validadores.dart';

TextEditingValue _valor(String texto) => TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );

String _aplicar(List<TextInputFormatter> formatters, String texto) {
  var valor = _valor(texto);
  for (final formatter in formatters) {
    valor = formatter.formatEditUpdate(TextEditingValue.empty, valor);
  }
  return valor.text;
}

void main() {
  group('Nombre de producto', () {
    test('acepta nombres normales', () {
      for (final v in [
        'Laptop HP 15',
        'Café molido (500 g)',
        'Cable USB-C 2m',
        'Servicio técnico #1',
        'Aceite 10% extra',
        'Piña & Coco',
        'AB',
      ]) {
        expect(Validadores.validarNombreProducto(v), isNull, reason: v);
      }
    });

    test('rechaza vacío, muy corto y muy largo', () {
      expect(Validadores.validarNombreProducto(null), isNotNull);
      expect(Validadores.validarNombreProducto('   '), isNotNull);
      expect(Validadores.validarNombreProducto('A'), isNotNull);
      expect(Validadores.validarNombreProducto('a' * 100), isNull);
      expect(Validadores.validarNombreProducto('a' * 101), isNotNull);
    });

    test('rechaza caracteres que pueden causar conflictos', () {
      for (final v in [
        '<script>alert(1)</script>',
        "'; DROP TABLE Producto;--",
        'Producto" OR "1"="1',
        'Nombre; otro',
        'a`b',
        r'ruta\carpeta',
        'a|b',
        '{json}',
        'precio=5',
        'Hola 😀',
        '-Guion inicial',
        '.Punto inicial',
        'Cable -- 2m',
        'Con\ttab',
        'Con\nsalto',
        'Cero​ancho',
      ]) {
        expect(Validadores.validarNombreProducto(v), isNotNull, reason: v);
      }
    });
  });

  group('Precio', () {
    test('acepta valores válidos', () {
      for (final v in ['0', '0.5', '10', '150.50', '999999999.99', '007']) {
        expect(Validadores.validarPrecio(v), isNull, reason: v);
      }
    });

    test('rechaza valores inválidos', () {
      for (final v in [
        '',
        '  ',
        'abc',
        '-1',
        '1e5',
        'NaN',
        'Infinity',
        '1,5',
        '1.234',
        '.5',
        '5.',
        '1..2',
        '1.2.3',
        '0x10',
        '+5',
        '1000000000',
        '9' * 30,
      ]) {
        expect(Validadores.validarPrecio(v), isNotNull, reason: v);
      }
    });

    test('parsearPrecio redondea a 2 decimales', () {
      expect(Validadores.parsearPrecio(' 12.5 '), 12.5);
      expect(Validadores.parsearPrecio('007'), 7);
    });
  });

  group('Existencias', () {
    test('acepta enteros dentro del rango', () {
      for (final v in ['0', '1', '25', '9999999']) {
        expect(Validadores.validarExistencias(v), isNull, reason: v);
      }
    });

    test('rechaza valores inválidos', () {
      for (final v in [
        '',
        '-1',
        '1.5',
        '1e3',
        'abc',
        '+5',
        '10000000',
        '9' * 40,
      ]) {
        expect(Validadores.validarExistencias(v), isNotNull, reason: v);
      }
    });
  });

  group('Nombre de usuario', () {
    test('acepta nombres reales', () {
      for (final v in [
        'Juan Pérez',
        'María José',
        "O'Connor",
        'Ana-Luisa',
        'Ma. Guadalupe Núñez',
        'Pedro Sánchez Jr.',
        'Zoë',
        'Li',
      ]) {
        expect(Validadores.validarNombreUsuario(v), isNull, reason: v);
      }
    });

    test('rechaza números, símbolos y formatos raros', () {
      for (final v in [
        '',
        '   ',
        'J',
        'Juan123',
        'Juan_Perez',
        '<b>Juan</b>',
        "Juan'; DROP TABLE",
        'Juan@Perez',
        '-Juan',
        "'Juan",
        'Juan--Perez',
        "Juan''Perez",
        'Juan 😀',
        'a' * 101,
      ]) {
        expect(Validadores.validarNombreUsuario(v), isNotNull, reason: v);
      }
    });

    test('espacios repetidos se normalizan antes de validar', () {
      expect(Validadores.validarNombreUsuario('  Juan    Pérez  '), isNull);
      expect(Validadores.normalizarEspacios('  Juan    Pérez  '), 'Juan Pérez');
    });
  });

  group('Correo', () {
    test('acepta correos válidos', () {
      for (final v in [
        'juan@gmail.com',
        'juan.perez@empresa.com.mx',
        'juan+tag@correo.org',
        'j_p-1@sub.dominio.io',
        ' juan@gmail.com ',
      ]) {
        expect(Validadores.validarCorreo(v), isNull, reason: v);
      }
    });

    test('rechaza correos inválidos', () {
      for (final v in [
        '',
        'juan',
        'juan@',
        '@gmail.com',
        'juan@gmail',
        'juan@gmail.c',
        'juan@@gmail.com',
        'ju an@gmail.com',
        'juan..perez@gmail.com',
        '.juan@gmail.com',
        'juan.@gmail.com',
        'juan@-gmail.com',
        'juan@gmail..com',
        'juan@gmail.com.',
        'juan@exa_mple.com',
        "o'brien@gmail.com",
        '<juan>@gmail.com',
        'juan@gmail.com;otro@gmail.com',
        'ñandú@gmail.com',
        '${'a' * 65}@gmail.com',
        '${'a' * 150}@gmail.com',
      ]) {
        expect(Validadores.validarCorreo(v), isNotNull, reason: v);
      }
    });

    test('detecta correos repetidos sin distinguir mayúsculas', () {
      const existentes = ['Ana@Correo.com', 'luis@correo.com'];
      expect(
        Validadores.validarCorreoDisponible('ana@correo.COM', existentes),
        isNotNull,
      );
      expect(
        Validadores.validarCorreoDisponible('nuevo@correo.com', existentes),
        isNull,
      );
      expect(Validadores.validarCorreoDisponible('', existentes), isNull);
    });
  });

  group('Teléfono', () {
    test('acepta formatos habituales', () {
      for (final v in [
        '4771234567',
        '477 123 4567',
        '(477) 123-4567',
        '+52 477 123 4567',
        '+524771234567',
      ]) {
        expect(Validadores.validarTelefono(v), isNull, reason: v);
      }
    });

    test('rechaza formatos inválidos', () {
      for (final v in [
        '',
        '123',
        '12345678901234567',
        'abcdefghij',
        '477-123-45a7',
        '477+1234567',
        '++524771234567',
        '(477 1234567',
        '477) 1234567',
        '477;1234567',
        '477.123.4567',
        '4' * 21,
      ]) {
        expect(Validadores.validarTelefono(v), isNotNull, reason: v);
      }
    });
  });

  group('Contraseña', () {
    test('acepta contraseñas válidas', () {
      for (final v in ['Abcdef12', 'clave2025!', 'Ñandú123', 'a1' * 32]) {
        expect(Validadores.validarContrasena(v), isNull, reason: v);
      }
    });

    test('rechaza contraseñas inválidas', () {
      for (final v in [
        '',
        'Ab1',
        'sololetras',
        '12345678',
        'con espacio1',
        ' Abcdef12',
        'Abcdef12 ',
        'Abc\tdef12',
        'Abcdef12😀',
        'a1' * 33,
      ]) {
        expect(Validadores.validarContrasena(v), isNotNull, reason: v);
      }
    });

    test('al editar, vacío significa no cambiarla', () {
      expect(Validadores.validarContrasena('', obligatoria: false), isNull);
      expect(Validadores.validarContrasena(null, obligatoria: false), isNull);
      expect(Validadores.validarContrasena('corta1', obligatoria: false),
          isNotNull);
    });

    test('confirmación', () {
      expect(Validadores.validarConfirmacionContrasena('', ''), isNull);
      expect(Validadores.validarConfirmacionContrasena('', 'Abcdef12'),
          isNotNull);
      expect(Validadores.validarConfirmacionContrasena('Abcdef13', 'Abcdef12'),
          isNotNull);
      expect(Validadores.validarConfirmacionContrasena('Abcdef12', 'Abcdef12'),
          isNull);
      expect(Validadores.validarConfirmacionContrasena('algo', ''), isNotNull);
    });
  });

  group('Filtros de entrada', () {
    test('nombre de producto elimina símbolos peligrosos y limpia espacios', () {
      expect(
        _aplicar(FormatosEntrada.nombreProducto(), '  Cable <USB>;  2m  '),
        'Cable USB 2m ',
      );
    });

    test('nombre de producto respeta el límite', () {
      expect(
        _aplicar(FormatosEntrada.nombreProducto(), 'a' * 150).length,
        Validadores.maxNombreProducto,
      );
    });

    test('nombre de usuario descarta números y símbolos', () {
      expect(
        _aplicar(FormatosEntrada.nombreUsuario(), "Juan123 <Pérez>;"),
        'Juan Pérez',
      );
    });

    test('precio solo admite 2 decimales y convierte la coma', () {
      final f = FormatosEntrada.precio().first;
      TextEditingValue ed(String antes, String despues) =>
          f.formatEditUpdate(_valor(antes), _valor(despues));

      expect(ed('12.5', '12.55').text, '12.55');
      expect(ed('12.55', '12.556').text, '12.55');
      expect(ed('12', '12a').text, '12');
      expect(ed('12', '12,5').text, '12.5');
      expect(ed('1.5', '1.5.').text, '1.5');
      expect(ed('', '-').text, '');
      expect(ed('123456789', '1234567890').text, '123456789');
    });

    test('existencias solo dígitos y con límite', () {
      expect(_aplicar(FormatosEntrada.existencias(), '1a2-3.4'), '1234');
      expect(
        _aplicar(FormatosEntrada.existencias(), '1' * 12).length,
        Validadores.maxExistencias.toString().length,
      );
    });

    test('correo elimina espacios y símbolos no permitidos', () {
      expect(
        _aplicar(FormatosEntrada.correo(), ' ju an<>@mail.com'),
        'juan@mail.com',
      );
    });

    test('teléfono solo admite caracteres de teléfono', () {
      expect(
        _aplicar(FormatosEntrada.telefono(), '(477) 12a3-45;67'),
        '(477) 123-4567',
      );
    });

    test('contraseña descarta espacios y emojis', () {
      expect(
        _aplicar(FormatosEntrada.contrasena(), 'Ab c1 😀'),
        'Abc1',
      );
    });
  });
}
