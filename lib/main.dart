import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Variable para controlar qué botón está seleccionado
  String _selectedItem = 'Ropa';

  @override
  Widget build(BuildContext context) {
    // Calculamos 1/3 del ancho de la pantalla
    double drawerWidth = MediaQuery.of(context).size.width / 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text('IA Design Shop'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      drawer: SizedBox(
        width: 80,
        child: Drawer(
          backgroundColor: Colors.white,
          child: Column( // Usamos Column en lugar de ListView para usar Spacer
            children: [
              // 1. BOTÓN DE PERFIL (Superior)
              const SizedBox(height: 50),
              _buildMenuItem(Icons.person_pin, 'Perfil'),

              const Divider(indent: 20, endIndent: 20), // Línea divisoria sutil

              // 2. BOTONES CENTRALES
              _buildMenuItem(Icons.stars_outlined, 'Ropa'),
              _buildMenuItem(Icons.stars_outlined, 'Otros'),
              _buildMenuItem(Icons.stars_outlined, 'IA Design'),

              // El Spacer empuja todo lo que viene debajo al final del menú
              const Spacer(),

              // 3. BOTÓN DEL CARRITO (Inferior)
              _buildMenuItem(Icons.shopping_cart_outlined, 'Carrito'),
              const SizedBox(height: 30), // Espacio final
            ],
          ),
        ),
      ),
      body: Center(
        child: Text(
          'Sección: $_selectedItem',
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  // Widget personalizado para los botones con el efecto de "píldora"
  Widget _buildMenuItem(IconData icon, String title) {
    bool isSelected = _selectedItem == title;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedItem = title;
        });
        // Si quieres que el menú se cierre al hacer clic, descomenta la siguiente línea:
        // Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            // El contenedor que crea el óvalo de selección
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFE8DEF8) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                isSelected ? _getSolidIcon(icon) : icon,
                size: 28,
                color: const Color(0xFF1D1B20),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: const Color(0xFF1D1B20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Función auxiliar para cambiar a icono sólido cuando se selecciona
  IconData _getSolidIcon(IconData icon) {
    if (icon == Icons.stars_outlined) return Icons.stars;
    if (icon == Icons.person_pin) return Icons.person;
    if (icon == Icons.shopping_cart_outlined) return Icons.shopping_cart;
    return icon;
  }
}