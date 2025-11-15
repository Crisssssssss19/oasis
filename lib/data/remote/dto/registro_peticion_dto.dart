class RegistroPeticionDto {
  final String telefonoAcceso;
  final String nombresUsuario;
  final String apellidosUsuario;
  final String correoAcceso;
  final String claveAcceso;

  const RegistroPeticionDto({
    required this.telefonoAcceso,
    required this.nombresUsuario,
    required this.apellidosUsuario,
    required this.correoAcceso,
    required this.claveAcceso,
  });

  Map<String, dynamic> toJson() {
    return {
      'telefonoAcceso': telefonoAcceso,
      'nombresUsuario': nombresUsuario,
      'apellidosUsuario': apellidosUsuario,
      'correoAcceso': correoAcceso,
      'claveAcceso': claveAcceso,
    };
  }
}
