import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/producto.dart';
import '../models/categoria.dart';
import '../models/licencia.dart';
import '../services/firebase_service.dart';
import '../services/db_service.dart';

class ItemDetailView extends StatefulWidget {
  final String name;
  final int id;
  final String type; // 'Categoria' o 'Licencia'
  final VoidCallback onBack;
  final Function(Producto) onShowProductDetail;

  const ItemDetailView({
    super.key,
    required this.name,
    required this.id,
    required this.type,
    required this.onBack,
    required this.onShowProductDetail,
  });

  @override
  State<ItemDetailView> createState() => _ItemDetailViewState();
}

class _ItemDetailViewState extends State<ItemDetailView> {
  final FirebaseService _service = FirebaseService();
  final DBService _dbService = DBService();
  int? _selectedFilterId; // Si es Categoria, filtra por licenseID. Si es Licencia, por categoriaID.
  List<int> _favoriteIds = [];
  bool _isLoggedIn = false;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');
    setState(() {
      _isLoggedIn = email != null;
      _userEmail = email;
    });
    if (_isLoggedIn) {
      _loadFavorites();
    }
  }

  Future<void> _loadFavorites() async {
    if (_userEmail == null) return;
    final favs = await _dbService.getFavoriteProductIDs(_userEmail!);
    setState(() {
      _favoriteIds = favs;
    });
  }

  Future<void> _toggleFavorite(int productID) async {
    if (_userEmail == null) return;
    if (_favoriteIds.contains(productID)) {
      await _dbService.removeFromFavorites(productID, _userEmail!);
      setState(() {
        _favoriteIds.remove(productID);
      });
    } else {
      await _dbService.addToFavorites(productID, _userEmail!);
      setState(() {
        _favoriteIds.add(productID);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Barra de navegación interna con botón volver
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: widget.onBack,
                ),
                Text(
                  widget.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          
          // Filtros horizontales (Chips)
          _buildFilterBar(),

          // Grid de productos filtrados
          Expanded(
            child: StreamBuilder<List<Producto>>(
              stream: widget.type == 'Categoria'
                  ? _service.getProductosFiltrados(
                      categoriaID: widget.id, 
                      licenseID: _selectedFilterId
                    )
                  : _service.getProductosFiltrados(
                      licenseID: widget.id, 
                      categoriaID: _selectedFilterId
                    ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hay productos disponibles'));
                }

                final productos = snapshot.data!;
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 0.6,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: productos.length,
                  itemBuilder: (context, index) {
                    return _buildProductCard(productos[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return SizedBox(
      height: 50,
      child: widget.type == 'Categoria'
          ? StreamBuilder<List<Licencia>>(
              stream: _service.getLicencias(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                final items = snapshot.data!;
                return _buildFilterList(items.map((e) => _FilterItemData(id: e.licenseID!, name: e.nombre)).toList());
              },
            )
          : StreamBuilder<List<Categoria>>(
              stream: _service.getCategorias(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                final items = snapshot.data!;
                return _buildFilterList(items.map((e) => _FilterItemData(id: e.categoriaID!, name: e.nombre)).toList());
              },
            ),
    );
  }

  Widget _buildFilterList(List<_FilterItemData> items) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildFilterChip(null, 'Todo');
        }
        final item = items[index - 1];
        return _buildFilterChip(item.id, item.name);
      },
    );
  }

  Widget _buildFilterChip(int? id, String label) {
    final isSelected = _selectedFilterId == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilterId = id;
          });
        },
        selectedColor: const Color(0xFFE8DEF8),
        checkmarkColor: const Color(0xFF6750A4),
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildProductCard(Producto producto) {
    final isFavorite = _favoriteIds.contains(producto.productID);
    
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.onShowProductDetail(producto),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F0F8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: producto.backgroundImage.isNotEmpty
                      ? Image.network(
                          producto.backgroundImage,
                          fit: BoxFit.contain,
                        )
                      : const Icon(Icons.shopping_bag_outlined, size: 50, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    producto.nombre,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_isLoggedIn)
                  _FavoriteButton(
                    isFavorite: isFavorite,
                    onTap: () => _toggleFavorite(producto.productID ?? 0),
                  ),
              ],
            ),
            const Text(
              'Updated today',
              style: TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback onTap;

  const _FavoriteButton({required this.isFavorite, required this.onTap});

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.3 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: Icon(
            widget.isFavorite ? Icons.bookmark : Icons.bookmark_border,
            color: widget.isFavorite ? const Color(0xFF6750A4) : Colors.grey,
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _FilterItemData {
  final int id;
  final String name;
  _FilterItemData({required this.id, required this.name});
}
