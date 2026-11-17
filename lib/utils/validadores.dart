
class Validadores {

  // NOMBRE DE PRODUCTO
  static String? validarNombreProducto(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Ingresa el nombre del producto';
    }

    final nombre = valor.trim();

    if (nombre.length > 100) {
      return 'Máximo 100 caracteres';
    }

    // Letras, acentos, números y algunos símbolos habituales.
    final regex = RegExp(
      r"^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ0-9][A-Za-zÁÉÍÓÚÜÑáéíóúüñ0-9 .,_()/#&+:-]*$",
    );

    if (!regex.hasMatch(nombre)) {
      return 'Contiene caracteres no permitidos';
    }

    return null;
  }

  // PRECIO
  static String? validarPrecio(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Ingresa el precio';
    }

    final precio = double.tryParse(valor.trim());

    if (precio == null || !precio.isFinite) {
      return 'Ingresa un número válido';
    }

    if (precio < 0) {
      return 'El precio no puede ser negativo';
    }

    if (precio > 999999999999) {
      return 'El precio es demasiado elevado';
    }

    return null;
  }

  // EXISTENCIAS
  static String? validarExistencias(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Ingresa las existencias';
    }

    final cantidad = int.tryParse(valor.trim());

    if (cantidad == null) {
      return 'Ingresa un número entero válido';
    }

    if (cantidad < 0) {
      return 'Las existencias no pueden ser negativas';
    }

    return null;
  }

  // NOMBRE DE USUARIO
  static String? validarNombreUsuario(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Ingresa el nombre del usuario';
    }

    final nombre = valor.trim();

    if (nombre.length > 100) {
      return 'Máximo 100 caracteres';
    }

    // Permite nombres como María José, O'Connor y Ana-Luisa.
    final regex = RegExp(
      r"^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ]+(?:[ '’-][A-Za-zÁÉÍÓÚÜÑáéíóúüñ]+)*$",
    );

    if (!regex.hasMatch(nombre)) {
      return 'Utiliza solamente letras, espacios, apóstrofes o guiones';
    }

    return null;
  }

  // CORREO
  static String? validarCorreo(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Ingresa el correo electrónico';
    }

    final correo = valor.trim();

    if (correo.length > 150) {
      return 'El correo no puede superar 150 caracteres';
    }

    final regex = RegExp(
      r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?)+$",
    );

    if (!regex.hasMatch(correo)) {
      return 'Ingresa un correo electrónico válido';
    }

    return null;
  }

  // TELÉFONO
  static String? validarTelefono(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Ingresa el teléfono';
    }

    // Permite +, espacios, guiones y paréntesis.
    final formato = RegExp(r'^\+?[0-9\s()-]+$');

    if (!formato.hasMatch(valor.trim())) {
      return 'El teléfono contiene caracteres no permitidos';
    }

    final digitos = valor.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitos.length < 10 || digitos.length > 15) {
      return 'El teléfono debe tener entre 10 y 15 dígitos';
    }

    return null;
  }

  // CONTRASEÑA
  static String? validarContrasena(
    String? valor, {
    bool obligatoria = true,
  }) {
    if (valor == null || valor.isEmpty) {
      return obligatoria ? 'Ingresa una contraseña' : null;
    }

    if (valor.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }

    if (valor.length > 64) {
      return 'La contraseña no puede superar 64 caracteres';
    }

    // No permite espacios ni caracteres de control.
    if (RegExp(r'[\s\x00-\x1F\x7F]').hasMatch(valor)) {
      return 'No se permiten espacios ni caracteres de control';
    }

    return null;
  }
}
