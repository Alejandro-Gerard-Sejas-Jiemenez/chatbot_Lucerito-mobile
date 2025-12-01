class Usuario {
  final int id;
  final String nombre;
  final String correo;
  final String telefono;
  final String? direccion;

  Usuario({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.telefono,
    this.direccion,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nombre: json['nombre'],
      correo: json['correo'],
      telefono: json['telefono'],
      direccion: json['direccion'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'correo': correo,
        'telefono': telefono,
        'direccion': direccion,
      };
}
