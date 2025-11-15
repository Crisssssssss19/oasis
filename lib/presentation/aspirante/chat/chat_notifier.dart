import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oasis/core/util/websocket_service.dart';
import 'package:oasis/domain/model/chat_resumen.dart';
import 'package:oasis/domain/model/mensaje.dart';
import 'package:oasis/domain/usecase/chat_caso_uso.dart';
import 'package:oasis/presentation/aspirante/chat/chat_state.dart';

/// Notifier para gestionar el estado del chat
/// Orquesta el UseCase, WebSocket y actualiza estados
class ChatNotifier extends StateNotifier<ChatState> {
  final ChatCasoUso casoUso;
  final WebSocketService wsService;
  final Ref ref;

  /// ID del usuario actual (debe proporcionarse)
  int? _usuarioId;

  /// ID de la empresa del usuario actual (opcional)
  int? _empresaId;

  /// Suscripción a eventos WebSocket
  StreamSubscription<ChatEventoWS>? _wsSubscription;

  /// Chat actual seleccionado
  int? _chatActual;

  /// Timer para ocultar el indicador de "escribiendo"
  Timer? _typingTimer;

  ChatNotifier(this.casoUso, this.wsService, this.ref)
      : super(const ChatListaCargando()) {
    _inicializarWebSocket();
  }

  /// Establece el usuario actual
  void setUsuarioId(int userId) {
    _usuarioId = userId;
  }

  /// Establece la empresa del usuario actual
  void setEmpresaId(int? empresaId) {
    _empresaId = empresaId;
  }

  /// Obtiene el ID del usuario actual
  int? get usuarioId => _usuarioId;

  /// Inicializa WebSocket
  void _inicializarWebSocket() {
    // Conectar a WebSocket
    wsService.conectar().ignore();

    // Escuchar eventos de WebSocket
    _wsSubscription = wsService.eventos.listen(
      (evento) => _procesarEventoWS(evento),
      onError: (error) {
        // Error en WebSocket
      },
    );
  }

  /// Procesa eventos que llegan por WebSocket
  void _procesarEventoWS(ChatEventoWS evento) {
    if (evento is ChatMensajeEvento) {
      _procesarMensajeWS(evento.mensaje);
    } else if (evento is ChatTypingEvento) {
      _procesarTypingWS(evento.typing);
    } else if (evento is ChatInboxEvento) {
      _procesarInboxWS(evento.inbox);
    }
  }

  /// Procesa nuevo mensaje recibido por WS
  void _procesarMensajeWS(Map<String, dynamic> mensaje) {
    try {
      final nuevoMensaje = Mensaje(
        id: mensaje['id'] as int? ?? 0,
        idPostulacion: mensaje['postulacionId'] as int? ?? 0,
        idUsuarioResponde: mensaje['usuarioId'] as int? ?? 0,
        texto: mensaje['texto'] as String? ?? "",
        // Parsear como UTC y convertir a hora local
        fecha: mensaje['fecha'] is String
            ? DateTime.parse(mensaje['fecha'] as String).toLocal()
            : DateTime.now(),
        estado: mensaje['estado'] as int? ?? 1,
      );

      if (state case ChatMensajesCargados(:final postulacionId, :final mensajes)) {
        // Si estamos DENTRO de un chat
        
        // Si es del chat actual, agregar a la lista
        if (nuevoMensaje.idPostulacion == postulacionId) {
          final mensajesActualizados = [...mensajes, nuevoMensaje];
          // Ordenar por fecha (más antiguos primero)
          mensajesActualizados.sort((a, b) => a.fecha.compareTo(b.fecha));
          
          state = (state as ChatMensajesCargados).copyWith(
            mensajes: mensajesActualizados,
          );
        }

        // Marcar como leído si es del otro usuario
        if (_usuarioId != null && nuevoMensaje.idUsuarioResponde != _usuarioId) {
          marcarComoLeido(nuevoMensaje.idPostulacion);
        }
      } else if (state is ChatListaCargada) {
        // Si estamos en la LISTA de chats, actualizar la lista
        // Actualización optimista: actualizar el último mensaje y fecha si es del otro usuario
        if (_usuarioId != null && nuevoMensaje.idUsuarioResponde != _usuarioId) {
          final estadoActual = state as ChatListaCargada;
          final chatsActualizados = estadoActual.chats.map((chat) {
            if (chat.postulacionId == nuevoMensaje.idPostulacion) {
              // Incrementar contador de no leídos y actualizar último mensaje
              return chat.copyWith(
                ultimoMensaje: nuevoMensaje.texto,
                fechaUltimoMensaje: nuevoMensaje.fecha,
                noLeidos: chat.noLeidos + 1,
              );
            }
            return chat;
          }).toList();
          
          state = estadoActual.copyWith(chats: chatsActualizados);
        }
        
        // Recargar desde el servidor para obtener el estado correcto
        cargarChatsPaginado(
          searchTerm: "",
          page: 0,
          silencioso: true,
        );
      }
    } catch (e) {
      // Error procesando mensaje
    }
  }

