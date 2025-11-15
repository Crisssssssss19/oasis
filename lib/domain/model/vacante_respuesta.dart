class VacanteRespuesta {
  final int id;
  final String titulo;
  final DateTime fechaInicioUtc;
  final String minSalario;
  final String maxSalario;
  final String ubicacion;
  final String empresa;
  final String jornada;
  final String modalidad;
  final String tipoContrato;
  final String nombrePrivadoAnuncio;
  final String estado;
  final List<String> palabrasClave;
  final String imagenUrl;

  const VacanteRespuesta({
    required this.id,
    required this.titulo,
    required this.fechaInicioUtc,
    required this.minSalario,
    required this.maxSalario,
    required this.ubicacion,
    required this.empresa,
    required this.jornada,
    required this.modalidad,
    required this.tipoContrato,
    required this.nombrePrivadoAnuncio,
    required this.estado,
    required this.palabrasClave,
    required this.imagenUrl,
  });

  DateTime get fechaInicioLocal => fechaInicioUtc.toLocal();
}
