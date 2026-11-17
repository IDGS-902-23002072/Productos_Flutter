
import 'package:flutter/material.dart';
import '../utils/formatos_entrada.dart';
import '../utils/validadores.dart';
import '../models/producto.dart';
import '../services/api_service.dart';

class ProductosPage extends StatefulWidget {
  const ProductosPage({super.key});

  @override
  State<ProductosPage> createState() => _ProductosPageState();
}

class _ProductosPageState extends State<ProductosPage> {
  List<Producto> productos = [];

  bool cargando = true;
  String? error;

  @override
  void initState() {
    super.initState();
    cargarProductos();
  }

  // CONSULTAR PRODUCTOS
  Future<void> cargarProductos() async {
    setState(() {
      cargando = true;
      error = null;
    });

    try {
      final resultado = await ApiService.obtenerProductos();

      if (!mounted) return;

      setState(() {
        productos = resultado;
        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString();
        cargando = false;
      });
    }
  }

  // ABRIR FORMULARIO PARA REGISTRAR O EDITAR
  Future<void> abrirFormulario({Producto? producto}) async {
    final resultado = await showDialog<Producto>(
      context: context,
      builder: (context) {
        return ProductoFormDialog(producto: producto);
      },
    );

    if (resultado == null) return;

    try {
      if (producto == null) {
        await ApiService.crearProducto(resultado);
        mostrarMensaje('Producto registrado correctamente');
      } else {
        await ApiService.actualizarProducto(resultado);
        mostrarMensaje('Producto actualizado correctamente');
      }

      await cargarProductos();
    } catch (e) {
      if (!mounted) return;
      mostrarMensaje(e.toString(), error: true);
    }
  }

  // CONFIRMAR ELIMINACIÓN LÓGICA
  Future<void> confirmarEliminacion(Producto producto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar producto'),
          content: Text(
            '¿Estás seguro de eliminar "${producto.nombre}"?',
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
      await ApiService.eliminarProducto(producto.idProducto);

      if (!mounted) return;

      mostrarMensaje('Producto eliminado correctamente');
      await cargarProductos();
    } catch (e) {
      if (!mounted) return;
      mostrarMensaje(e.toString(), error: true);
    }
  }

  // MOSTRAR MENSAJES
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
              'Mi inventario',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              'Administración de productos',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: cargarProductos,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),

      body: cargando
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 55,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No se pudieron cargar los productos',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        FilledButton(
                          onPressed: cargarProductos,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: cargarProductos,
                  child: productos.isEmpty
                      ? ListView(
                          physics:
                              const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 130),
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 75,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 15),
                            Center(
                              child: Text(
                                'No hay productos registrados',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                            Center(
                              child: Text(
                                'Agrega tu primer producto.',
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView(
                          physics:
                              const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          children: [
                            const SizedBox(height: 22),

                            const Text(
                              'Lista de productos',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 12),

                            // LISTADO DE PRODUCTOS
                            ...productos.map(
                              (producto) => ProductoCard(
                                producto: producto,
                                onEditar: () => abrirFormulario(
                                  producto: producto,
                                ),
                                onEliminar: () =>
                                    confirmarEliminacion(producto),
                              ),
                            ),
                          ],
                        ),
                ),

      // BOTÓN PARA REGISTRAR
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => abrirFormulario(),
        backgroundColor: const Color(0xFF3157D5),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo producto'),
      ),
    );
  }
}

