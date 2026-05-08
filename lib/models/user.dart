class User {
  int? userID;
  String nombre;
  String apellidos;
  String correo;
  String telefono;
  String direccion;

  User({
    this.userID,
    required this.nombre,
    required this.apellidos,
    required this.correo,
    required this.telefono,
    required this.direccion,
  });

  // Convert a User into a Map. The keys must correspond to the names of the columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'userID': userID,
      'nombre': nombre,
      'apellidos': apellidos,
      'correo': correo,
      'telefono': telefono,
      'direccion': direccion,
    };
  }

  // Extract a User object from a Map.
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userID: map['userID'],
      nombre: map['nombre'],
      apellidos: map['apellidos'],
      correo: map['correo'],
      telefono: map['telefono'],
      direccion: map['direccion'],
    );
  }
}
