import 'package:flutter/services.dart';

import 'validadores.dart';

/// Filtros de entrada para los campos de texto.
///
/// Evitan que el usuario escriba (o pegue) caracteres que luego fallarían la
/// validación: símbolos raros, emojis, caracteres invisibles, espacios
/// repetidos y textos más largos que el límite permitido.
/// La validación final sigue haciéndola [Validadores].
class FormatosEntrada {
  FormatosEntrada._();

  static const String _letras = r'A-Za-zÀ-ÖØ-öø-ÿ';

  /// Nombre de producto: letras, números y . , _ ( ) / # & + : % -
  static List<TextInputFormatter> nombreProducto() => [
        FilteringTextInputFormatter.allow(
          RegExp('[$_letras' r'0-9 .,_()/#&+:%-]'),
        ),
        _EspaciosLimpios(),
        LengthLimitingTextInputFormatter(Validadores.maxNombreProducto),
      ];

  /// Nombre de persona: letras, espacio, punto, apóstrofe y guion.
  static List<TextInputFormatter> nombreUsuario() => [
        FilteringTextInputFormatter.allow(
          RegExp('[$_letras' r" .'’-]"),
        ),
        _EspaciosLimpios(),
        LengthLimitingTextInputFormatter(Validadores.maxNombreUsuario),
      ];

  /// Precio: solo dígitos y un punto decimal, con máximo 2 decimales.
  /// La coma se convierte en punto automáticamente.
  static List<TextInputFormatter> precio() => [_PrecioFormatter()];

  /// Existencias: solo dígitos.
  static List<TextInputFormatter> existencias() => [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(
          Validadores.maxExistencias.toString().length,
        ),
      ];

  /// Correo: caracteres seguros para una dirección, sin espacios.
  static List<TextInputFormatter> correo() => [
        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9@._%+-]')),
        LengthLimitingTextInputFormatter(Validadores.maxCorreo),
      ];

  /// Teléfono: dígitos, espacio, guion, paréntesis y +.
  static List<TextInputFormatter> telefono() => [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9+() -]')),
        _EspaciosLimpios(),
        LengthLimitingTextInputFormatter(Validadores.maxTelefono),
      ];

  /// Contraseña: ASCII imprimible y letras latinas acentuadas, sin espacios.
  static List<TextInputFormatter> contrasena() => [
        FilteringTextInputFormatter.allow(
          RegExp(r'[\x21-\x7E\u00A1-\u00FF]'),
        ),
        LengthLimitingTextInputFormatter(Validadores.maxContrasena),
      ];
}

/// Elimina espacios al inicio y colapsa espacios consecutivos mientras se
/// escribe, manteniendo el cursor en su lugar.
class _EspaciosLimpios extends TextInputFormatter {
  static final RegExp _inicio = RegExp(r'^ +');
  static final RegExp _repetidos = RegExp(r' {2,}');

  static String _limpiar(String texto) {
    return texto.replaceFirst(_inicio, '').replaceAll(_repetidos, ' ');
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final texto = newValue.text;
    final limpio = _limpiar(texto);

    if (limpio == texto) return newValue;

    final base = newValue.selection.baseOffset;
    final cursor = (base < 0 || base > texto.length) ? texto.length : base;
    final nuevoCursor = _limpiar(texto.substring(0, cursor)).length;

    return TextEditingValue(
      text: limpio,
      selection: TextSelection.collapsed(offset: nuevoCursor),
    );
  }
}

/// Acepta solo números con punto decimal opcional (máx. 2 decimales).
/// Cualquier cambio que deje un valor inválido se ignora.
class _PrecioFormatter extends TextInputFormatter {
  static final RegExp _valido = RegExp(
    '^\\d{0,${Validadores.maxEnterosPrecio}}'
    '(\\.\\d{0,${Validadores.maxDecimalesPrecio}})?\$',
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final texto = newValue.text.replaceAll(',', '.');

    if (!_valido.hasMatch(texto)) return oldValue;

    if (texto == newValue.text) return newValue;

    // Misma longitud (',' -> '.'), por lo que la selección sigue siendo válida.
    return newValue.copyWith(text: texto);
  }
}
