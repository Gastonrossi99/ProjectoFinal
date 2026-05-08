import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/producto.dart';
import '../services/firebase_service.dart';
import '../services/db_service.dart';

class RopaDetalleView extends StatelessWidget {
  final Producto producto;
  final String categoryName;
  final VoidCallback onBack;
  final Function(Producto) onProductSelected;

  const RopaDetalleView({
    super.key,
    required this.producto,
    required this.categoryName,
    required this.onBack,
    required this.onProductSelected,
  });

  @override
  Widget build(BuildContext context) {
    final FirebaseService firebaseService = FirebaseService();
    final DBService dbService = DBService();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: onBack,
        ),
        title: Text(
          categoryName,
          style: const TextStyle(color: Colors.black, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen del producto
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 300,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F0F8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: producto.backgroundImage.isNotEmpty
                            ? (producto.backgroundImage.startsWith('data:image')
                                ? Image.memory(
                                    base64Decode(producto.backgroundImage.split(',').last),
                                    fit: BoxFit.contain,
                                  )
                                : Image.network(producto.backgroundImage, fit: BoxFit.contain))
                            : const Icon(Icons.shopping_bag_outlined, size: 100, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                  // Detalles del producto
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          producto.nombre,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          producto.detalles,
                          style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          '${producto.coste.toStringAsFixed(2)} \$',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            final String? email = prefs.getString('user_email');

                            if (email != null) {
                              await dbService.addToCart(producto.productID ?? 0, email);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Producto añadido al carrito'),
                                    backgroundColor: Color(0xFF6750A4),
                                  ),
                                );
                              }
                            } else {
                              if (context.mounted) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Inicio de sesión requerido'),
                                    content: const Text('Necesitas iniciar sesión para añadir productos al carrito.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cerrar'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6750A4),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text('Add to cart', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Sección "Misma colección"
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                children: [
                  Text(
                    'Misma colección',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward),
                ],
              ),
            ),

            SizedBox(
              height: 250,
              child: StreamBuilder<List<Producto>>(
                stream: firebaseService.getProductosFiltrados(licenseID: producto.licenseID),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  
                  // Filtrar el producto actual de la lista de recomendados
                  final productos = snapshot.data!
                      .where((p) => p.productID != producto.productID)
                      .toList();

                  if (productos.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text('No hay más productos en esta colección'),
                    );
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: productos.length,
                    itemBuilder: (context, index) {
                      final p = productos[index];
                      return GestureDetector(
                        onTap: () => onProductSelected(p),
                        child: Container(
                          width: 300,
                          margin: const EdgeInsets.only(right: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[200]!),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F0F8),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: p.backgroundImage.isNotEmpty
                                      ? (p.backgroundImage.startsWith('data:image')
                                          ? Image.memory(
                                              base64Decode(p.backgroundImage.split(',').last),
                                              fit: BoxFit.contain,
                                            )
                                          : Image.network(p.backgroundImage, fit: BoxFit.contain))
                                      : const Icon(Icons.image),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.nombre,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      p.detalles,
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
