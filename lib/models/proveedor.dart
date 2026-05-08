class Proveedor {
  int? proveedorID;
  String nombre;

  Proveedor({
    this.proveedorID,
    required this.nombre,
  });

  Map<String, dynamic> toMap() {
    return {
      'proveedorID': proveedorID,
      'nombre': nombre,
    };
  }

  factory Proveedor.fromMap(Map<String, dynamic> map) {
    return Proveedor(
      proveedorID: map['proveedorID'],
      nombre: map['nombre'],
    );
  }
}
