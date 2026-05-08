import 'package:flutter/material.dart';
import '../services/db_service.dart';

class CarritoView extends StatefulWidget {
  const CarritoView({super.key});

  @override
  State<CarritoView> createState() => _CarritoViewState();
}

class _CarritoViewState extends State<CarritoView> {
  final DBService _dbService = DBService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Carrito Local'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () async {
              await _dbService.clearCart();
              setState(() {});
            },
          )
        ],
      ),
      body: FutureBuilder<List<int>>(
        future: _dbService.getCartProductIDs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('El carrito está vacío', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          final ids = snapshot.data!;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Tienes ${ids.length} productos guardados localmente'),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: ids.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.inventory_2),
                      title: Text('Producto ID: ${ids[index]}'),
                      subtitle: const Text('Guardado localmente'),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        onPressed: () async {
                          await _dbService.removeFromCart(ids[index]);
                          setState(() {});
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
