class Licencia {
  int? licenseID;
  String nombre;
  DateTime fechaDeExpiracion;
  String backgroundImage;

  Licencia({
    this.licenseID,
    required this.nombre,
    required this.fechaDeExpiracion,
    required this.backgroundImage,
  });

  Map<String, dynamic> toMap() {
    return {
      'licenseID': licenseID,
      'nombre': nombre,
      'fechaDeExpiracion': fechaDeExpiracion.toIso8601String(),
      'backgroundImage': backgroundImage,
    };
  }

  factory Licencia.fromMap(Map<String, dynamic> map) {
    return Licencia(
      licenseID: map['licenseID'],
      nombre: map['nombre'],
      fechaDeExpiracion: map['fechaDeExpiracion'] is String 
          ? DateTime.parse(map['fechaDeExpiracion']) 
          : (map['fechaDeExpiracion'] as dynamic).toDate(),
      backgroundImage: map['backgroundImage'] ?? '',
    );
  }
}
