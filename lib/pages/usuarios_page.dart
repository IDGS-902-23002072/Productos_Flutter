
import 'package:flutter/material.dart';

import '../models/usuario.dart';
import '../services/usuario_service.dart';

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({super.key});

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  List<Usuario> usuarios = [];

  bool cargando = true;
  String? error;

  @override
  void initState() {
    super.initState();
    cargarUsuarios();
  }

  // CONSULTAR
  Future<void> cargarUsuarios() async {
    setState(() {
      cargando = true;
      error = null;
    });

    try {
      final resultado = await UsuarioService.obtenerUsuarios();

      setState(() {
        usuarios = resultado;
        cargando = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        cargando = false;
      });
    }
  }

  // REGISTRAR Y EDITAR
  Future<void> abrirFormulario({Usuario? usuario}) async {
    final resultado = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return UsuarioFormDialog(usuario: usuario);
      },
    );

    if (resultado == null) return;

    final Usuario datos = resultado['usuario'];
    final String contrasena = resultado['contrasena'] ?? '';

    try {
      if (usuario == null) {
        await UsuarioService.crearUsuario(datos, contrasena);
        mostrarMensaje('Usuario registrado correctamente');
      } else {
        await UsuarioService.actualizarUsuario(
          datos,
          contrasena: contrasena,
        );
        mostrarMensaje('Usuario actualizado correctamente');
      }

      await cargarUsuarios();
    } catch (e) {
      mostrarMensaje(e.toString(), error: true);
    }
  }

  // ELIMINAR
  Future<void> confirmarEliminacion(Usuario usuario) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar usuario'),
          content: Text(
            '¿Estás seguro de eliminar a ${usuario.nombre}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    try {
      await UsuarioService.eliminarUsuario(usuario.idUsuario);

      mostrarMensaje('Usuario eliminado correctamente');
      await cargarUsuarios();
    } catch (e) {
      mostrarMensaje(e.toString(), error: true);
    }
  }

  void mostrarMensaje(String mensaje, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3157D5),
        foregroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Usuarios',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Administración de usuarios',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: cargarUsuarios,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 50,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 10),
                      const Text('No se pudieron cargar los usuarios'),
                      const SizedBox(height: 10),
                      FilledButton(
                        onPressed: cargarUsuarios,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: cargarUsuarios,
                  child: usuarios.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 130),
                            Icon(
                              Icons.people_outline,
                              size: 75,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 15),
                            Center(
                              child: Text(
                                'No hay usuarios registrados',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3157D5),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.groups,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                  const SizedBox(width: 15),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Usuarios registrados',
                                        style: TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                      Text(
                                        '${usuarios.length}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 22),

                            const Text(
                              'Lista de usuarios',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 12),

                            ...usuarios.map(
                              (usuario) => UsuarioCard(
                                usuario: usuario,
                                onEditar: () =>
                                    abrirFormulario(usuario: usuario),
                                onEliminar: () =>
                                    confirmarEliminacion(usuario),
                              ),
                            ),
                          ],
                        ),
                ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => abrirFormulario(),
        backgroundColor: const Color(0xFF3157D5),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Nuevo usuario'),
      ),
    );
  }
}

// TARJETA DE USUARIO
class UsuarioCard extends StatelessWidget {
  final Usuario usuario;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const UsuarioCard({
    super.key,
    required this.usuario,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 13),
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFFE9EDFF),
              child: Text(
                usuario.nombre.isNotEmpty
                    ? usuario.nombre[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Color(0xFF3157D5),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    usuario.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    usuario.correo,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    usuario.telefono,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            PopupMenuButton<String>(
              onSelected: (opcion) {
                if (opcion == 'editar') onEditar();
                if (opcion == 'eliminar') onEliminar();
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'editar',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'eliminar',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Eliminar'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// FORMULARIO PARA CREAR Y EDITAR
class UsuarioFormDialog extends StatefulWidget {
  final Usuario? usuario;

  const UsuarioFormDialog({
    super.key,
    this.usuario,
  });

  @override
  State<UsuarioFormDialog> createState() => _UsuarioFormDialogState();
}

class _UsuarioFormDialogState extends State<UsuarioFormDialog> {
  final formKey = GlobalKey<FormState>();

  late TextEditingController nombreController;
  late TextEditingController correoController;
  late TextEditingController telefonoController;
  late TextEditingController contrasenaController;

  late bool estatus;

  bool get editando => widget.usuario != null;

  @override
  void initState() {
    super.initState();

    final usuario = widget.usuario;

    nombreController = TextEditingController(
      text: usuario?.nombre ?? '',
    );

    correoController = TextEditingController(
      text: usuario?.correo ?? '',
    );

    telefonoController = TextEditingController(
      text: usuario?.telefono ?? '',
    );

    contrasenaController = TextEditingController();

    estatus = usuario?.estatus ?? true;
  }

  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    telefonoController.dispose();
    contrasenaController.dispose();
    super.dispose();
  }

  void guardar() {
    if (!formKey.currentState!.validate()) return;

    final usuario = Usuario(
      idUsuario: widget.usuario?.idUsuario ?? 0,
      nombre: nombreController.text.trim(),
      correo: correoController.text.trim(),
      telefono: telefonoController.text.trim(),
      estatus: estatus,
    );

    Navigator.pop(context, {
      'usuario': usuario,
      'contrasena': contrasenaController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        editando ? 'Editar usuario' : 'Nuevo usuario',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),

      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa el nombre';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 14),

              TextFormField(
                controller: correoController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      !RegExp(r'^[^@]+@[^@]+\.[^@]+$')
                          .hasMatch(value.trim())) {
                    return 'Ingresa un correo válido';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 14),

              TextFormField(
                controller: telefonoController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa el teléfono';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 14),

              TextFormField(
                controller: contrasenaController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: editando
                      ? 'Nueva contraseña (opcional)'
                      : 'Contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (!editando &&
                      (value == null || value.length < 6)) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  if (editando &&
                      value != null &&
                      value.isNotEmpty &&
                      value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 10),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Usuario activo'),
                value: estatus,
                onChanged: (value) {
                  setState(() {
                    estatus = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: guardar,
          child: Text(editando ? 'Actualizar' : 'Guardar'),
        ),
      ],
    );
  }
}
