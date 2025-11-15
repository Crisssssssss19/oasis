import 'package:oasis/data/remote/dto/chat_resumen_dto.dart';

/// DTO para respuesta paginada de chats
class ChatResumenPaginaDto {
  final List<ChatResumenDto> chats;
  final int totalElementos;
  final int paginaActual;
  final int tamanoPagina;
  final int totalPaginas;
  final bool tieneMas;

  const ChatResumenPaginaDto({
    required this.chats,
    required this.totalElementos,
    required this.paginaActual,
    required this.tamanoPagina,
    required this.totalPaginas,
    required this.tieneMas,
  });

  /// Factory para crear desde JSON
  factory ChatResumenPaginaDto.fromJson(Map<String, dynamic> json) {
    return ChatResumenPaginaDto(
      chats: (json['chats'] as List<dynamic>?)
              ?.map((e) => ChatResumenDto.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
      totalElementos: json['totalElementos'] as int? ?? 0,
      paginaActual: json['paginaActual'] as int? ?? 0,
      tamanoPagina: json['tamanoPagina'] as int? ?? 10,
      totalPaginas: json['totalPaginas'] as int? ?? 0,
      tieneMas: json['tieneMas'] as bool? ?? false,
    );
  }
}