  /// Procesa evento de usuario escribiendo
  void _procesarTypingWS(Map<String, dynamic> typing) {
    final postulacionId = typing['postulacionId'] as int? ?? 0;
    final usuarioId = typing['userId'] as int? ?? 0;
    final estaEscribiendo = typing['typing'] as bool? ?? false;

    // Solo actualizar si estamos viendo este chat
    if (state is ChatMensajesCargados) {
      final estadoActual = state as ChatMensajesCargados;
      
      if (estadoActual.postulacionId == postulacionId && usuarioId != _usuarioId) {
        if (estaEscribiendo) {
          // Cancelar timer anterior si existe
          _typingTimer?.cancel();
          
          // Mostrar indicador de typing
          state = estadoActual.copyWith(
            usuarioEscribiendoId: usuarioId,
            usuarioEscribiendoNombre: "Usuario $usuarioId",
          );
          
          // Crear nuevo timer para ocultar después de 3 segundos
          _typingTimer = Timer(const Duration(seconds: 3), () {
            if (state is ChatMensajesCargados) {
              final s = state as ChatMensajesCargados;
              if (s.usuarioEscribiendoId == usuarioId) {
                state = s.copyWith(
                  usuarioEscribiendoId: null,
                  usuarioEscribiendoNombre: null,
                );
              }
            }
          });
        } else {
          // Ocultar indicador de typing inmediatamente
          _typingTimer?.cancel();
          state = estadoActual.copyWith(
            usuarioEscribiendoId: null,
            usuarioEscribiendoNombre: null,
          );
        }
      }
    }
  }

  /// Procesa evento de inbox
  void _procesarInboxWS(Map<String, dynamic> inbox) {
    // Si estamos en la lista de chats, actualizar
    if (state is ChatListaCargada) {
      // Recargar lista de chats en background sin cambiar el estado actual
      cargarChatsPaginado(
        searchTerm: "",
        page: 0,
        silencioso: true,
      );
    }
  }

