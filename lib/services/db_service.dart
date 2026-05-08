import 'package:shared_preferences/shared_preferences.dart';

class DBService {
  static final DBService _instance = DBService._internal();
  factory DBService() => _instance;
  DBService._internal();

  static const String _cartKey = 'carrito_items';

  // Insert a product into the cart
  Future<void> addToCart(int productID) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cart = prefs.getStringList(_cartKey) ?? [];
    
    // Guardamos como String porque SharedPreferences no guarda listas de int directamente
    if (!cart.contains(productID.toString())) {
      cart.add(productID.toString());
      await prefs.setStringList(_cartKey, cart);
    }
  }

  // Get all product IDs in the cart
  Future<List<int>> getCartProductIDs() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cart = prefs.getStringList(_cartKey) ?? [];
    return cart.map((id) => int.parse(id)).toList();
  }

  // Remove a product from the cart
  Future<void> removeFromCart(int productID) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cart = prefs.getStringList(_cartKey) ?? [];
    cart.remove(productID.toString());
    await prefs.setStringList(_cartKey, cart);
  }

  // Clear the entire cart
  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }
}
