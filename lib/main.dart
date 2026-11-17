
import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const ProductosApp());
}

class ProductosApp extends StatelessWidget {
  const ProductosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sistema de productos',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3157D5),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
      ),
      home: const HomePage(),
    );
  }
}
