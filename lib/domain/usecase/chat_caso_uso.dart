import 'package:oasis/domain/model/mensaje.dart';
import 'package:oasis/domain/model/chat_resumen.dart';
import 'package:oasis/domain/repository/chat_repositorio.dart';

/// UseCase para operaciones de chat
/// Orquesta las operaciones del repositorio y aplica lógica de negocio
class ChatCasoUso {
  final ChatRepositorio repositorio;

  ChatCasoUso(this.repositorio);

  /// Obtiene la lista de chats
  Future<List<ChatResumen>> listarChats({
    required int userId,
    int? vacanteId,
    int? empresaId,
  }) async {
    try {
      return await repositorio.listarChats(
        userId: userId,
        vacanteId: vacanteId,
        empresaId: empresaId,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Obtiene la lista paginada de chats con búsqueda
  Future<Map<String, dynamic>> listarChatsPaginado({
    required int userId,
    String searchTerm = "",
    int page = 0,
    int size = 10,
  }) async {
    try {
      return await repositorio.listarChatsPaginado(
        userId: userId,
        searchTerm: searchTerm,
        page: page,
        size: size,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Obtiene mensajes paginados
  Future<List<Mensaje>> obtenerMensajesPaginados({
    required int postulacionId,
    required int page,
    required int size,
  }) async {
    try {
      return await repositorio.obtenerMensajesPaginados(
        postulacionId: postulacionId,
        page: page,
        size: size,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Obtiene todos los mensajes
  Future<List<Mensaje>> obtenerTodosMensajes({
    required int postulacionId,
  }) async {
    try {
      return await repositorio.obtenerTodosMensajes(
        postulacionId: postulacionId,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Marca mensajes como leído
  Future<int> marcarComoLeido({
    required int postulacionId,
    required int userId,
  }) async {
    try {
      return await repositorio.marcarComoLeido(
        postulacionId: postulacionId,
        userId: userId,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Envía un nuevo mensaje
  Future<Mensaje> enviarMensaje({
    required int postulacionId,
    required int usuarioId,
    required String texto,
  }) async {
    try {
      if (texto.trim().isEmpty) {
        throw Exception("El texto del mensaje no puede estar vacío");
      }
      return await repositorio.enviarMensaje(
        postulacionId: postulacionId,
        usuarioId: usuarioId,
        texto: texto.trim(),
      );
    } catch (e) {
      rethrow;
    }
  }
}


