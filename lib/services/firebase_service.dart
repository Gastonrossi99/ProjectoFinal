import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/categoria.dart';
import '../models/producto.dart';
import '../models/proveedor.dart';
import '../models/pedido.dart';
import '../models/licencia.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Colecciones
  final String _usersColl = 'users';
  final String _categoriasColl = 'categorias';
  final String _productosColl = 'productos';
  final String _proveedoresColl = 'proveedores';
  final String _pedidosColl = 'pedidos';
  final String _licenciasColl = 'licencias';

  // --- USUARIOS ---
  Future<void> addUser(User user) async {
    final snapshot = await _db.collection(_usersColl).get();
    int newId = snapshot.docs.length + 1;
    user.userID = newId;
    
    await _db.collection(_usersColl).add(user.toMap());
  }

  Stream<List<User>> getUsers() {
    return _db.collection(_usersColl).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => User.fromMap(doc.data())).toList());
  }

  Future<User?> getUserByEmail(String email) async {
    final snapshot = await _db
        .collection(_usersColl)
        .where('correo', isEqualTo: email)
        .limit(1)
        .get();
    
    if (snapshot.docs.isNotEmpty) {
      return User.fromMap(snapshot.docs.first.data());
    }
    return null;
  }

  // --- CATEGORIAS ---
  Future<void> addCategoria(Categoria categoria) async {
    final snapshot = await _db.collection(_categoriasColl).get();
    categoria.categoriaID = snapshot.docs.length + 1;
    await _db.collection(_categoriasColl).add(categoria.toMap());
  }

  Stream<List<Categoria>> getCategorias() {
    return _db
        .collection(_categoriasColl)
        .orderBy('categoriaID')
        .snapshots()
        .map((snapshot) =>
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

  Future<Producto?> getProductoById(int productID) async {
    final snapshot = await _db
        .collection(_productosColl)
        .where('productID', isEqualTo: productID)
        .limit(1)
        .get();
    
    if (snapshot.docs.isNotEmpty) {
      return Producto.fromMap(snapshot.docs.first.data());
    }
    return null;
  }

  Stream<List<Producto>> getProductosFiltrados({int? categoriaID, int? licenseID}) {
    Query query = _db.collection(_productosColl);
    if (categoriaID != null) {
      query = query.where('categoriaID', isEqualTo: categoriaID);
    }
    if (licenseID != null) {
      query = query.where('licenseID', isEqualTo: licenseID);
    }
    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Producto.fromMap(doc.data() as Map<String, dynamic>)).toList());
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

  // --- LICENCIAS ---
  Future<void> addLicencia(Licencia licencia) async {
    final snapshot = await _db.collection(_licenciasColl).get();
    int newId = snapshot.docs.length + 1;
    licencia.licenseID = newId;
    
    await _db.collection(_licenciasColl).add(licencia.toMap());
  }

  Stream<List<Licencia>> getLicencias() {
    return _db
        .collection(_licenciasColl)
        .orderBy('licenseID')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Licencia.fromMap(doc.data())).toList());
  }
}
