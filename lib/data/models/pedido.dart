import 'producto.dart';
import 'usuario.dart';
import 'ubicacion.dart';

class Pedido {
  final int id;
  final Usuario usuario;
  final List<Producto> productos;
  final double total;
  final String estado;
  final Ubicacion ubicacionLocal;
  final Ubicacion ubicacionCliente;
  final String? nombreContacto;
  final String? comentario;

  Pedido({
    required this.id,
    required this.usuario,
    required this.productos,
    required this.total,
    required this.estado,
    required this.ubicacionLocal,
    required this.ubicacionCliente,
    this.nombreContacto,
    this.comentario,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      id: json['id'],
      usuario: Usuario.fromJson(json['usuario']),
      productos: (json['productos'] as List)
          .map((e) => Producto.fromJson(e))
          .toList(),
      total: (json['total'] as num).toDouble(),
      estado: json['estado'],
      ubicacionLocal: Ubicacion.fromJson(json['ubicacion_local']),
      ubicacionCliente: Ubicacion.fromJson(json['ubicacion_cliente']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'usuario': usuario.toJson(),
    'productos': productos.map((e) => e.toJson()).toList(),
    'total': total,
    'estado': estado,
    'ubicacion_local': ubicacionLocal.toJson(),
    'ubicacion_cliente': ubicacionCliente.toJson(),
  };
}
