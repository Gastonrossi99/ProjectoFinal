import 'package:shared_preferences/shared_preferences.dart';

class DBService {
  static final DBService _instance = DBService._internal();
  factory DBService() => _instance;
  DBService._internal();

  static const String _cartKey = 'carrito_items';
  static const String _favsKey = 'favoritos_items';

  // --- CARRITO ---
  // Insert a product into the cart
  Future<void> addToCart(int productID) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cart = prefs.getStringList(_cartKey) ?? [];
    
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

  // --- FAVORITOS ---
  // Add product to favorites
  Future<void> addToFavorites(int productID) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favs = prefs.getStringList(_favsKey) ?? [];
    
    if (!favs.contains(productID.toString())) {
      favs.add(productID.toString());
      await prefs.setStringList(_favsKey, favs);
    }
  }

  // Get all favorite product IDs
  Future<List<int>> getFavoriteProductIDs() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favs = prefs.getStringList(_favsKey) ?? [];
    return favs.map((id) => int.parse(id)).toList();
  }

  // Remove from favorites
  Future<void> removeFromFavorites(int productID) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favs = prefs.getStringList(_favsKey) ?? [];
    favs.remove(productID.toString());
    await prefs.setStringList(_favsKey, favs);
  }

  // Check if a product is favorite
  Future<bool> isFavorite(int productID) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> favs = prefs.getStringList(_favsKey) ?? [];
    return favs.contains(productID.toString());
  }
}
