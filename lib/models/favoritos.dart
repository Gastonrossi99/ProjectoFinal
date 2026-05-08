class Favoritos {
  List<int> productIDs;

  Favoritos({required this.productIDs});

  Map<String, dynamic> toMap() {
    return {
      'productIDs': productIDs,
    };
  }

  factory Favoritos.fromMap(Map<String, dynamic> map) {
    return Favoritos(
      productIDs: List<int>.from(map['productIDs'] ?? []),
    );
  }
}
