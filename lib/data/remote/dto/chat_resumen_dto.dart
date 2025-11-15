import 'package:oasis/domain/model/chat_resumen.dart';

/// DTO para mapear resumen de chat desde la API
class ChatResumenDto {
  final int postulacionId;
  final String ultimoMensaje;
  final DateTime? fechaUltimoMensaje;
  final int noLeidos;
  final String vacanteTitulo;
  final int? vacanteEstado;
  final int? postulacionEstado;          // Estado de la postulación
  final String? postulacionEstadoNombre; // Nombre del estado
  final String contraparteNombre;
  final String contraparteTipo;

  const ChatResumenDto({
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

  /// Factory para crear desde JSON del backend
  factory ChatResumenDto.fromJson(Map<String, dynamic> json) {
    return ChatResumenDto(
      postulacionId: json['postulacionId'] as int? ?? 0,
      ultimoMensaje: json['ultimoMensaje'] as String? ?? "",
      // Parsear como UTC y convertir a hora local
      fechaUltimoMensaje: json['fechaUltimoMensaje'] is String
          ? DateTime.parse(json['fechaUltimoMensaje'] as String).toLocal()
          : null,
      noLeidos: json['noLeidos'] as int? ?? 0,
      vacanteTitulo: json['vacanteTitulo'] as String? ?? "",
      vacanteEstado: json['vacanteEstado'] as int?,
      postulacionEstado: json['postulacionEstado'] as int?,
      postulacionEstadoNombre: json['postulacionEstadoNombre'] as String?,
      contraparteNombre: json['contraparteNombre'] as String? ?? "Desconocido",
      contraparteTipo: json['contraparteTipo'] as String? ?? "usuario",
    );
  }

  /// Mapea DTO a modelo de dominio
  ChatResumen toModel() {
    return ChatResumen(
      postulacionId: postulacionId,
      ultimoMensaje: ultimoMensaje,
      fechaUltimoMensaje: fechaUltimoMensaje,
      noLeidos: noLeidos,
      vacanteTitulo: vacanteTitulo,
      vacanteEstado: vacanteEstado,
      postulacionEstado: postulacionEstado,
      postulacionEstadoNombre: postulacionEstadoNombre,
      contraparteNombre: contraparteNombre,
      contraparteTipo: contraparteTipo,
    );
  }
}


