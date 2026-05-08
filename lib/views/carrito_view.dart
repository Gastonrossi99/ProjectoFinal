import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/db_service.dart';
import '../services/firebase_service.dart';
import '../models/producto.dart';
import 'carrito_detalle_view.dart';

class CarritoView extends StatefulWidget {
  const CarritoView({super.key});

  @override
  State<CarritoView> createState() => _CarritoViewState();
}

class _CarritoViewState extends State<CarritoView> {
  final DBService _dbService = DBService();
  final FirebaseService _firebaseService = FirebaseService();
  String? _userEmail;
  String? _userName;
  bool _isLoading = true;
  
  List<Producto> _cartProducts = [];
  final Map<int, int> _quantities = {};
  final Map<int, String> _selectedSizes = {};
  bool _isNavigatingToDetalle = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');
    
    if (email != null) {
      final user = await _firebaseService.getUserByEmail(email);
      if (user != null) {
        setState(() {
          _userEmail = email;
          _userName = '${user.nombre} ${user.apellidos}';
        });
      } else {
        setState(() {
          _userEmail = email;
        });
      }
      await _loadCartProducts();
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadCartProducts() async {
    if (_userEmail == null) return;
    final ids = await _dbService.getCartProductIDs(_userEmail!);
    
    List<Producto> products = [];
    for (int id in ids) {
      final p = await _firebaseService.getProductoById(id);
      if (p != null) {
        products.add(p);
        _quantities[id] = _quantities[id] ?? 1;
      }
    }
    
    setState(() {
      _cartProducts = products;
    });
  }

  double get _totalPrice {
    double total = 0;
    for (var p in _cartProducts) {
      total += p.coste * (_quantities[p.productID] ?? 1);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_userEmail == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Carrito'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text('Inicia sesión para ver tu carrito', style: TextStyle(fontSize: 18, color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    if (_isNavigatingToDetalle) {
      return CarritoDetalleView(
        total: _totalPrice,
        onBack: () => setState(() => _isNavigatingToDetalle = false),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Carrito de ${_userName ?? _userEmail}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () async {
              await _dbService.clearCart(_userEmail!);
              setState(() {
                _cartProducts.clear();
                _quantities.clear();
              });
            },
          )
        ],
      ),
      body: _cartProducts.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Tu carrito está vacío', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            )
          : Stack(
              children: [
                ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: _cartProducts.length,
                  itemBuilder: (context, index) {
                    return _buildCartItem(_cartProducts[index]);
                  },
                ),
                Positioned(
                  bottom: 24,
                  right: 24,
                  child: ElevatedButton(
                    onPressed: () => setState(() => _isNavigatingToDetalle = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6750A4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Continue to pay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCartItem(Producto producto) {
    int qty = _quantities[producto.productID] ?? 1;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F0F8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: producto.backgroundImage.isNotEmpty
                  ? Image.network(producto.backgroundImage, fit: BoxFit.contain)
                  : const Icon(Icons.shopping_bag_outlined, size: 50, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  producto.nombre,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text('Talla: ', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    DropdownButton<String>(
                      value: _selectedSizes[producto.productID],
                      hint: const Text('desplegar', style: TextStyle(fontSize: 13, color: Colors.grey)),
                      underline: const SizedBox(),
                      isDense: true,
                      items: ['S', 'M', 'L', 'XL', 'XXL', 'XXXL'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (newVal) {
                        if (newVal != null) {
                          setState(() {
                            _selectedSizes[producto.productID!] = newVal;
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Selector de cantidad
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Text('Cantidad: ', style: TextStyle(fontSize: 13)),
                          DropdownButton<int>(
                            value: qty,
                            underline: const SizedBox(),
                            isDense: true,
                            items: List.generate(10, (i) => i + 1).map((int value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text(value.toString()),
                              );
                            }).toList(),
                            onChanged: (newVal) {
                              if (newVal != null) {
                                setState(() {
                                  _quantities[producto.productID!] = newVal;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () async {
                        await _dbService.removeFromCart(producto.productID!, _userEmail!);
                        _loadCartProducts();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${(producto.coste * qty).toStringAsFixed(2)} \$',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
