class Categoria {
  int? categoriaID;
  String nombre;

  Categoria({
    this.categoriaID,
    required this.nombre,
  });

  Map<String, dynamic> toMap() {
    return {
      'categoriaID': categoriaID,
      'nombre': nombre,
    };
  }

  factory Categoria.fromMap(Map<String, dynamic> map) {
    return Categoria(
      categoriaID: map['categoriaID'],
      nombre: map['nombre'],
    );
  }
}
