import 'package:flutter/material.dart';
import '../models/pedido.dart';
import '../models/producto.dart';
import '../services/db_service.dart';
import '../services/firebase_service.dart';

class PedidosView extends StatefulWidget {
  final String userEmail;
  final VoidCallback onBack;
  final Function(Producto, String)? onShowProductDetail;

  const PedidosView({
    super.key, 
    required this.userEmail, 
    required this.onBack,
    this.onShowProductDetail,
  });

  @override
  State<PedidosView> createState() => _PedidosViewState();
}

class _PedidosViewState extends State<PedidosView> {
  final DBService _dbService = DBService();
  final FirebaseService _firebaseService = FirebaseService();
  List<Pedido> _pedidos = [];
  bool _isLoading = true;
  // Mapa para guardar los productos de cada pedido y evitar recargas constantes
  final Map<int, List<Producto>> _productosPorPedido = {};

  @override
  void initState() {
    super.initState();
    _loadPedidos();
  }

  Future<void> _loadPedidos() async {
    final pedidos = await _dbService.getPedidos(widget.userEmail);
    
    // Cargar los productos para cada pedido
    for (var pedido in pedidos) {
      List<Producto> productos = [];
      for (int id in pedido.productosIDs) {
        final p = await _firebaseService.getProductoById(id);
        if (p != null) productos.add(p);
      }
      _productosPorPedido[pedido.pedidoID!] = productos;
    }

    if (mounted) {
      setState(() {
        _pedidos = pedidos;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: widget.onBack,
        ),
        title: const Text('Mis Pedidos', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pedidos.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_shipping_outlined, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Aún no has realizado pedidos', style: TextStyle(color: Colors.grey, fontSize: 18)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _pedidos.length,
                  itemBuilder: (context, index) {
                    final pedido = _pedidos[index];
                    final productos = _productosPorPedido[pedido.pedidoID] ?? [];
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Pedido #${pedido.pedidoID}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8DEF8),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text('Procesando', style: TextStyle(color: Color(0xFF6750A4), fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const Divider(height: 32),
                            Text('${pedido.productosIDs.length} productos asociados', style: const TextStyle(fontWeight: FontWeight.w500)),
                            const SizedBox(height: 16),
                            
                            // LISTA DE IMÁGENES DE PRODUCTOS
                            SizedBox(
                              height: 80,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: productos.length,
                                itemBuilder: (context, pIndex) {
                                  final p = productos[pIndex];
                                  return GestureDetector(
                                    onTap: () {
                                      if (widget.onShowProductDetail != null) {
                                        widget.onShowProductDetail!(p, 'Mi Pedido');
                                      }
                                    },
                                    child: Container(
                                      width: 80,
                                      margin: const EdgeInsets.only(right: 12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3F0F8),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.grey[200]!),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: p.backgroundImage.isNotEmpty
                                            ? Image.network(p.backgroundImage, fit: BoxFit.contain)
                                            : const Icon(Icons.image),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            
                            const Divider(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Entrega estimada: ${pedido.diaDeLlegada.day}/${pedido.diaDeLlegada.month}/${pedido.diaDeLlegada.year}', 
                                      style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)
                                    ),
                                  ],
                                ),
                                Text(
                                  'Total: ${pedido.coste.toStringAsFixed(2)} \$',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6750A4), fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
