class PinPeticionDto {
  final String telefonoAcceso;

  const PinPeticionDto({required this.telefonoAcceso});

  Map<String, dynamic> toJson() {
    return {'telefonoAcceso': telefonoAcceso};
  }
}
