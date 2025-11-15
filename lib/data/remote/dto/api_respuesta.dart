class ApiRespuesta<T> {
  final int codigoEstado;
  final String mensaje;
  final String fechaHora;
  final T? datos;
  final String? error;

  const ApiRespuesta({
    required this.codigoEstado,
    required this.mensaje,
    required this.fechaHora,
    this.datos,
    this.error,
  });

  factory ApiRespuesta.fromJson(
      Map<String, dynamic> json, [
        T? Function(Object? json)? fromJsonT,
      ]) {
    final hasDatos = json.containsKey('datos') && json['datos'] != null;

    return ApiRespuesta<T>(
      codigoEstado: json['codigoEstado'] as int,
      mensaje: json['mensaje'] as String,
      fechaHora: json['fechaHora'] as String,
      datos: hasDatos && fromJsonT != null ? fromJsonT(json['datos']) : null,
      error: json.containsKey('error') ? json['error'] as String? : null,
    );
  }

  Map<String, dynamic> toJson(Object? Function(T value)? toJsonT) {
    return {
      'codigoEstado': codigoEstado,
      'mensaje': mensaje,
      'fechaHora': fechaHora,
      if (datos != null && toJsonT != null) 'datos': toJsonT(datos as T),
      if (error != null) 'error': error,
    };
  }

  bool get esExitoso => codigoEstado == 200 && datos != null;
  bool get esError => codigoEstado != 200 || error != null;
}