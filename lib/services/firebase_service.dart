import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/categoria.dart';
import '../models/producto.dart';
import '../models/proveedor.dart';
import '../models/pedido.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Colecciones
  final String _usersColl = 'users';
  final String _categoriasColl = 'categorias';
  final String _productosColl = 'productos';
  final String _proveedoresColl = 'proveedores';
  final String _pedidosColl = 'pedidos';

  // --- USUARIOS ---
  Future<void> addUser(User user) async {
    final snapshot = await _db.collection(_usersColl).get();
    int newId = snapshot.docs.length + 1;
    user.userID = newId;
    
    print("Enviando a Firebase: ${user.toMap()}"); // Debug para ver el ID
    await _db.collection(_usersColl).add(user.toMap());
  }

  Stream<List<User>> getUsers() {
    return _db.collection(_usersColl).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => User.fromMap(doc.data())).toList());
  }

  // --- CATEGORIAS ---
  Future<void> addCategoria(Categoria categoria) async {
    final snapshot = await _db.collection(_categoriasColl).get();
    categoria.categoriaID = snapshot.docs.length + 1;
    await _db.collection(_categoriasColl).add(categoria.toMap());
  }

  Stream<List<Categoria>> getCategorias() {
    return _db.collection(_categoriasColl).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Categoria.fromMap(doc.data())).toList());
  }

  // --- PRODUCTOS ---
  Future<void> addProducto(Producto producto) async {
    final snapshot = await _db.collection(_productosColl).get();
    producto.productID = snapshot.docs.length + 1;
    await _db.collection(_productosColl).add(producto.toMap());
  }

  Stream<List<Producto>> getProductos() {
    return _db.collection(_productosColl).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Producto.fromMap(doc.data())).toList());
  }

  // --- PROVEEDORES ---
  Future<void> addProveedor(Proveedor proveedor) async {
    final snapshot = await _db.collection(_proveedoresColl).get();
    proveedor.proveedorID = snapshot.docs.length + 1;
    await _db.collection(_proveedoresColl).add(proveedor.toMap());
  }

  Stream<List<Proveedor>> getProveedores() {
    return _db.collection(_proveedoresColl).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Proveedor.fromMap(doc.data())).toList());
  }

  // --- PEDIDOS ---
  Future<void> addPedido(Pedido pedido) async {
    final snapshot = await _db.collection(_pedidosColl).get();
    pedido.pedidoID = snapshot.docs.length + 1;
    await _db.collection(_pedidosColl).add(pedido.toMap());
  }

  Stream<List<Pedido>> getPedidos() {
    return _db.collection(_pedidosColl).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Pedido.fromMap(doc.data())).toList());
  }
}
