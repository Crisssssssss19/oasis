import "dart:async";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:go_router/go_router.dart";
import "package:oasis/core/di/providers.dart";
import "package:oasis/core/ui/app_bottom_bar.dart";
import "package:oasis/core/ui/app_top_bar.dart";
import "package:oasis/domain/model/chat_resumen.dart";
import "package:oasis/presentation/aspirante/chat/chat_provider.dart";
import "package:oasis/presentation/aspirante/chat/chat_state.dart";
import "package:intl/intl.dart";

/// Pantalla principal del chat
/// Muestra lista de todos los chats
/// Obtiene userId y empresaId automáticamente de la sesión
class ChatScreen extends ConsumerStatefulWidget {
  
  const ChatScreen({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  // Controlador para el campo de búsqueda
  final TextEditingController _searchController = TextEditingController();
  // Nodo de foco para el campo de búsqueda
  final FocusNode _searchFocusNode = FocusNode();
  // Query de búsqueda actual
  String _searchQuery = "";
  // Controlador de scroll para detectar el final
  final ScrollController _scrollController = ScrollController();
  // Timer para debounce de búsqueda
  Timer? _debounceTimer;
  // Flag para evitar recargas innecesarias en build
  bool _haCargadoInicialmente = false;
  
  @override
  void initState() {
    super.initState();
    print("📋 [CHAT_SCREEN] initState");
    
    // Cargar chats al inicio
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _haCargadoInicialmente = true;
        ref.read(chatProvider.notifier).cargarChatsPaginado(
          searchTerm: _searchQuery,
          page: 0,
        );
      }
    });
    
