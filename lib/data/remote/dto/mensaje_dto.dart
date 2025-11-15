import 'package:oasis/domain/model/mensaje.dart';

/// DTO para mapear mensajes desde la API
class MensajeDto {
  final int id;
  final int postulacionId;
  final int usuarioId;
  final String texto;
  final DateTime fecha;
  final int estado;

  const MensajeDto({
    required this.id,
    required this.postulacionId,
    required this.usuarioId,
    required this.texto,
    required this.fecha,
    required this.estado,
  });

  /// Factory para crear desde JSON del backend
  factory MensajeDto.fromJson(Map<String, dynamic> json) {
    return MensajeDto(
      id: json['id'] as int? ?? 0,
      postulacionId: json['postulacionId'] as int? ?? 0,
      usuarioId: json['usuarioId'] as int? ?? 0,
      texto: json['texto'] as String? ?? "",
      // Parsear como UTC y convertir a hora local
      fecha: json['fecha'] is String
          ? DateTime.parse(json['fecha'] as String).toLocal()
          : (json['fecha'] as DateTime? ?? DateTime.now()),
      estado: json['estado'] as int? ?? 1,
    );
  }

  /// Convierte a JSON para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postulacionId': postulacionId,
      'usuarioId': usuarioId,
      'texto': texto,
      // Convertir a UTC antes de enviar al backend
      'fecha': fecha.toUtc().toIso8601String(),
      'estado': estado,
    };
  }

  /// Mapea DTO a modelo de dominio
  Mensaje toModel() {
    return Mensaje(
      id: id,
      idPostulacion: postulacionId,
      idUsuarioResponde: usuarioId,
      texto: texto,
      fecha: fecha,
      estado: estado,
    );
  }

  /// Factory para crear desde modelo de dominio
  factory MensajeDto.fromModel(Mensaje model) {
    return MensajeDto(
      id: model.id,
      postulacionId: model.idPostulacion,
      usuarioId: model.idUsuarioResponde,
      texto: model.texto,
      fecha: model.fecha,
      estado: model.estado,
    );
  }
}


