/// Evento de inbox que llega via WebSocket cuando hay nuevo mensaje
class InboxEvento {
  final int postulacionId;
  final int usuarioId;
  /// Vista previa del mensaje (truncada)
  final String preview;
  final DateTime fecha;
  /// Cantidad de mensajes no leídos
  final int noLeidos;

  const InboxEvento({
    required this.postulacionId,
    required this.usuarioId,
    required this.preview,
    required this.fecha,
    required this.noLeidos,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InboxEvento &&
          runtimeType == other.runtimeType &&
          postulacionId == other.postulacionId;

  @override
  int get hashCode => postulacionId.hashCode;
}


