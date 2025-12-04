class Traking {
  final int? id;
  final String? latitud;
  final String? longitud;
  final String userDeliveryID;
  final String estado;
  final String? ordenCod;
  final String? comentario;

  Traking({
    this.id,
    this.latitud,
    this.longitud,
    required this.userDeliveryID,
    required this.estado,
    this.ordenCod,
    this.comentario,
  });

  factory Traking.fromJson(Map<String, dynamic> json) {
    return Traking(
      id: json['id'],
      latitud: json['latitud'],
      longitud: json['longitud'],
      userDeliveryID: json['user_delivery_id'],
      estado: json['estado'],
      ordenCod: json['orden_cod'],
      comentario: json['comentario'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'latitud': latitud,
    'longitud': longitud,
    'user_delivery_id': userDeliveryID,
    'estado': estado,
    'orden_cod': ordenCod,
    'comentario': comentario,
  };
}
