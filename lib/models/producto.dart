
class Producto {
  final int idProducto;
  final String nombre;
  final double precioUnitario;
  final bool estatus;
  final int existencias;
  final int tipo;

  Producto({
    required this.idProducto,
    required this.nombre,
    required this.precioUnitario,
    required this.estatus,
    required this.existencias,
    required this.tipo,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      idProducto: json['idProducto'],
      nombre: json['nombre'] ?? '',
      precioUnitario:
          (json['precioUnitario'] as num).toDouble(),
      estatus: json['estatus'] ?? false,
      existencias: json['existencias'] ?? 0,
      tipo: json['tipo'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idProducto': idProducto,
      'nombre': nombre,
      'precioUnitario': precioUnitario,
      'estatus': estatus,
      'existencias': existencias,
      'tipo': tipo,
    };
  }
}
