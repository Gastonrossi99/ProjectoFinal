import 'package:flutter/material.dart';

class CarritoView extends StatelessWidget {
  const CarritoView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 100, color: Color(0xFF1D1B20)),
            SizedBox(height: 16),
            Text(
              'Tu Carrito',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('No hay productos en el carrito', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