  /// Carga la lista de chats
  /// [vacanteId]: Opcional, filtra por vacante
  /// [empresaId]: Opcional, filtra por empresa
  /// [silencioso]: Si es true, no cambia el estado (útil para refrescar en background)
  Future<void> cargarChats({
    int? vacanteId,
    int? empresaId,
    bool silencioso = false,
  }) async {
    if (_usuarioId == null) {
      if (!silencioso) {
        state = const ChatListaError("Usuario no autenticado");
      }
      return;
    }

    // Solo mostrar loading si NO estamos en modo silencioso
    if (!silencioso) {
      state = const ChatListaCargando();
    }
    
    try {
      final chats = await casoUso.listarChats(
        userId: _usuarioId!,
        vacanteId: vacanteId,
        empresaId: empresaId,
      );

      // Solo cambiar estado si NO estamos viendo mensajes O si no es silencioso
      if (!silencioso) {
        state = ChatListaCargada(chats: chats);
      }
      // Si es silencioso, solo actualizamos los chats si estamos en estado de lista
      else if (state is ChatListaCargada) {
        state = ChatListaCargada(chats: chats);
      }

      // Suscribirse a inbox del usuario
      if (wsService.estaConectado) {
        await wsService.suscribir('/topic/inbox/user/$_usuarioId');
        
        // También suscribirse a inbox de empresa si existe
        if (_empresaId != null) {
          await wsService.suscribir('/topic/inbox/company/$_empresaId');
        }
      }
    } catch (e) {
      if (!silencioso) {
        state = ChatListaError(e.toString());
      }
    }
  }

  /// Carga la lista paginada de chats con búsqueda
  /// [searchTerm]: Término de búsqueda (opcional)
  /// [page]: Número de página (por defecto 0)
  /// [size]: Tamaño de página (por defecto 10)
  /// [silencioso]: Si es true, no cambia el estado (útil para refrescar en background)
  Future<void> cargarChatsPaginado({
    String searchTerm = "",
    int page = 0,
    int size = 10,
    bool silencioso = false,
  }) async {
    if (_usuarioId == null) {
      if (!silencioso) {
        state = const ChatListaError("Usuario no autenticado");
      }
      return;
    }

    // Solo mostrar loading si NO estamos en modo silencioso Y es la primera página
    if (!silencioso && page == 0) {
      state = const ChatListaCargando();
    }
    
    try {
      final resultado = await casoUso.listarChatsPaginado(
        userId: _usuarioId!,
        searchTerm: searchTerm,
        page: page,
        size: size,
      );

      final chats = resultado["chats"] as List<ChatResumen>;
      final paginaActual = resultado["paginaActual"] as int;
      final tamanoPagina = resultado["tamanoPagina"] as int;
      final tieneMas = resultado["tieneMas"] as bool;

      // Si no es silencioso, actualizar estado
      if (!silencioso) {
        state = ChatListaCargada(
          chats: chats,
          paginaActual: paginaActual,
          tamanoPagina: tamanoPagina,
          hayMas: tieneMas,
        );
      }
      // Si es silencioso, solo actualizamos los chats si estamos en estado de lista
      else if (state is ChatListaCargada) {
        state = ChatListaCargada(
          chats: chats,
          paginaActual: paginaActual,
          tamanoPagina: tamanoPagina,
          hayMas: tieneMas,
        );
      }

      // Suscribirse a inbox del usuario
      if (wsService.estaConectado) {
        await wsService.suscribir('/topic/inbox/user/$_usuarioId');
        
        // También suscribirse a inbox de empresa si existe
        if (_empresaId != null) {
          await wsService.suscribir('/topic/inbox/company/$_empresaId');
        }
      }
    } catch (e) {
      if (!silencioso) {
        state = ChatListaError(e.toString());
      }
    }
  }

  /// Carga más chats (paginación infinita)
  Future<void> cargarMasChats(String searchTerm) async {
    if (state case ChatListaCargada(
      :final cargandoMas,
      :final hayMas,
      :final paginaActual,
      :final tamanoPagina,
    )) {
      if (cargandoMas || !hayMas) return;

      // Marcar como cargando más
      state = (state as ChatListaCargada).copyWith(cargandoMas: true);

      try {
        final siguientePagina = paginaActual + 1;
        final resultado = await casoUso.listarChatsPaginado(
          userId: _usuarioId!,
          searchTerm: searchTerm,
          page: siguientePagina,
          size: tamanoPagina,
        );

        final nuevosChats = resultado["chats"] as List<ChatResumen>;
        final tieneMas = resultado["tieneMas"] as bool;

        // Agregar los nuevos chats a la lista existente
        final chatsExistentes = (state as ChatListaCargada).chats;
        final chatsActualizados = [...chatsExistentes, ...nuevosChats];

        state = (state as ChatListaCargada).copyWith(
          chats: chatsActualizados,
          cargandoMas: false,
          hayMas: tieneMas,
          paginaActual: siguientePagina,
        );
      } catch (e) {
        state = (state as ChatListaCargada).copyWith(cargandoMas: false);
      }
    }
  }

