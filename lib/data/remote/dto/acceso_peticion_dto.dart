class AccesoPeticionDto {
  final String correoAcceso;
  final String claveAcceso;

  const AccesoPeticionDto({
    required this.correoAcceso,
    required this.claveAcceso,
  });

  Map<String, dynamic> toJson() {
    return {'correoAcceso': correoAcceso, 'claveAcceso': claveAcceso};
  }
}
