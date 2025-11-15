import 'package:oasis/domain/model/mensaje.dart';
import 'package:oasis/domain/model/chat_resumen.dart';

/// Interfaz abstracta del repositorio de chat
/// Define los contratos para operaciones de chat
abstract class ChatRepositorio {
  /// Obtiene la lista de chats del usuario
  /// [userId]: ID del usuario logueado
  /// [vacanteId]: Opcional, filtra por vacante
  /// [empresaId]: Opcional, filtra por empresa
  Future<List<ChatResumen>> listarChats({
    required int userId,
    int? vacanteId,
    int? empresaId,
  });

  /// Obtiene la lista paginada de chats con búsqueda
  /// [userId]: ID del usuario logueado
  /// [searchTerm]: Término de búsqueda (opcional)
  /// [page]: Número de página
  /// [size]: Tamaño de la página
  /// Retorna un Map con: chats, totalElementos, paginaActual, tamanoPagina, totalPaginas, tieneMas
  Future<Map<String, dynamic>> listarChatsPaginado({
    required int userId,
    String searchTerm = "",
    int page = 0,
    int size = 10,
  });

  /// Obtiene el historial de mensajes de una postulación
  /// [postulacionId]: ID de la postulación
  /// [page]: Número de página (para paginación)
  /// [size]: Cantidad de mensajes por página
  Future<List<Mensaje>> obtenerMensajesPaginados({
    required int postulacionId,
    required int page,
    required int size,
  });

  /// Obtiene todos los mensajes de una postulación
  /// [postulacionId]: ID de la postulación
  Future<List<Mensaje>> obtenerTodosMensajes({
    required int postulacionId,
  });

  /// Marca los mensajes como leídos
  /// [postulacionId]: ID de la postulación
  /// [userId]: ID del usuario que lee
  /// Retorna la cantidad de mensajes actualizados
  Future<int> marcarComoLeido({
    required int postulacionId,
    required int userId,
  });

  /// Envía un nuevo mensaje
  /// [postulacionId]: ID de la postulación
  /// [usuarioId]: ID del usuario que envía
  /// [texto]: Contenido del mensaje
  Future<Mensaje> enviarMensaje({
    required int postulacionId,
    required int usuarioId,
    required String texto,
  });
}


