class AccesoDatosDto {
  final String tokenApp;
  final String fotoApp;
  final int expiraEn;

  const AccesoDatosDto({
    required this.tokenApp,
    required this.fotoApp,
    required this.expiraEn,
  });

  factory AccesoDatosDto.fromJson(Map<String, dynamic> json) {
    return AccesoDatosDto(
      tokenApp: json['tokenApp'] as String,
      fotoApp: json['fotoApp'] as String,
      expiraEn: json['expiraEn'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'tokenApp': tokenApp, 'fotoApp': fotoApp, 'expiraEn': expiraEn};
  }
}
