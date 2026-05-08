class CarritoItem {
  final int? id;
  final int productID;

  CarritoItem({
    this.id,
    required this.productID,
  });

  // Convert a CarritoItem into a Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productID': productID,
    };
  }

  // Extract a CarritoItem object from a Map.
  factory CarritoItem.fromMap(Map<String, dynamic> map) {
    return CarritoItem(
      id: map['id'],
      productID: map['productID'],
    );
  }
}
