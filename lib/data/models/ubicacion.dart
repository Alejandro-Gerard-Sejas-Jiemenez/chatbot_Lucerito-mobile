class Ubicacion {
  final double latitud;
  final double longitud;

  Ubicacion({
    required this.latitud,
    required this.longitud,
  });

  factory Ubicacion.fromJson(Map<String, dynamic> json) {
    return Ubicacion(
      latitud: (json['latitud'] as num).toDouble(),
      longitud: (json['longitud'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'latitud': latitud,
        'longitud': longitud,
      };
}
