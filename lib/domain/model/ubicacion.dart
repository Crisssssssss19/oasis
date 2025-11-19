class Ubicacion {
  final int id;
  final String nombre;

  const Ubicacion({required this.id, required this.nombre});

  factory Ubicacion.fromJson(Map<String, dynamic> json) {
    return Ubicacion(
      id: json['id_ubicacion'] as int,
      nombre: json['nombre_ubicacion'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id_ubicacion': id, 'nombre_ubicacion': nombre};
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ubicacion && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
