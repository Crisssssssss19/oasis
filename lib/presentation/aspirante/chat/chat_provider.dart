import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:oasis/core/di/providers.dart";
import "package:oasis/presentation/aspirante/chat/chat_notifier.dart";
import "package:oasis/presentation/aspirante/chat/chat_state.dart";

/// Provider de ChatNotifier
/// Disponible en cualquier parte de la app con ref.watch(chatProvider)
/// Se inicializa automáticamente con userId y empresaId de la sesión
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final casoUso = ref.watch(chatUseCaseProvider);
  final wsService = ref.watch(webSocketServiceProvider);
  final session = ref.watch(sessionProvider);
  
  // Crear el notifier
  final notifier = ChatNotifier(casoUso, wsService, ref);
  
  // Configurar userId y empresaId desde la sesión si están disponibles
  if (session.userId != null) {
    notifier.setUsuarioId(session.userId!);
  }
  if (session.empresaId != null) {
    notifier.setEmpresaId(session.empresaId);
  }
  
  return notifier;
});