// TARJETA DE PRODUCTO
class ProductoCard extends StatelessWidget {
  final Producto producto;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const ProductoCard({
    super.key,
    required this.producto,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final esArticulo = producto.tipo == 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 13),
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9EDFF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    esArticulo
                        ? Icons.inventory_2_outlined
                        : Icons.miscellaneous_services,
                    color: const Color(0xFF3157D5),
                    size: 27,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        producto.nombre,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ID: ${producto.idProducto}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: producto.estatus
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    producto.estatus ? 'Activo' : 'Inactivo',
                    style: TextStyle(
                      color: producto.estatus
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _dato(
                    'Precio',
                    '\$${producto.precioUnitario.toStringAsFixed(2)}',
                    Icons.attach_money,
                  ),
                ),
                Expanded(
                  child: _dato(
                    'Existencias',
                    '${producto.existencias}',
                    Icons.warehouse_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Icon(
                  esArticulo
                      ? Icons.category_outlined
                      : Icons.design_services_outlined,
                  size: 17,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Text(
                  esArticulo ? 'Artículo' : 'Servicio',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),

                const Spacer(),

                IconButton(
                  onPressed: onEditar,
                  icon: const Icon(Icons.edit_outlined),
                  color: const Color(0xFF3157D5),
                  tooltip: 'Editar',
                ),
                IconButton(
                  onPressed: onEliminar,
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                  tooltip: 'Eliminar',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dato(String titulo, String valor, IconData icono) {
    return Row(
      children: [
        Icon(
          icono,
          color: Colors.grey.shade600,
          size: 19,
        ),
        const SizedBox(width: 7),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            Text(
              valor,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// FORMULARIO PARA CREAR Y EDITAR
class ProductoFormDialog extends StatefulWidget {
  final Producto? producto;

  const ProductoFormDialog({
    super.key,
    this.producto,
  });

  @override
  State<ProductoFormDialog> createState() =>
      _ProductoFormDialogState();
}

class _ProductoFormDialogState
    extends State<ProductoFormDialog> {
  final formKey = GlobalKey<FormState>();

  late TextEditingController nombreController;
  late TextEditingController precioController;
  late TextEditingController existenciasController;

  late bool estatus;
  late int tipo;

  bool get editando => widget.producto != null;

  @override
  void initState() {
    super.initState();

    final producto = widget.producto;

    nombreController = TextEditingController(
      text: producto?.nombre ?? '',
    );

    precioController = TextEditingController(
      text: producto?.precioUnitario.toStringAsFixed(
            Validadores.maxDecimalesPrecio,
          ) ??
          '',
    );

    existenciasController = TextEditingController(
      text: producto?.existencias.toString() ?? '',
    );

    estatus = producto?.estatus ?? true;
    tipo = producto?.tipo ?? 0;
  }

  @override
  void dispose() {
    nombreController.dispose();
    precioController.dispose();
    existenciasController.dispose();
    super.dispose();
  }

  // GUARDAR FORMULARIO
  void guardar() {
    if (!formKey.currentState!.validate()) return;

    final producto = Producto(
      idProducto: widget.producto?.idProducto ?? 0,
      nombre: Validadores.normalizarEspacios(nombreController.text),
      precioUnitario: Validadores.parsearPrecio(precioController.text),
      estatus: estatus,
      existencias: int.parse(existenciasController.text.trim()),
      tipo: tipo,
    );

    Navigator.pop(context, producto);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        editando ? 'Editar producto' : 'Nuevo producto',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),

      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nombreController,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                maxLength: Validadores.maxNombreProducto,
                inputFormatters: FormatosEntrada.nombreProducto(),
                decoration: const InputDecoration(
                  labelText: 'Nombre del producto',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: Validadores.validarNombreProducto,
              ),

              const SizedBox(height: 14),

              TextFormField(
                controller: precioController,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                inputFormatters: FormatosEntrada.precio(),
                decoration: const InputDecoration(
                  labelText: 'Precio unitario',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                validator: Validadores.validarPrecio,
              ),

              const SizedBox(height: 14),

              TextFormField(
                controller: existenciasController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: FormatosEntrada.existencias(),
                decoration: const InputDecoration(
                  labelText: 'Existencias',
                  prefixIcon: Icon(Icons.warehouse_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: Validadores.validarExistencias,
              ),

              const SizedBox(height: 14),

              DropdownButtonFormField<int>(
                initialValue: tipo,
                decoration: const InputDecoration(
                  labelText: 'Tipo de producto',
                  prefixIcon: Icon(Icons.category_outlined),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 0,
                    child: Text('Artículo'),
                  ),
                  DropdownMenuItem(
                    value: 1,
                    child: Text('Servicio'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      tipo = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 10),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Producto activo'),
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
