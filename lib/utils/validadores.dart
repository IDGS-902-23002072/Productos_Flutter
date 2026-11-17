/// Validaciones reutilizables para los formularios de productos y usuarios.
///
/// Todas las funciones devuelven `null` cuando el valor es válido o el
/// mensaje de error que debe mostrarse en el campo.
///
/// Los límites están como constantes para poder ajustarlos en un solo lugar
/// (idealmente iguales a los de las columnas de la base de datos / API).
class Validadores {
  Validadores._();

  // ---------------------------------------------------------------------------
  // LÍMITES
  // ---------------------------------------------------------------------------

  // Productos
  static const int minNombreProducto = 2;
  static const int maxNombreProducto = 100;
  static const int maxEnterosPrecio = 9; // hasta 999,999,999.99
  static const int maxDecimalesPrecio = 2;
  static const int maxExistencias = 9999999;

  // Usuarios
  static const int minNombreUsuario = 2;
  static const int maxNombreUsuario = 100;
  static const int maxCorreo = 150;
  static const int maxParteLocalCorreo = 64;
  static const int maxTelefono = 20;
  static const int minDigitosTelefono = 10;
  static const int maxDigitosTelefono = 15;
  static const int minContrasena = 8;
  static const int maxContrasena = 64;

  // ---------------------------------------------------------------------------
  // EXPRESIONES REGULARES
  // ---------------------------------------------------------------------------

  // Letras latinas con acentos (incluye ñ y ü). Excluye × y ÷.
  static const String _letras = r'A-Za-zÀ-ÖØ-öø-ÿ';
  static const String _letrasNumeros = '${_letras}0-9';

  // Nombre de producto: empieza con letra o número y solo admite un conjunto
  // pequeño de símbolos habituales. Quedan fuera < > " ' ` ; = \ | { } [ ] $ @
  // ! ? * ~ ^ y cualquier carácter invisible, de control o emoji.
  static final RegExp _regexNombreProducto = RegExp(
    '^[$_letrasNumeros][$_letrasNumeros .,_()/#&+:%-]*\$',
  );

  // Nombre de persona: palabras separadas por un espacio, apóstrofe o guion.
  // Permite un punto al final de cada palabra (Ma. Guadalupe, Jr.).
  // Ejemplos válidos: María José, O'Connor, Ana-Luisa, Ma. Guadalupe.
  static final RegExp _regexNombreUsuario = RegExp(
    '^[$_letras]+\\.?(?:[ \'’-][$_letras]+\\.?)*\$',
  );

  // Correo: parte local con letras/números y separadores simples (. _ % + -),
  // sin puntos seguidos ni al inicio/final; dominio con etiquetas válidas y
  // extensión de solo letras (mínimo 2).
  static final RegExp _regexCorreo = RegExp(
    r'^[A-Za-z0-9]+(?:[._%+-][A-Za-z0-9]+)*'
    r'@(?:[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)+[A-Za-z]{2,24}$',
  );

  static final RegExp _regexTelefono = RegExp(r'^\+?[0-9 ()-]+$');

  // Contraseña: ASCII imprimible (sin espacios) y letras latinas con acento.
  static final RegExp _regexCaracteresContrasena = RegExp(
    r'^[\x21-\x7E\u00A1-\u00FF]+$',
  );

  static final RegExp _regexPrecio = RegExp(r'^\d+(\.\d+)?$');
  static final RegExp _regexEntero = RegExp(r'^\d+$');

  // ---------------------------------------------------------------------------
  // UTILIDADES
  // ---------------------------------------------------------------------------

  /// Quita espacios al inicio/final y colapsa varios espacios seguidos en uno.
  /// Los tabuladores y saltos de línea NO se convierten: se dejan tal cual
  /// para que la validación los rechace.
  static String normalizarEspacios(String valor) {
    return valor.trim().replaceAll(RegExp(r' {2,}'), ' ');
  }

  /// Convierte el texto de un campo de precio validado en `double`
  /// redondeado a 2 decimales.
  static double parsearPrecio(String valor) {
    final numero = double.parse(valor.trim());
    return (numero * 100).round() / 100;
  }

  // ---------------------------------------------------------------------------
  // PRODUCTOS
  // ---------------------------------------------------------------------------

  static String? validarNombreProducto(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Ingresa el nombre del producto';
    }

    final nombre = normalizarEspacios(valor);

    if (nombre.length < minNombreProducto) {
      return 'Debe tener al menos $minNombreProducto caracteres';
    }

    if (nombre.length > maxNombreProducto) {
      return 'Máximo $maxNombreProducto caracteres';
    }

    if (!_regexNombreProducto.hasMatch(nombre)) {
      return 'Empieza con letra o número. Solo se permiten letras, '
          'números y . , _ ( ) / # & + : % -';
    }

    // Secuencia de comentario SQL.
    if (nombre.contains('--')) {
      return 'No uses dos guiones seguidos (--)';
    }

