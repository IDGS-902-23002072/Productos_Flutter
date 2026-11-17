
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/producto.dart';

class ApiService {

  // CONSULTAR PRODUCTOS ACTIVOS
  static Future<List<Producto>> obtenerProductos() async {
    final response = await http.get(
      Uri.parse(ApiConfig.productos),
    );

    if (response.statusCode == 200) {
      final List<dynamic> datos = jsonDecode(response.body);

      return datos
          .map((item) => Producto.fromJson(item))
          .where((producto) => producto.estatus == true)
          .toList();
    }

    throw Exception(
      'Error al consultar productos: ${response.statusCode}',
    );
  }

  // REGISTRAR PRODUCTO
  static Future<void> crearProducto(Producto producto) async {
    final response = await http.post(
      Uri.parse(ApiConfig.productos),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(producto.toJson()),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      // Diagnóstico: muestra en la consola lo enviado y lo que respondió la API.
      debugPrint(
        'POST ${ApiConfig.productos} enviado=${jsonEncode(producto.toJson())} '
        'respuesta=${response.statusCode} ${response.body}',
      );
      throw Exception(
        'Error al registrar producto: ${response.statusCode} ${response.body}',
      );
    }
  }

  // ACTUALIZAR PRODUCTO
  static Future<void> actualizarProducto(Producto producto) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.productos}/${producto.idProducto}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(producto.toJson()),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 204) {
      throw Exception(
        'Error al actualizar producto: ${response.statusCode} ${response.body}',
      );
    }
  }

  // ELIMINAR PRODUCTO (BORRADO LÓGICO)
  static Future<void> eliminarProducto(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.productos}/$id'),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 204) {
      throw Exception(
        'Error al eliminar producto: ${response.statusCode} ${response.body}',
      );
    }
  }
}
