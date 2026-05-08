import 'dart:convert';

class Pedido {
  int? pedidoID;
  int userID;
  List<int> productosIDs;
  int proveedorID;
  DateTime diaDeLlegada;

  Pedido({
    this.pedidoID,
    required this.userID,
    required this.productosIDs,
    required this.proveedorID,
    required this.diaDeLlegada,
  });

  Map<String, dynamic> toMap() {
    return {
      'pedidoID': pedidoID,
      'userID': userID,
      'productosIDs': productosIDs,
      'proveedorID': proveedorID,
      'diaDeLlegada': diaDeLlegada.toIso8601String(),
    };
  }

  factory Pedido.fromMap(Map<String, dynamic> map) {
    return Pedido(
      pedidoID: map['pedidoID'],
      userID: map['userID'],
      productosIDs: List<int>.from(map['productosIDs'] ?? []),
      proveedorID: map['proveedorID'],
      diaDeLlegada: DateTime.parse(map['diaDeLlegada']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Pedido.fromJson(String source) => Pedido.fromMap(json.decode(source));
}
