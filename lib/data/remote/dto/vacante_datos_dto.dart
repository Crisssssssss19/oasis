class VacanteDatosDto {
  final int idVacante;
  final String tituloVacante;
  final String fechaInicioVacante;
  final String minSalarioVacante;
  final String maxSalarioVacante;
  final String nombreUbicacion;
  final String nombreEmpresa;
  final String nombreJornada;
  final String nombreModalidad;
  final String nombreTipoContrato;
  final String nombrePrivadoAnuncio;
  final String nombreEstadoVacante;
  final List<String> palabrasClave;
  final String imagenUrl;

  const VacanteDatosDto({
    required this.idVacante,
    required this.tituloVacante,
    required this.fechaInicioVacante,
    required this.minSalarioVacante,
    required this.maxSalarioVacante,
    required this.nombreUbicacion,
    required this.nombreEmpresa,
    required this.nombreJornada,
    required this.nombreModalidad,
    required this.nombreTipoContrato,
    required this.nombrePrivadoAnuncio,
    required this.nombreEstadoVacante,
    required this.palabrasClave,
    required this.imagenUrl,
  });

  factory VacanteDatosDto.fromJson(Map<String, dynamic> json) {
    return VacanteDatosDto(
      idVacante: json['idVacante'] as int,
      tituloVacante: json['tituloVacante'] as String,
      fechaInicioVacante: json['fechaInicioVacante'] as String,
      minSalarioVacante: json['minSalarioVacante'] as String,
      maxSalarioVacante: json['maxSalarioVacante'] as String,
      nombreUbicacion: json['nombreUbicacion'] as String,
      nombreEmpresa: json['nombreEmpresa'] as String,
      nombreJornada: json['nombreJornada'] as String,
      nombreModalidad: json['nombreModalidad'] as String,
      nombreTipoContrato: json['nombreTipoContrato'] as String,
      nombrePrivadoAnuncio: json['nombrePrivadoAnuncio'] as String,
      nombreEstadoVacante: json['nombreEstadoVacante'] as String,
      palabrasClave: (json['palabrasClave'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      imagenUrl: json['imagenUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idVacante': idVacante,
      'tituloVacante': tituloVacante,
      'fechaInicioVacante': fechaInicioVacante,
      'minSalarioVacante': minSalarioVacante,
      'maxSalarioVacante': maxSalarioVacante,
      'nombreUbicacion': nombreUbicacion,
      'nombreEmpresa': nombreEmpresa,
      'nombreJornada': nombreJornada,
      'nombreModalidad': nombreModalidad,
      'nombreTipoContrato': nombreTipoContrato,
      'nombrePrivadoAnuncio': nombrePrivadoAnuncio,
      'nombreEstadoVacante': nombreEstadoVacante,
      'palabrasClave': palabrasClave,
      'imagenUrl': imagenUrl,
    };
  }
}
