import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 
import 'views/home.dart';
import 'views/perfil.dart';
import 'views/otros.dart';
import 'views/ia_design.dart';
import 'views/carrito.dart';
import 'views/tipo_de_ropa.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

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

  // Estado para el detalle
  String? _detailName;
  int? _detailId;
  String? _detailType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IAnime'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      drawer: SizedBox(
        width: 80,
        child: Drawer(
          backgroundColor: Colors.white,
          child: Column(
            children: [
              const SizedBox(height: 50),
              _buildMenuItem(Icons.person_pin, 'Perfil'),
              const Divider(indent: 20, endIndent: 20),
              _buildMenuItem(Icons.stars_outlined, 'Ropa'),
              _buildMenuItem(Icons.stars_outlined, 'Otros'),
              _buildMenuItem(Icons.stars_outlined, 'IA Design'),
              const Spacer(),
              _buildMenuItem(Icons.shopping_cart_outlined, 'Carrito'),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      body: _getBody(),
    );
  }

  // Función para devolver la vista correspondiente según la selección
  Widget _getBody() {
    if (_selectedItem == 'Ropa' && _detailName != null) {
      return ItemDetailView(
        name: _detailName!,
        id: _detailId!,
        type: _detailType!,
        onBack: () {
          setState(() {
            _detailName = null;
          });
        },
      );
    }

    switch (_selectedItem) {
      case 'Perfil':
        return const PerfilView();
      case 'Ropa':
        return HomeView(
          onShowDetail: (name, id, type) {
            setState(() {
              _detailName = name;
              _detailId = id;
              _detailType = type;
            });
          },
        );
      case 'Otros':
        return const OtrosView();
      case 'IA Design':
        return const IADesignView();
      case 'Carrito':
        return const CarritoView();
      default:
        return HomeView(
          onShowDetail: (name, id, type) {
            setState(() {
              _detailName = name;
              _detailId = id;
              _detailType = type;
            });
          },
        );
    }
  }

  Widget _buildMenuItem(IconData icon, String title) {
    bool isSelected = _selectedItem == title;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedItem = title;
          _detailName = null;
        });
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
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

  IconData _getSolidIcon(IconData icon) {
    if (icon == Icons.stars_outlined) return Icons.stars;
    if (icon == Icons.person_pin) return Icons.person;
    if (icon == Icons.shopping_cart_outlined) return Icons.shopping_cart;
    return icon;
  }
}