    // Listener para actualizar UI cuando cambie el texto
    _searchController.addListener(() {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        if (mounted) {
          // Actualizar query sin setState para evitar reconstrucciones innecesarias
          _searchQuery = _searchController.text;
          // Cargar chats con nuevo término de búsqueda en modo silencioso
          // para evitar parpadeo al mostrar loading
          ref.read(chatProvider.notifier).cargarChatsPaginado(
            searchTerm: _searchQuery,
            page: 0,
            silencioso: true,
          );
        }
      });
    });
    
    // Listener para scroll
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
        // Cargar más cuando llegamos al 80% del scroll
        ref.read(chatProvider.notifier).cargarMasChats(_searchQuery);
      }
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Solo observar el estado sin reconstruir todo cuando cambia
    final state = ref.watch(chatProvider.select((state) {
      // Solo reconstruir si cambia el tipo de estado o los datos relevantes
      if (state is ChatListaCargada) {
        return (state.chats, state.runtimeType);
      }
      return (null, state.runtimeType);
    }));
    final session = ref.watch(sessionProvider);

    // Solo recargar si esta pantalla está visible/activa y es necesario
    final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? false;
    final fullState = ref.read(chatProvider);
    
    // Solo hacer recargas automáticas si aún no hemos cargado inicialmente
    // Esto evita reconstrucciones innecesarias que causan pérdida de foco en el buscador
    if (isCurrentRoute && !_haCargadoInicialmente) {
      // Detectar si venimos de un chat individual y cargar la lista
      if (fullState is ChatMensajesCargados || 
          fullState is ChatMensajesCargando || 
          fullState is ChatMensajesError) {
        print("📋 [CHAT_SCREEN] Estado de mensajes detectado y pantalla visible: ${fullState.runtimeType}");
        // Usar addPostFrameCallback para evitar modificar el estado durante build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _haCargadoInicialmente = true;
            print("📋 [CHAT_SCREEN] Forzando recarga de lista de chats");
            ref.read(chatProvider.notifier).cargarChatsPaginado(
              searchTerm: _searchQuery,
              page: 0,
            );
          }
        });
      } else if (fullState is ChatListaError || fullState is ChatListaCargando) {
        // Si está en loading o error, no hacer nada (ya está cargando)
        print("📋 [CHAT_SCREEN] Estado actual: ${fullState.runtimeType}");
      } else if (fullState is! ChatListaCargada) {
        // Si no es ningún estado conocido, cargar
        print("📋 [CHAT_SCREEN] Estado desconocido: ${fullState.runtimeType}, cargando chats");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _haCargadoInicialmente = true;
            ref.read(chatProvider.notifier).cargarChatsPaginado(
              searchTerm: _searchQuery,
              page: 0,
            );
          }
        });
      }
    }

    return Scaffold(
      appBar: AppTopBar(
        title: "Chats",
        notificacionesCount: 0, // TODO: Conectar con notificaciones reales
        chatCount: null, // No mostrar badge en esta pantalla
        isChatActive: true, // Icono de chat "presionado"
        onNotificacionesPressed: () => context.go("/notificaciones"),
        onChatPressed: null, // No hacer nada, ya estamos aquí
      ),
      body: _buildListaChats(fullState),
      bottomNavigationBar: AppBottomBar(
        currentIndex: -1, // No marcar ningún elemento como activo
        profileImageBase64: session.imageBase64,
      ),
    );
  }

  /// Construye la lista de chats
  Widget _buildListaChats(ChatState fullState) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    // Siempre mostrar el buscador, solo cambiar el contenido debajo
    return Column(
      children: [
        // Buscador siempre visible - no se reconstruye con cambios en la lista
        _buildSearchBar(colorScheme, textTheme),
        // Contenido dinámico basado en el estado - usar Consumer para evitar reconstruir el buscador
        Expanded(
          child: Consumer(
            builder: (context, ref, child) {
              final currentState = ref.watch(chatProvider);
              
              print("📋 [CHAT_SCREEN] Estado actual en Consumer: ${currentState.runtimeType}");
              
              return switch (currentState) {
                ChatListaCargada(chats: final chats) => _buildListaResultados(chats, colorScheme, textTheme),
                ChatListaCargando() => const Center(
                  child: CircularProgressIndicator(),
                ),
                ChatListaError(mensaje: final error) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text("Error: $error"),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(chatProvider.notifier).cargarChatsPaginado(
                            searchTerm: _searchQuery,
                            page: 0,
                          );
                        },
                        child: const Text("Reintentar"),
                      ),
                    ],
                  ),
                ),
                ChatMensajesCargados() || ChatMensajesCargando() || ChatMensajesError() => 
                  // Si estamos en estado de mensajes, recargar la lista
                  // pero SOLO si esta pantalla es la ruta actual
                  Builder(
                    builder: (context) {
                      // Verificar si esta pantalla es la actual antes de recargar
                      final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? false;
                      
                      if (isCurrentRoute) {
                        // Solo recargar si estamos viendo esta pantalla
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            print("📋 [CHAT_SCREEN] Detectado estado de mensajes en pantalla actual, recargando lista...");
                            ref.read(chatProvider.notifier).cargarChatsPaginado(
                              searchTerm: _searchQuery,
                              page: 0,
                            );
                          }
                        });
                      } else {
                        print("📋 [CHAT_SCREEN] Estado de mensajes detectado pero no es la ruta actual, ignorando");
                      }
                      
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                _ => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text("Estado: ${currentState.runtimeType}"),
                      ],
                    ),
                  ),
              };
            },
          ),
        ),
      ],
    );
  }
  
  /// Construye solo la lista de resultados (sin el buscador)
  Widget _buildListaResultados(List<ChatResumen> chats, ColorScheme colorScheme, TextTheme textTheme) {
    return chats.isEmpty
        ? Center(
            child: Text(
              "No hay chats disponibles",
            ),
          )
        : RefreshIndicator(
            onRefresh: () async {
              await ref.read(chatProvider.notifier).cargarChatsPaginado(
                searchTerm: _searchQuery,
                page: 0,
              );
            },
            child: ListView.builder(
              controller: _scrollController,
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return _buildChatItem(chat, colorScheme, textTheme);
              },
            ),
          );
  }
  
  /// Construye la barra de búsqueda
  Widget _buildSearchBar(ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        // Optimización: Deshabilitar autofocus para que no se active automáticamente
        autofocus: false,
        // Optimización: enableInteractiveSelection para mejor UX
        enableInteractiveSelection: true,
        decoration: InputDecoration(
          hintText: "Buscar chats...",
          hintStyle: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: colorScheme.onSurface.withValues(alpha: 0.8),
          ),
          filled: true,
          fillColor: colorScheme.surface.withValues(alpha: 0.5),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: colorScheme.primary,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  /// Construye un item de chat con diseño moderno
  Widget _buildChatItem(ChatResumen chat, ColorScheme colorScheme, TextTheme textTheme) {
    // Usar el nombre del estado de la postulación desde el backend
    final estadoTexto = chat.postulacionEstadoNombre ?? "En proceso";
    
    // Calcular el porcentaje basado en el ID del estado de postulación
    int porcentajeProgreso;
    switch (chat.postulacionEstado) {
      case 1:
        porcentajeProgreso = 20; // Pendiente revisión
        break;
      case 2:
        porcentajeProgreso = 40; // En revisión
        break;
      case 3:
        porcentajeProgreso = 50; // Revisión técnica
        break;
      case 4:
        porcentajeProgreso = 60; // Entrevista inicial
        break;
      case 5:
        porcentajeProgreso = 80; // Entrevista final
        break;
      case 6:
        porcentajeProgreso = 100; // Contratado
        break;
      case 7:
        porcentajeProgreso = 0; // Rechazado
        break;
      case 8:
        porcentajeProgreso = 0; // Desistió
        break;
      default:
        porcentajeProgreso = 25; // Estado desconocido
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navegar a la pantalla de conversación individual
            context.push(
              "/chat/${chat.postulacionId}",
              extra: {
                "vacanteTitulo": chat.vacanteTitulo,
                "contraparteNombre": chat.contraparteNombre,
              },
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Avatar de la empresa con badge de no leídos
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary.withValues(alpha: 0.8),
                            colorScheme.secondary.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          chat.contraparteNombre.isNotEmpty 
                              ? chat.contraparteNombre[0].toUpperCase()
                              : chat.vacanteTitulo.isNotEmpty 
                                  ? chat.vacanteTitulo[0].toUpperCase()
                                  : "C",
                          style: textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Badge de mensajes no leídos
                    if (chat.noLeidos > 0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.tertiary,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          child: Center(
                            child: Text(
                              chat.noLeidos > 99 ? "99+" : chat.noLeidos.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                // Contenido del chat
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Encabezado con nombre y hora
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              chat.contraparteNombre.isNotEmpty 
                                  ? chat.contraparteNombre
                                  : chat.vacanteTitulo,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            chat.fechaUltimoMensaje != null
                                ? DateFormat("hh:mm a").format(chat.fechaUltimoMensaje!)
                                : "",
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Último mensaje
                      Text(
                        chat.ultimoMensaje,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Etiqueta de estado
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          estadoTexto,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Barra de progreso
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: porcentajeProgreso / 100,
                              backgroundColor: colorScheme.outline.withValues(alpha: 0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.primary,
                              ),
                              borderRadius: BorderRadius.circular(4),
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "$porcentajeProgreso%",
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
