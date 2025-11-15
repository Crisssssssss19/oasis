import 'package:oasis/domain/model/inbox_evento.dart';

/// DTO para mapear eventos de inbox desde WebSocket
class InboxEventoDto {
  final int postulacionId;
  final int usuarioId;
  final String preview;
  final DateTime fecha;
  final int noLeidos;

  const InboxEventoDto({
    required this.postulacionId,
    required this.usuarioId,
    required this.preview,
    required this.fecha,
    required this.noLeidos,
  });

  /// Factory para crear desde JSON del WebSocket
  factory InboxEventoDto.fromJson(Map<String, dynamic> json) {
    return InboxEventoDto(
      postulacionId: json['postulacionId'] as int? ?? 0,
      usuarioId: json['usuarioId'] as int? ?? 0,
      preview: json['preview'] as String? ?? "",
      // Parsear como UTC y convertir a hora local
      fecha: json['fecha'] is String
          ? DateTime.parse(json['fecha'] as String).toLocal()
          : (json['fecha'] as DateTime? ?? DateTime.now()),
      noLeidos: json['noLeidos'] as int? ?? 0,
    );
  }

  /// Mapea DTO a modelo de dominio
  InboxEvento toModel() {
    return InboxEvento(
      postulacionId: postulacionId,
      usuarioId: usuarioId,
      preview: preview,
      fecha: fecha,
      noLeidos: noLeidos,
    );
  }
}


