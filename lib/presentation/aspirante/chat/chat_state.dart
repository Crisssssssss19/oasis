import 'package:oasis/domain/model/chat_resumen.dart';
import 'package:oasis/domain/model/mensaje.dart';

/// Estados para el módulo de chat
/// Usa sealed class para que los switches sean exhaustivos
sealed class ChatState {
  const ChatState();
}

/// Estado inicial - cargando lista de chats
class ChatListaCargando extends ChatState {
  const ChatListaCargando();
}

/// Estado con lista de chats cargada
class ChatListaCargada extends ChatState {
  final List<ChatResumen> chats;
  final int? selectedPostulacionId;
  final int paginaActual;
  final int tamanoPagina;
  final bool hayMas;
  final bool cargandoMas;

  const ChatListaCargada({
    required this.chats,
    this.selectedPostulacionId,
    this.paginaActual = 0,
    this.tamanoPagina = 10,
    this.hayMas = false,
    this.cargandoMas = false,
  });

  ChatListaCargada copyWith({
    List<ChatResumen>? chats,
    int? selectedPostulacionId,
    int? paginaActual,
    int? tamanoPagina,
    bool? hayMas,
    bool? cargandoMas,
  }) {
    return ChatListaCargada(
      chats: chats ?? this.chats,
      selectedPostulacionId: selectedPostulacionId ?? this.selectedPostulacionId,
      paginaActual: paginaActual ?? this.paginaActual,
      tamanoPagina: tamanoPagina ?? this.tamanoPagina,
      hayMas: hayMas ?? this.hayMas,
      cargandoMas: cargandoMas ?? this.cargandoMas,
    );
  }
}

/// Estado con error en lista de chats
class ChatListaError extends ChatState {
  final String mensaje;

  const ChatListaError(this.mensaje);
}

/// Estado cargando mensajes de un chat específico
class ChatMensajesCargando extends ChatState {
  final int postulacionId;

  const ChatMensajesCargando(this.postulacionId);
}

/// Estado con mensajes cargados
class ChatMensajesCargados extends ChatState {
  final int postulacionId;
  final List<Mensaje> mensajes;
  final bool cargandoMas;
  final bool hayMas;
  final int paginaActual;
  final int? usuarioEscribiendoId;
  final String? usuarioEscribiendoNombre;

  const ChatMensajesCargados({
    required this.postulacionId,
    required this.mensajes,
    this.cargandoMas = false,
    this.hayMas = true,
    this.paginaActual = 0,
    this.usuarioEscribiendoId,
    this.usuarioEscribiendoNombre,
  });

  ChatMensajesCargados copyWith({
    int? postulacionId,
    List<Mensaje>? mensajes,
    bool? cargandoMas,
    bool? hayMas,
    int? paginaActual,
    int? usuarioEscribiendoId,
    String? usuarioEscribiendoNombre,
  }) {
    return ChatMensajesCargados(
      postulacionId: postulacionId ?? this.postulacionId,
      mensajes: mensajes ?? this.mensajes,
      cargandoMas: cargandoMas ?? this.cargandoMas,
      hayMas: hayMas ?? this.hayMas,
      paginaActual: paginaActual ?? this.paginaActual,
      usuarioEscribiendoId: usuarioEscribiendoId,
      usuarioEscribiendoNombre: usuarioEscribiendoNombre,
    );
  }
}

/// Estado con error en mensajes
class ChatMensajesError extends ChatState {
  final String mensaje;
  final int postulacionId;

  const ChatMensajesError({
    required this.mensaje,
    required this.postulacionId,
  });
}

/// Estado enviando mensaje
class ChatEnviandoMensaje extends ChatState {
  final int postulacionId;
  final String textoMensaje;

  const ChatEnviandoMensaje({
    required this.postulacionId,
    required this.textoMensaje,
  });
}

/// Estado usuario escribiendo
class ChatUsuarioEscribiendo extends ChatState {
  final int postulacionId;
  final int usuarioId;
  final String nombreUsuario;

  const ChatUsuarioEscribiendo({
    required this.postulacionId,
    required this.usuarioId,
    required this.nombreUsuario,
  });
}

