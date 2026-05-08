class Categoria {
  int? categoriaID;
  String nombre;
  String backgroundImage;

  Categoria({
    this.categoriaID,
    required this.nombre,
    required this.backgroundImage,
  });

  Map<String, dynamic> toMap() {
    return {
      'categoriaID': categoriaID,
      'nombre': nombre,
      'backgroundImage': backgroundImage,
    };
  }

  factory Categoria.fromMap(Map<String, dynamic> map) {
    return Categoria(
      categoriaID: map['categoriaID'],
      nombre: map['nombre'],
      backgroundImage: map['backgroundImage'] ?? '',
    );
  }
}
