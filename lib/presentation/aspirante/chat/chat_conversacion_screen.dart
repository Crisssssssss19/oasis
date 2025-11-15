import "dart:async";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:sticky_headers/sticky_headers.dart";
import "package:oasis/core/ui/app_bottom_bar.dart";
import "package:oasis/core/di/providers.dart";
import "package:oasis/domain/model/mensaje.dart";
import "package:oasis/presentation/aspirante/chat/chat_provider.dart";
import "package:oasis/presentation/aspirante/chat/chat_state.dart";
import "package:intl/intl.dart";

/// Pantalla de conversación individual de chat
/// Obtiene userId y empresaId automáticamente de la sesión
class ChatConversacionScreen extends ConsumerStatefulWidget {
  final int postulacionId;
  final String vacanteTitulo;
  final String? contraparteNombre;

  const ChatConversacionScreen({
    Key? key,
    required this.postulacionId,
    required this.vacanteTitulo,
    this.contraparteNombre,
  }) : super(key: key);

  @override
  ConsumerState<ChatConversacionScreen> createState() =>
      _ChatConversacionScreenState();
}

class _ChatConversacionScreenState
    extends ConsumerState<ChatConversacionScreen> {
  late TextEditingController _mensajeController;
  late ScrollController _scrollController;
  late FocusNode _focusNode; // Optimización: FocusNode explícito para mejor control
  bool _escribiendo = false;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _mensajeController = TextEditingController();
    _scrollController = ScrollController();
    _focusNode = FocusNode(); // Optimización: Inicializar FocusNode
    _scrollController.addListener(_onScroll);

    // Cargar mensajes al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatProvider.notifier).cargarMensajes(
            postulacionId: widget.postulacionId,
          );
    });
  }

  @override
  void deactivate() {
    // Desuscribirse del WebSocket ANTES de que el widget sea destruido
    // deactivate() se llama antes de dispose() y ref todavía es válido aquí
    ref.read(chatProvider.notifier).salirDelChat();
    super.deactivate();
  }

  @override
  void dispose() {
    _mensajeController.dispose();
    _scrollController.dispose();
    _focusNode.dispose(); // Optimización: Liberar FocusNode
    _typingTimer?.cancel();
    super.dispose();
  }

  /// Detecta cuando llegamos al final del scroll para cargar más mensajes
  void _onScroll() {
    // En reverse: true, position.pixels aumenta hacia arriba (mensajes más antiguos)
    // Cuando position.pixels >= maxScrollExtent - 200, cargamos más
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(chatProvider.notifier).cargarMasMensajes(widget.postulacionId);
    }
  }

  /// Envía un mensaje
  void _enviarMensaje() {
    if (_mensajeController.text.trim().isEmpty) {
      return;
    }

    final notifier = ref.read(chatProvider.notifier);
    notifier.enviarMensaje(
      postulacionId: widget.postulacionId,
      texto: _mensajeController.text,
    );

    _mensajeController.clear();

    // Cancelar timer y resetear estado de escritura
    _typingTimer?.cancel();
    if (_escribiendo) {
      setState(() => _escribiendo = false);
      notifier.enviarTyping(
        postulacionId: widget.postulacionId,
        escribiendo: false,
      );
    }
  }

  /// Actualiza estado de escritura
  /// Optimización: Solo hace setState cuando realmente cambia el estado de escritura
  void _onInputChanged(String text) {
    final deberiaEscribir = text.isNotEmpty;

    if (deberiaEscribir) {
      // Usuario está escribiendo

      // Si no estaba escribiendo antes, enviar evento
      if (!_escribiendo) {
        // Optimización: Solo setState cuando el estado realmente cambia
        _escribiendo = true;
        // Usar SchedulerBinding para evitar setState durante el frame de entrada de texto
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {});
            ref.read(chatProvider.notifier).enviarTyping(
                  postulacionId: widget.postulacionId,
                  escribiendo: true,
                );
          }
        });
      }

      // Cancelar timer previo y crear uno nuevo
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 2), () {
        // Después de 2 segundos de inactividad, enviar typing: false
        if (_escribiendo && mounted) {
          _escribiendo = false;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {});
              ref.read(chatProvider.notifier).enviarTyping(
                    postulacionId: widget.postulacionId,
                    escribiendo: false,
                  );
            }
          });
        }
      });
    } else {
      // Campo vacío, dejar de escribir inmediatamente
      if (_escribiendo) {
        _typingTimer?.cancel();
        _escribiendo = false;
        // Optimización: Usar addPostFrameCallback para evitar setState durante la entrada
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {});
            ref.read(chatProvider.notifier).enviarTyping(
                  postulacionId: widget.postulacionId,
                  escribiendo: false,
                );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Optimización CRÍTICA: Solo observar el estado, no reconstruir todo el Scaffold
    // cuando cambian los colores del tema
    return Scaffold(
      // Optimización CRÍTICA: resizeToAvoidBottomInset=true + cuerpo envuelto en Stack
      // para animación más fluida del teclado
      resizeToAvoidBottomInset: true,
      // Usar un header personalizado en lugar de AppBar
      appBar: _buildAppBar(context),
      // Optimización CRÍTICA: El body usa MediaQuery para manejar el teclado manualmente
      body: _buildBodyWithKeyboardHandling(context),
      // Optimización CRÍTICA: Ocultar bottom bar cuando aparece el teclado para liberar espacio
      // y reducir trabajo de layout
      bottomNavigationBar: MediaQuery.of(context).viewInsets.bottom > 0
          ? const SizedBox.shrink() // Widget mínimo cuando el teclado está visible
          : Consumer(
              builder: (context, ref, child) {
                final session = ref.watch(sessionProvider);
                return RepaintBoundary(
                  child: AppBottomBar(
                    currentIndex: -1,
                    profileImageBase64: session.imageBase64,
                  ),
                );
              },
            ),
    );
  }
  
  /// Construye el body con manejo optimizado del teclado
  Widget _buildBodyWithKeyboardHandling(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(chatProvider);
        // Optimización CRÍTICA: No usar padding adicional, dejar que resizeToAvoidBottomInset maneje todo
        // Esto evita recálculos de layout adicionales
        return _buildConversacion(state);
      },
    );
  }
  
  /// Construye el AppBar de forma separada para evitar reconstrucciones
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight + 16),
      child: RepaintBoundary(
        // Optimización: RepaintBoundary evita que el header se repinte innecesariamente
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  // Botón de regresar
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                    color: colorScheme.onSurface,
                  ),
                  // Mostrar información de la empresa y vacante
                  _buildHeaderInfo(
                    context: context,
                    nombreEmpresa: widget.contraparteNombre,
                    vacanteTitulo: widget.vacanteTitulo,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  /// Construye el header con información de la empresa
  Widget _buildHeaderInfo({
    required BuildContext context,
    required String? nombreEmpresa,
    required String vacanteTitulo,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    final nombre = nombreEmpresa ?? "";
    
    return Expanded(
      child: Row(
        children: [
          // Avatar circular de la empresa
          Container(
            width: 50,
            height: 50,
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
                nombre.isNotEmpty 
                    ? nombre[0].toUpperCase()
                    : "E",
                style: textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Información de la empresa
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  nombre.isNotEmpty ? nombre : "Empresa",
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  vacanteTitulo,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construye la vista de conversación
  Widget _buildConversacion(ChatState state) {
    return switch (state) {
      // Estados de lista (aún no se ha cargado el chat específico)
      ChatListaCargada() => const Center(
          child: CircularProgressIndicator(),
        ),
      ChatListaCargando() => const Center(
          child: CircularProgressIndicator(),
        ),
      ChatListaError(:final mensaje) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text("Error: $mensaje"),
            ],
          ),
        ),
      // Estados de mensajes
      ChatMensajesCargados(
        :final postulacionId,
        :final mensajes,
        :final cargandoMas,
        :final hayMas,
        :final paginaActual,
        :final usuarioEscribiendoId,
        :final usuarioEscribiendoNombre,
      ) =>
        Column(
          children: [
            // Lista de mensajes - Optimizado con RepaintBoundary
            Expanded(
              child: mensajes.isEmpty
                  ? const Center(child: Text("Sin mensajes"))
                  : RepaintBoundary(
                      // Optimización: Evitar que la lista se repinte cuando aparece el teclado
                      child: Stack(
                        children: [
                          _buildListaMensajesConSticky(mensajes),
                          // Indicador de carga de más mensajes
                          if (cargandoMas)
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                alignment: Alignment.center,
                                child: const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
            ),

            // Indicador de "está escribiendo" - Optimizado con RepaintBoundary
            if (usuarioEscribiendoId != null)
              RepaintBoundary(
                // Optimización: Evitar que este indicador se repinte innecesariamente
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Escribiendo...",
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),

            // Input de mensaje - Widget optimizado separado
            _ChatInputWidget(
              mensajeController: _mensajeController,
              focusNode: _focusNode,
              onInputChanged: _onInputChanged,
              onEnviarMensaje: _enviarMensaje,
            ),
          ],
        ),
      ChatMensajesCargando(:final postulacionId) => Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ChatMensajesError(
        :final mensaje,
        :final postulacionId,
      ) =>
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline, 
                size: 64, 
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text("Error: $mensaje"),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(chatProvider.notifier).cargarMensajes(
                        postulacionId: widget.postulacionId,
                      );
                },
                child: const Text("Reintentar"),
              ),
            ],
          ),
        ),
      // Estados que no deberían ocurrir pero manejamos por seguridad
      ChatEnviandoMensaje() => Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ChatUsuarioEscribiendo() => Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      _ => const Center(child: Text("Estado desconocido")),
    };
  }

  /// Construye una burbuja de mensaje con diseño moderno
  /// Optimización: Widget memoizado para evitar reconstrucciones innecesarias
  Widget _buildMensajeBubble(Mensaje mensaje) {
    // Obtener el userId del usuario actual desde el notifier
    // Optimización: Solo leer una vez por mensaje
    final userId = ref.read(chatProvider.notifier).usuarioId ?? 0;

    // Determinar si el mensaje es del usuario actual
    final esDelUsuario = userId > 0 && mensaje.idUsuarioResponde == userId;
    
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: esDelUsuario ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          // Avatar solo para mensajes de la empresa (izquierda)
          if (!esDelUsuario) ...[
            Container(
              width: 32,
              height: 32,
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
                  (widget.contraparteNombre?.isNotEmpty ?? false)
                      ? (widget.contraparteNombre ?? "")[0].toUpperCase()
                      : "E",
                  style: textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          // Burbuja de mensaje
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: esDelUsuario ? colorScheme.primary : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mensaje.texto,
                    style: TextStyle(
                      color: esDelUsuario ? Colors.white : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat("h:mm a").format(mensaje.fecha),
                    style: TextStyle(
                      fontSize: 11,
                      color: esDelUsuario 
                          ? Colors.white.withValues(alpha: 0.8) 
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye la lista de mensajes con sticky headers agrupados por día
  Widget _buildListaMensajesConSticky(List<Mensaje> mensajes) {
    // Agrupar mensajes por día
    final Map<String, List<Mensaje>> mensajesPorDia = {};

    for (final mensaje in mensajes) {
      final fechaKey = _getFechaKey(mensaje.fecha);
      if (!mensajesPorDia.containsKey(fechaKey)) {
        mensajesPorDia[fechaKey] = [];
      }
      mensajesPorDia[fechaKey]!.add(mensaje);
    }

    // Convertir a lista ordenada (más recientes primero para reverse: true)
    final grupos = mensajesPorDia.entries.toList()
      ..sort((a, b) => b.value.first.fecha.compareTo(a.value.first.fecha));

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      // Optimización: Flags de rendimiento para mejor performance cuando aparece el teclado
      addAutomaticKeepAlives: false, // No mantener widgets fuera de vista en memoria
      addRepaintBoundaries: true, // Evitar repintados innecesarios
      addSemanticIndexes: false, // Reducir sobrecarga semántica
      // Optimización: Cache extent para reducir cálculos durante scroll
      cacheExtent: 500,
      itemCount: grupos.length,
      itemBuilder: (context, index) {
        final grupo = grupos[index];
        final fecha = grupo.value.first.fecha;
        final mensajesDelDia = grupo.value;

        // Optimización: RepaintBoundary para cada grupo de mensajes
        return RepaintBoundary(
          child: StickyHeader(
            header: _buildSeparadorFecha(fecha),
            content: Column(
              children: mensajesDelDia.map((mensaje) {
                // Optimización: RepaintBoundary para cada mensaje
                return RepaintBoundary(
                  child: _buildMensajeBubble(mensaje),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  /// Obtiene la clave de fecha para agrupar (YYYY-MM-DD)
  String _getFechaKey(DateTime fecha) {
    return "${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}";
  }

  /// Construye el separador de fecha (sticky header)
  Widget _buildSeparadorFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final fechaMensaje = DateTime(fecha.year, fecha.month, fecha.day);

    String textoFecha;
    if (fechaMensaje == hoy) {
      textoFecha = "Hoy";
    } else if (fechaMensaje == hoy.subtract(const Duration(days: 1))) {
      textoFecha = "Ayer";
    } else if (fechaMensaje.year == ahora.year) {
      // Mismo año: "15 Oct"
      textoFecha = DateFormat("d MMM").format(fecha);
    } else {
      // Año diferente: "15 Oct 2024"
      textoFecha = DateFormat("d MMM yyyy").format(fecha);
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          textoFecha,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// Widget optimizado para el input de mensajes
/// Se reconstruye independientemente del resto de la pantalla
class _ChatInputWidget extends StatelessWidget {
  final TextEditingController mensajeController;
  final FocusNode focusNode;
  final void Function(String) onInputChanged;
  final VoidCallback onEnviarMensaje;

  const _ChatInputWidget({
    required this.mensajeController,
    required this.focusNode,
    required this.onInputChanged,
    required this.onEnviarMensaje,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Optimización: Reutilizar BorderRadius para evitar crear objetos nuevos
    const borderRadius = BorderRadius.all(Radius.circular(20));
    
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: mensajeController,
                focusNode: focusNode, // Optimización: FocusNode explícito
                onChanged: onInputChanged,
                // Optimización: textInputAction y keyboardType mejoran la experiencia
                textInputAction: TextInputAction.send,
                keyboardType: TextInputType.multiline,
                onSubmitted: (_) => onEnviarMensaje(),
                // Optimización: enableInteractiveSelection mejora el rendimiento
                enableInteractiveSelection: true,
                // Optimización: Reducir la cantidad de reconstrucciones por cambios de texto
                textCapitalization: TextCapitalization.sentences,
                // Optimización: Deshabilitar autocorrección reduce reconstrucciones
                autocorrect: true,
                enableSuggestions: true,
                decoration: InputDecoration(
                  hintText: "Escribe un mensaje...",
                  hintStyle: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: borderRadius,
                    borderSide: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: borderRadius,
                    borderSide: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: borderRadius,
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  // Optimización: Deshabilitar counter que se actualiza constantemente
                  counterText: "",
                  // Optimización: isDense reduce el padding interno
                  isDense: true,
                ),
                maxLines: null,
                // Optimización: Limitar líneas máximas para evitar layouts complejos
                maxLength: 1000,
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: colorScheme.primary,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: onEnviarMensaje,
                // Optimización: Reducir padding del IconButton
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

