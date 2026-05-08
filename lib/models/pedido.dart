import 'dart:convert';

class Pedido {
  int? pedidoID;
  int userID;
  List<int> productosIDs;
  int proveedorID;
  DateTime diaDeLlegada;
  double coste;

  Pedido({
    this.pedidoID,
    required this.userID,
    required this.productosIDs,
    required this.proveedorID,
    required this.diaDeLlegada,
    required this.coste,
  });

  Map<String, dynamic> toMap() {
    return {
      'pedidoID': pedidoID,
      'userID': userID,
      'productosIDs': productosIDs,
      'proveedorID': proveedorID,
      'diaDeLlegada': diaDeLlegada.toIso8601String(),
      'coste': coste,
    };
  }

  factory Pedido.fromMap(Map<String, dynamic> map) {
    return Pedido(
      pedidoID: map['pedidoID'],
      userID: map['userID'],
      productosIDs: List<int>.from(map['productosIDs'] ?? []),
      proveedorID: map['proveedorID'],
      diaDeLlegada: DateTime.parse(map['diaDeLlegada']),
      coste: (map['coste'] ?? 0.0).toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Pedido.fromJson(String source) => Pedido.fromMap(json.decode(source));
}
