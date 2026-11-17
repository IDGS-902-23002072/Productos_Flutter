
import 'package:flutter/material.dart';

import 'productos_page.dart';
import 'usuarios_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int paginaActual = 0;

  final List<Widget> paginas = const [
    ProductosPage(),
    UsuariosPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: paginaActual,
        children: paginas,
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: paginaActual,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE0E7FF),

        onDestinationSelected: (index) {
          setState(() {
            paginaActual = index;
          });
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Productos',
          ),

          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Usuarios',
          ),
        ],
      ),
    );
  }
}
