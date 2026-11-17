
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/usuario.dart';

class UsuarioService {

  // CONSULTAR USUARIOS ACTIVOS
  static Future<List<Usuario>> obtenerUsuarios() async {
    final response = await http.get(
      Uri.parse(ApiConfig.usuarios),
    );

    if (response.statusCode == 200) {
      final List<dynamic> datos = jsonDecode(response.body);

      return datos
          .map((item) => Usuario.fromJson(item))
          .where((usuario) => usuario.estatus == true)
          .toList();
    }

    throw Exception(
      'Error al consultar usuarios: ${response.statusCode}',
    );
  }

  // REGISTRAR USUARIO
  static Future<void> crearUsuario(
    Usuario usuario,
    String contrasena,
  ) async {
    final response = await http.post(
      Uri.parse(ApiConfig.usuarios),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
        usuario.toJson(contrasena: contrasena),
      ),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception(
        'Error al registrar usuario: ${response.statusCode} ${response.body}',
      );
    }
  }

  // ACTUALIZAR USUARIO
  static Future<void> actualizarUsuario(
    Usuario usuario, {
    String? contrasena,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.usuarios}/${usuario.idUsuario}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
        usuario.toJson(contrasena: contrasena),
      ),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 204) {
      throw Exception(
        'Error al actualizar usuario: ${response.statusCode} ${response.body}',
      );
    }
  }

  // ELIMINAR USUARIO (BORRADO LÓGICO)
  static Future<void> eliminarUsuario(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.usuarios}/$id'),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 204) {
      throw Exception(
        'Error al eliminar usuario: ${response.statusCode} ${response.body}',
      );
    }
  }
}
