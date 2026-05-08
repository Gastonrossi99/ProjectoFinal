import 'package:shared_preferences/shared_preferences.dart';
import '../models/pedido.dart';

class DBService {
  static final DBService _instance = DBService._internal();
  factory DBService() => _instance;
  DBService._internal();

  // Helper to generate unique keys per user
  String _getCartKey(String email) => 'cart_$email';
  String _getFavsKey(String email) => 'favs_$email';
  String _getPedidosKey(String email) => 'pedidos_$email';

  // --- CARRITO ---
  // Insert a product into the cart for a specific user
  Future<void> addToCart(int productID, String email) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getCartKey(email);
    List<String> cart = prefs.getStringList(key) ?? [];
    
    if (!cart.contains(productID.toString())) {
      cart.add(productID.toString());
      await prefs.setStringList(key, cart);
    }
  }

  // Get all product IDs in the cart for a specific user
  Future<List<int>> getCartProductIDs(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getCartKey(email);
    List<String> cart = prefs.getStringList(key) ?? [];
    return cart.map((id) => int.parse(id)).toList();
  }

  // Remove a product from the cart for a specific user
  Future<void> removeFromCart(int productID, String email) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getCartKey(email);
    List<String> cart = prefs.getStringList(key) ?? [];
    cart.remove(productID.toString());
    await prefs.setStringList(key, cart);
  }

  // Clear the entire cart for a specific user
  Future<void> clearCart(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_getCartKey(email));
  }

  // --- FAVORITOS ---
  // Add product to favorites for a specific user
  Future<void> addToFavorites(int productID, String email) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getFavsKey(email);
    List<String> favs = prefs.getStringList(key) ?? [];
    
    if (!favs.contains(productID.toString())) {
      favs.add(productID.toString());
      await prefs.setStringList(key, favs);
    }
  }

  // Get all favorite product IDs for a specific user
  Future<List<int>> getFavoriteProductIDs(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getFavsKey(email);
    List<String> favs = prefs.getStringList(key) ?? [];
    return favs.map((id) => int.parse(id)).toList();
  }

  // Remove from favorites for a specific user
  Future<void> removeFromFavorites(int productID, String email) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getFavsKey(email);
    List<String> favs = prefs.getStringList(key) ?? [];
    favs.remove(productID.toString());
    await prefs.setStringList(key, favs);
  }

  // Check if a product is favorite for a specific user
  Future<bool> isFavorite(int productID, String email) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getFavsKey(email);
    List<String> favs = prefs.getStringList(key) ?? [];
    return favs.contains(productID.toString());
  }

  // --- PEDIDOS ---
  // Save a order locally for a specific user
  Future<void> savePedido(Pedido pedido, String email) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getPedidosKey(email);
    List<String> pedidos = prefs.getStringList(key) ?? [];
    
    // Auto-increment ID based on list length if not present
    pedido.pedidoID ??= pedidos.length + 1;
    
    pedidos.add(pedido.toJson());
    await prefs.setStringList(key, pedidos);
  }

  // Get all orders for a specific user
  Future<List<Pedido>> getPedidos(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getPedidosKey(email);
    List<String> pedidosJson = prefs.getStringList(key) ?? [];
    return pedidosJson.map((json) => Pedido.fromJson(json)).toList();
  }
}
