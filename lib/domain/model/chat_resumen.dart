/// Resumen de un chat (para listar en la bandeja de entrada)
class ChatResumen {
  final int postulacionId;
  final String ultimoMensaje;
  final DateTime? fechaUltimoMensaje;
  /// Cantidad de mensajes no leídos para este usuario
  final int noLeidos;
  final String vacanteTitulo;
  /// Estado de la vacante: 1 = abierta, 0 = cerrada
  final int? vacanteEstado;
  /// Estado de la postulación
  final int? postulacionEstado;
  /// Nombre del estado de la postulación
  final String? postulacionEstadoNombre;
  /// Nombre de la empresa (si soy candidato) o candidato (si soy empresa)
  final String contraparteNombre;
  /// Tipo de contraparte: "empresa" | "usuario"
  final String contraparteTipo;

  const ChatResumen({
    required this.postulacionId,
    required this.ultimoMensaje,
    this.fechaUltimoMensaje,
    required this.noLeidos,
    required this.vacanteTitulo,
    this.vacanteEstado,
    this.postulacionEstado,
    this.postulacionEstadoNombre,
    required this.contraparteNombre,
    required this.contraparteTipo,
  });

  /// Verifica si hay mensajes sin leer
  bool get tieneNoLeidos => noLeidos > 0;

  /// Verifica si la vacante está abierta
  bool get vacanteAbierta => vacanteEstado == 1;

  /// Copia del modelo con campos opcionales
  ChatResumen copyWith({
    int? postulacionId,
    String? ultimoMensaje,
    DateTime? fechaUltimoMensaje,
    int? noLeidos,
    String? vacanteTitulo,
    int? vacanteEstado,
    int? postulacionEstado,
    String? postulacionEstadoNombre,
    String? contraparteNombre,
    String? contraparteTipo,
  }) {
    return ChatResumen(
      postulacionId: postulacionId ?? this.postulacionId,
      ultimoMensaje: ultimoMensaje ?? this.ultimoMensaje,
      fechaUltimoMensaje: fechaUltimoMensaje ?? this.fechaUltimoMensaje,
      noLeidos: noLeidos ?? this.noLeidos,
      vacanteTitulo: vacanteTitulo ?? this.vacanteTitulo,
      vacanteEstado: vacanteEstado ?? this.vacanteEstado,
      postulacionEstado: postulacionEstado ?? this.postulacionEstado,
      postulacionEstadoNombre: postulacionEstadoNombre ?? this.postulacionEstadoNombre,
      contraparteNombre: contraparteNombre ?? this.contraparteNombre,
      contraparteTipo: contraparteTipo ?? this.contraparteTipo,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatResumen &&
          runtimeType == other.runtimeType &&
          postulacionId == other.postulacionId;

  @override
  int get hashCode => postulacionId.hashCode;
}