  /// Carga los mensajes de un chat específico
  /// [postulacionId]: ID de la postulación
  /// [page]: Número de página (por defecto 0)
  /// [size]: Cantidad de mensajes por página (por defecto 30)
  Future<void> cargarMensajes({
    required int postulacionId,
    int page = 0,
    int size = 30,
  }) async {
    print('🚀 [NOTIFIER] cargarMensajes - postId=$postulacionId, page=$page, size=$size');
    _chatActual = postulacionId;
    state = ChatMensajesCargando(postulacionId);
    print('📊 [NOTIFIER] Estado cambiado a: ChatMensajesCargando');
    
    try {
      print('⏳ [NOTIFIER] Llamando a casoUso.obtenerMensajesPaginados...');
      final mensajes = await casoUso.obtenerMensajesPaginados(
        postulacionId: postulacionId,
        page: page,
        size: size,
      );

      // Ordenar mensajes por fecha (más antiguos primero)
      mensajes.sort((a, b) => a.fecha.compareTo(b.fecha));

      print('✅ [NOTIFIER] Mensajes recibidos y ordenados: ${mensajes.length}');
      state = ChatMensajesCargados(
        postulacionId: postulacionId,
        mensajes: mensajes,
        hayMas: mensajes.length == size,
        paginaActual: page,
      );
      print('📊 [NOTIFIER] Estado cambiado a: ChatMensajesCargados (${mensajes.length} mensajes)');

      // Suscribirse al chat en WebSocket
      if (wsService.estaConectado) {
        print('🔌 [NOTIFIER] Suscribiendo a WebSocket...');
        await wsService.suscribir('/topic/chat/$postulacionId');
      }

      // Marcar como leído automáticamente
      if (_usuarioId != null) {
        // print('✉️ [NOTIFIER] Marcando como leído...');
        await marcarComoLeido(postulacionId);
      }
      // print('🎉 [NOTIFIER] cargarMensajes completado!');
    } catch (e) {
      // print('❌ [NOTIFIER] Error en cargarMensajes: $e');
      state = ChatMensajesError(
        mensaje: e.toString(),
        postulacionId: postulacionId,
      );
      // print('📊 [NOTIFIER] Estado cambiado a: ChatMensajesError');
    }
  }

  /// Carga más mensajes (paginación)
  Future<void> cargarMasMensajes(int postulacionId) async {
    if (state case ChatMensajesCargados(
      :final cargandoMas,
      :final hayMas,
      :final paginaActual,
      :final mensajes,
    )) {
      if (cargandoMas || !hayMas) return;

      state = state is ChatMensajesCargados
          ? (state as ChatMensajesCargados).copyWith(cargandoMas: true)
          : state;

      try {
        final pageActuales = paginaActual + 1;
        final nuevosMensajes = await casoUso.obtenerMensajesPaginados(
          postulacionId: postulacionId,
          page: pageActuales,
          size: 30,
        );

        final mensajesActualizados = [...mensajes, ...nuevosMensajes];
        // Ordenar por fecha (más antiguos primero)
        mensajesActualizados.sort((a, b) => a.fecha.compareTo(b.fecha));
        final masDisponibles = nuevosMensajes.length == 30;

        state = (state as ChatMensajesCargados).copyWith(
          mensajes: mensajesActualizados,
          cargandoMas: false,
          hayMas: masDisponibles,
          paginaActual: pageActuales,
        );
      } catch (e) {
        state = (state as ChatMensajesCargados).copyWith(cargandoMas: false);
      }
    }
  }

