class VacantePeticionDto {
  final String campoOrden;
  final String orden;

  const VacantePeticionDto({required this.campoOrden, required this.orden});

  factory VacantePeticionDto.fromJson(Map<String, dynamic> json) {
    return VacantePeticionDto(
      campoOrden: json['campoOrden'] as String,
      orden: json['orden'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'campoOrden': campoOrden, 'orden': orden};
  }
}
