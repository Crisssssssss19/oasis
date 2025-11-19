class PalabraClave {
  final int id;
  final String nombre;

  const PalabraClave({required this.id, required this.nombre});

  factory PalabraClave.fromJson(Map<String, dynamic> json) {
    return PalabraClave(
      id: json['id_palabra_clave'] as int,
      nombre: json['texto_palabra_clave'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id_ubicacion': id, 'nombre_ubicacion': nombre};
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PalabraClave &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