  /// Envía un nuevo mensaje
  /// Via WebSocket si está conectado, fallback a REST
  Future<void> enviarMensaje({
    required int postulacionId,
    required String texto,
  }) async {
    if (_usuarioId == null) {
      return;
    }

    try {
      print('📤 [NOTIFIER] Enviando mensaje: "$texto"');
      
      // NO cambiar el estado - mantener ChatMensajesCargados
      // El mensaje llegará por WebSocket y se agregará automáticamente

      // Intentar enviar via WebSocket primero
      if (wsService.estaConectado) {
        print('📤 [NOTIFIER] Enviando via WebSocket...');
        await wsService.enviarMensaje(
          destination: '/app/chat/$postulacionId/send',
          cuerpo: {
            'postulacionId': postulacionId,
            'usuarioId': _usuarioId,
            'texto': texto,
          },
        );
        print('✅ [NOTIFIER] Mensaje enviado via WebSocket');
      } else {
        // Fallback a REST
        print('📤 [NOTIFIER] Enviando via REST...');
        final nuevoMensaje = await casoUso.enviarMensaje(
          postulacionId: postulacionId,
          usuarioId: _usuarioId!,
          texto: texto,
        );
        
        // Si usamos REST, agregar el mensaje manualmente
        if (state is ChatMensajesCargados) {
          final estadoActual = state as ChatMensajesCargados;
          final mensajesActualizados = [...estadoActual.mensajes, nuevoMensaje];
          // Ordenar por fecha (más antiguos primero)
          mensajesActualizados.sort((a, b) => a.fecha.compareTo(b.fecha));
          
          state = estadoActual.copyWith(
            mensajes: mensajesActualizados,
          );
        }
        print('✅ [NOTIFIER] Mensaje enviado via REST');
      }
    } catch (e) {
      print('❌ [NOTIFIER] Error al enviar mensaje: $e');
      // No cambiar el estado a error - solo mostrar un snackbar o log
      // state mantiene ChatMensajesCargados
    }
  }

  /// Envía indicador de typing
  Future<void> enviarTyping({
    required int postulacionId,
    required bool escribiendo,
  }) async {
    if (!wsService.estaConectado || _usuarioId == null) return;

    await wsService.enviarMensaje(
      destination: '/app/chat/$postulacionId/typing',
      cuerpo: {
        'postulacionId': postulacionId,
        'userId': _usuarioId,
        'typing': escribiendo,
      },
    );
  }

  /// Marca mensajes como leído
  Future<void> marcarComoLeido(int postulacionId) async {
    if (_usuarioId == null) return;

    try {
      await casoUso.marcarComoLeido(
        postulacionId: postulacionId,
        userId: _usuarioId!,
      );

      // Actualizar lista de chats en background sin cambiar el estado actual
      await cargarChatsPaginado(
        searchTerm: "",
        page: 0,
        silencioso: true,
      );
    } catch (e) {
      // Silenciar error en marca como leído
    }
  }

  /// Selecciona un chat en la lista
  void seleccionarChat(int postulacionId) {
    if (state case ChatListaCargada(:final chats)) {
      cargarMensajes(postulacionId: postulacionId);
    }
  }

  /// Sale del chat actual y desuscribe del WebSocket
  Future<void> salirDelChat() async {
    if (_chatActual != null) {
      print('🚪 [NOTIFIER] Saliendo del chat $_chatActual');
      
      // Desuscribirse del WebSocket del chat actual
      if (wsService.estaConectado) {
        print('🔌 [NOTIFIER] Desuscribiendo de /topic/chat/$_chatActual');
        await wsService.desuscribir('/topic/chat/$_chatActual');
      }
      
      _chatActual = null;
    }
  }

  /// Limpieza cuando se destruye el notifier
  @override
  void dispose() {
    _wsSubscription?.cancel();
    super.dispose();
  }
}
