class Pedido {
  int? pedidoID;
  int userID;
  int productID;
  int proveedorID;
  DateTime diaDeLlegada;

  Pedido({
    this.pedidoID,
    required this.userID,
    required this.productID,
    required this.proveedorID,
    required this.diaDeLlegada,
  });

  Map<String, dynamic> toMap() {
    return {
      'pedidoID': pedidoID,
      'userID': userID,
      'productID': productID,
      'proveedorID': proveedorID,
      'diaDeLlegada': diaDeLlegada.toIso8601String(),
    };
  }

  factory Pedido.fromMap(Map<String, dynamic> map) {
    return Pedido(
      pedidoID: map['pedidoID'],
      userID: map['userID'],
      productID: map['productID'],
      proveedorID: map['proveedorID'],
      diaDeLlegada: map['diaDeLlegada'] is String 
          ? DateTime.parse(map['diaDeLlegada']) 
          : (map['diaDeLlegada'] as dynamic).toDate(),
    );
  }
}
