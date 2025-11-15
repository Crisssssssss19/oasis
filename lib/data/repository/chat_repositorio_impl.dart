import 'package:dio/dio.dart';
import 'package:oasis/data/remote/chat_api.dart';
import 'package:oasis/domain/model/mensaje.dart';
import 'package:oasis/domain/model/chat_resumen.dart';
import 'package:oasis/domain/repository/chat_repositorio.dart';

/// Implementación concreta del repositorio de chat
/// Coordina entre la API y la capa de dominio
class ChatRepositorioImpl implements ChatRepositorio {
  final ChatApi api;

  ChatRepositorioImpl(this.api);

  @override
  Future<List<ChatResumen>> listarChats({
    required int userId,
    int? vacanteId,
    int? empresaId,
  }) async {
    try {
      final response = await api.listarChats(
        userId: userId,
        vacanteId: vacanteId,
        empresaId: empresaId,
      );

      if (response.esExitoso && response.datos != null) {
        // Mapea DTOs a modelos de dominio
        return response.datos!.map((dto) => dto.toModel()).toList();
      } else {
        throw Exception(response.mensaje);
      }
    } on DioException catch (e) {
      throw Exception("Error HTTP ${e.response?.statusCode ?? ''}: ${e.message}");
    } catch (e) {
      throw Exception("Error inesperado: $e");
    }
  }

  @override
  Future<Map<String, dynamic>> listarChatsPaginado({
    required int userId,
    String searchTerm = "",
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await api.listarChatsPaginado(
        userId: userId,
        searchTerm: searchTerm,
        page: page,
        size: size,
      );

      if (response.esExitoso && response.datos != null) {
        final pagina = response.datos!;
        // Mapea DTOs a modelos de dominio
        final chats = pagina.chats.map((dto) => dto.toModel()).toList();
        
        return {
          "chats": chats,
          "totalElementos": pagina.totalElementos,
          "paginaActual": pagina.paginaActual,
          "tamanoPagina": pagina.tamanoPagina,
          "totalPaginas": pagina.totalPaginas,
          "tieneMas": pagina.tieneMas,
        };
      } else {
        throw Exception(response.mensaje);
      }
    } on DioException catch (e) {
      throw Exception("Error HTTP ${e.response?.statusCode ?? ''}: ${e.message}");
    } catch (e) {
      throw Exception("Error inesperado: $e");
    }
  }

  @override
  Future<List<Mensaje>> obtenerMensajesPaginados({
    required int postulacionId,
    required int page,
    required int size,
  }) async {
    try {
      // print('🔍 [REPO] Obteniendo mensajes: postId=$postulacionId, page=$page, size=$size');
      final response = await api.obtenerMensajesPaginados(
        postulacionId: postulacionId,
        page: page,
        size: size,
      );

      // print('🔍 [REPO] Response - codigoEstado: ${response.codigoEstado}');
      // print('🔍 [REPO] Response - mensaje: ${response.mensaje}');
      // print('🔍 [REPO] Response - datos: ${response.datos}');
      // print('🔍 [REPO] Response - esExitoso: ${response.esExitoso}');

      if (response.esExitoso && response.datos != null) {
        // Mapea DTOs a modelos de dominio
        final mensajes = response.datos!.map((dto) => dto.toModel()).toList();
        print('✅ [REPO] Mensajes mapeados: ${mensajes.length}');
        return mensajes;
      } else {
        print('❌ [REPO] Error: ${response.mensaje}');
        throw Exception(response.mensaje);
      }
    } on DioException catch (e) {
      print('❌ [REPO] DioException: ${e.message}');
      throw Exception("Error HTTP ${e.response?.statusCode ?? ''}: ${e.message}");
    } catch (e) {
      print('❌ [REPO] Exception: $e');
      throw Exception("Error inesperado: $e");
    }
  }

  @override
  Future<List<Mensaje>> obtenerTodosMensajes({
    required int postulacionId,
  }) async {
    try {
      // Obtener todos con paginación (page=0, size=1000)
      final response = await api.obtenerMensajesPaginados(
        postulacionId: postulacionId,
        page: 0,
        size: 1000,
      );

      if (response.esExitoso && response.datos != null) {
        return response.datos!.map((dto) => dto.toModel()).toList();
      } else {
        throw Exception(response.mensaje);
      }
    } on DioException catch (e) {
      throw Exception("Error HTTP ${e.response?.statusCode ?? ''}: ${e.message}");
    } catch (e) {
      throw Exception("Error inesperado: $e");
    }
  }

  @override
  Future<int> marcarComoLeido({
    required int postulacionId,
    required int userId,
  }) async {
    try {
      final response = await api.marcarComoLeido(
        postulacionId: postulacionId,
        userId: userId,
      );

      if (response.esExitoso) {
        return response.datos ?? 0;
      } else {
        throw Exception(response.mensaje);
      }
    } on DioException catch (e) {
      throw Exception("Error HTTP ${e.response?.statusCode ?? ''}: ${e.message}");
    } catch (e) {
      throw Exception("Error inesperado: $e");
    }
  }

  @override
  Future<Mensaje> enviarMensaje({
    required int postulacionId,
    required int usuarioId,
    required String texto,
  }) async {
    try {
      final response = await api.enviarMensaje(
        postulacionId: postulacionId,
        usuarioId: usuarioId,
        texto: texto,
      );

      if (response.esExitoso && response.datos != null) {
        return response.datos!.toModel();
      } else {
        throw Exception(response.mensaje);
      }
    } on DioException catch (e) {
      throw Exception("Error HTTP ${e.response?.statusCode ?? ''}: ${e.message}");
    } catch (e) {
      throw Exception("Error inesperado: $e");
    }
  }
}

