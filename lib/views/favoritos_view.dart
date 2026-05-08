import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/db_service.dart';
import '../services/firebase_service.dart';

class FavoritosView extends StatefulWidget {
  final String userEmail;
  final VoidCallback onBack;
  final Function(Producto, String)? onShowProductDetail;

  const FavoritosView({
    super.key, 
    required this.userEmail, 
    required this.onBack,
    this.onShowProductDetail,
  });

  @override
  State<FavoritosView> createState() => _FavoritosViewState();
}

class _FavoritosViewState extends State<FavoritosView> {
  final DBService _dbService = DBService();
  final FirebaseService _firebaseService = FirebaseService();
  List<Producto> _favoriteProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final ids = await _dbService.getFavoriteProductIDs(widget.userEmail);
    List<Producto> products = [];
    for (int id in ids) {
      final p = await _firebaseService.getProductoById(id);
      if (p != null) products.add(p);
    }
    if (mounted) {
      setState(() {
        _favoriteProducts = products;
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
        title: const Text('Mis Favoritos', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteProducts.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bookmark_border, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Aún no tienes favoritos', style: TextStyle(color: Colors.grey, fontSize: 18)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _favoriteProducts.length,
                  itemBuilder: (context, index) {
                    final p = _favoriteProducts[index];
                    return GestureDetector(
                      onTap: () {
                        if (widget.onShowProductDetail != null) {
                          widget.onShowProductDetail!(p, 'Favoritos');
                        }
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  color: const Color(0xFFF3F0F8),
                                  child: p.backgroundImage.isNotEmpty
                                      ? Image.network(
                                          p.backgroundImage, 
                                          width: 100, // Doble de grande que antes (era 50)
                                          height: 100, 
                                          fit: BoxFit.contain
                                        )
                                      : const Icon(Icons.image, size: 100),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.nombre, 
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${p.coste.toStringAsFixed(2)} \$',
                                      style: const TextStyle(fontSize: 18, color: Color(0xFF6750A4), fontWeight: FontWeight.w500)
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () async {
                                  await _dbService.removeFromFavorites(p.productID!, widget.userEmail);
                                  _loadFavorites();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
