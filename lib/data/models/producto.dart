class Producto {
  final int id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String? imagen;

  Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    this.imagen,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      precio: (json['precio'] as num).toDouble(),
      imagen: json['imagen'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'descripcion': descripcion,
        'precio': precio,
        'imagen': imagen,
      };
}
