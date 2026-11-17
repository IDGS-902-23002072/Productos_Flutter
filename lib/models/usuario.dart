
class Usuario {
  final int idUsuario;
  final String nombre;
  final String correo;
  final String telefono;
  final bool estatus;
  final DateTime? createdAt;

  Usuario({
    required this.idUsuario,
    required this.nombre,
    required this.correo,
    required this.telefono,
    required this.estatus,
    this.createdAt,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      idUsuario: json['idUsuario'],
      nombre: json['nombre'] ?? '',
      correo: json['correo'] ?? '',
      telefono: json['telefono'] ?? '',
      estatus: json['estatus'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson({String? contrasena}) {
    final datos = {
      'idUsuario': idUsuario,
      'nombre': nombre,
      'correo': correo,
      'telefono': telefono,
      'estatus': estatus,
    };

    if (contrasena != null && contrasena.isNotEmpty) {
      datos['contrasena'] = contrasena;
    }

    return datos;
  }
}