    return null;
  }

  static String? validarPrecio(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Ingresa el precio';
    }

    final texto = valor.trim();

    if (texto.startsWith('-')) {
      return 'El precio no puede ser negativo';
    }

    if (!_regexPrecio.hasMatch(texto)) {
      return 'Ingresa un número válido (ejemplo: 150.50)';
    }

    final partes = texto.split('.');
    final enteros = partes[0].replaceFirst(RegExp(r'^0+(?=\d)'), '');

    if (enteros.length > maxEnterosPrecio) {
      return 'El precio es demasiado elevado';
    }

    if (partes.length == 2 && partes[1].length > maxDecimalesPrecio) {
      return 'Máximo $maxDecimalesPrecio decimales';
    }

    return null;
  }

  static String? validarExistencias(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Ingresa las existencias';
    }

    final texto = valor.trim();

    if (texto.startsWith('-')) {
      return 'Las existencias no pueden ser negativas';
    }

    if (!_regexEntero.hasMatch(texto)) {
      return 'Ingresa un número entero (sin decimales ni símbolos)';
    }

    final cantidad = int.tryParse(texto);

    if (cantidad == null || cantidad > maxExistencias) {
      return 'Máximo $maxExistencias existencias';
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // USUARIOS
  // ---------------------------------------------------------------------------

  static String? validarNombreUsuario(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Ingresa el nombre del usuario';
    }

    final nombre = normalizarEspacios(valor);

    if (nombre.length < minNombreUsuario) {
      return 'Debe tener al menos $minNombreUsuario caracteres';
    }

    if (nombre.length > maxNombreUsuario) {
      return 'Máximo $maxNombreUsuario caracteres';
    }

    if (!_regexNombreUsuario.hasMatch(nombre)) {
      return 'Usa solo letras, espacios, punto, apóstrofe o guion';
    }

    return null;
  }

  static String? validarCorreo(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Ingresa el correo electrónico';
    }

    final correo = valor.trim();

    if (correo.length > maxCorreo) {
      return 'El correo no puede superar $maxCorreo caracteres';
    }

    if (!_regexCorreo.hasMatch(correo)) {
      return 'Ingresa un correo válido (ejemplo: nombre@dominio.com)';
    }

    if (correo.split('@').first.length > maxParteLocalCorreo) {
      return 'La parte antes de la @ es demasiado larga';
    }

    return null;
  }

  /// Revisa que el correo no esté ya registrado por otro usuario.
  /// La comparación ignora mayúsculas/minúsculas.
  static String? validarCorreoDisponible(
    String? valor,
    Iterable<String> correosExistentes,
  ) {
    if (valor == null) return null;

    final correo = valor.trim().toLowerCase();
    if (correo.isEmpty) return null;

    final repetido = correosExistentes.any(
      (existente) => existente.trim().toLowerCase() == correo,
    );

    return repetido ? 'Este correo ya está registrado' : null;
  }

  static String? validarTelefono(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Ingresa el teléfono';
    }

    final telefono = normalizarEspacios(valor);

    if (telefono.length > maxTelefono) {
      return 'Máximo $maxTelefono caracteres';
    }

    if (!_regexTelefono.hasMatch(telefono)) {
      return 'Solo dígitos, espacios, guiones, paréntesis y + al inicio';
    }

    final abiertos = '('.allMatches(telefono).length;
    final cerrados = ')'.allMatches(telefono).length;

    if (abiertos != cerrados) {
      return 'Revisa los paréntesis del teléfono';
    }

    final digitos = telefono.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitos.length < minDigitosTelefono ||
        digitos.length > maxDigitosTelefono) {
      return 'El teléfono debe tener entre $minDigitosTelefono y '
          '$maxDigitosTelefono dígitos';
    }

    return null;
  }

  /// [obligatoria] = false se usa al editar un usuario, donde dejar el campo
  /// vacío significa "no cambiar la contraseña".
  static String? validarContrasena(
    String? valor, {
    bool obligatoria = true,
  }) {
    if (valor == null || valor.isEmpty) {
      return obligatoria ? 'Ingresa una contraseña' : null;
    }

    if (valor.length < minContrasena) {
      return 'La contraseña debe tener al menos $minContrasena caracteres';
    }

    if (valor.length > maxContrasena) {
      return 'La contraseña no puede superar $maxContrasena caracteres';
    }

    if (!_regexCaracteresContrasena.hasMatch(valor)) {
      return 'No se permiten espacios, emojis ni caracteres especiales raros';
    }

    if (!RegExp('[$_letras]').hasMatch(valor) ||
        !RegExp(r'[0-9]').hasMatch(valor)) {
      return 'Debe incluir al menos una letra y un número';
    }

    return null;
  }

  /// Compara la confirmación con la contraseña escrita.
  /// Si ambas están vacías (edición sin cambio de contraseña) es válido.
  static String? validarConfirmacionContrasena(
    String? confirmacion,
    String? contrasena,
  ) {
    final original = contrasena ?? '';
    final repetida = confirmacion ?? '';

    if (original.isEmpty && repetida.isEmpty) return null;

    if (repetida.isEmpty) return 'Confirma la contraseña';

    if (repetida != original) return 'Las contraseñas no coinciden';

    return null;
  }
}
