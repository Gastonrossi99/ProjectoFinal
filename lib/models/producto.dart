class Producto {
  int? productID;
  String nombre;
  int stock;
  double coste;
  String detalles;
  int categoriaID;
  String backgroundImage;
  int licenseID;

  Producto({
    this.productID,
    required this.nombre,
    required this.stock,
    required this.coste,
    required this.detalles,
    required this.categoriaID,
    required this.backgroundImage,
    required this.licenseID,
  });

  Map<String, dynamic> toMap() {
    return {
      'productID': productID,
      'nombre': nombre,
      'stock': stock,
      'coste': coste,
      'detalles': detalles,
      'categoriaID': categoriaID,
      'backgroundImage': backgroundImage,
      'licenseID': licenseID,
    };
  }

  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      productID: map['productID'],
      nombre: map['nombre'],
      stock: map['stock'],
      coste: map['coste'],
      detalles: map['detalles'],
      categoriaID: map['categoriaID'],
      backgroundImage: map['backgroundImage'] ?? '',
      licenseID: map['licenseID'] ?? 0,
    );
  }
}
