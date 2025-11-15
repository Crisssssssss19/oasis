import 'package:dio/dio.dart';
import 'package:oasis/data/remote/dto/api_respuesta.dart';
import 'package:oasis/data/remote/dto/mensaje_dto.dart';
import 'package:oasis/data/remote/dto/chat_resumen_dto.dart';
import 'package:oasis/data/remote/dto/chat_resumen_pagina_dto.dart';

/// Cliente API para operaciones de chat
/// Realiza llamadas HTTP al backend usando Dio
class ChatApi {
  final Dio _dio;

  ChatApi(this._dio);

  /// Obtiene la lista de chats del usuario
  /// Endpoints: /api/chats?userId=...&vacanteId=...&empresaId=...
  Future<ApiRespuesta<List<ChatResumenDto>>> listarChats({
    required int userId,
    int? vacanteId,
    int? empresaId,
  }) async {
    try {
      final queryParams = {
        'userId': userId,
        if (vacanteId != null) 'vacanteId': vacanteId,
        if (empresaId != null) 'empresaId': empresaId,
      };

      final response = await _dio.get(
        'api/chats',
        queryParameters: queryParams,
        // 🔴 DESARROLLO: Sin validación de token
        // 🟢 PRODUCCIÓN: Agregar Options(extra: {"tokenRequerido": true})
      );

      return ApiRespuesta.fromJson(
        response.data as Map<String, dynamic>,
        (json) => (json as List<dynamic>)
            .map((e) => ChatResumenDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      // Manejo de error
      if (e.response?.data is Map<String, dynamic>) {
        return ApiRespuesta.fromJson(e.response!.data as Map<String, dynamic>);
      }
      return ApiRespuesta<List<ChatResumenDto>>(
        codigoEstado: e.response?.statusCode ?? -1,
        mensaje: e.message ?? 'Error desconocido',
        fechaHora: DateTime.now().toIso8601String(),
        datos: null,
        error: e.error?.toString(),
      );
    }
  }

  /// Obtiene la lista paginada de chats del usuario con búsqueda
  /// Endpoint: /api/chats/paginado?userId=...&search=...&page=0&size=10
  Future<ApiRespuesta<ChatResumenPaginaDto>> listarChatsPaginado({
    required int userId,
    String searchTerm = "",
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await _dio.get(
        'api/chats/paginado',
        queryParameters: {
          'userId': userId,
          'search': searchTerm,
          'page': page,
          'size': size,
        },
      );

      return ApiRespuesta.fromJson(
        response.data as Map<String, dynamic>,
        (json) => ChatResumenPaginaDto.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      if (e.response?.data is Map<String, dynamic>) {
        return ApiRespuesta.fromJson(e.response!.data as Map<String, dynamic>);
      }
      return ApiRespuesta<ChatResumenPaginaDto>(
        codigoEstado: e.response?.statusCode ?? -1,
        mensaje: e.message ?? 'Error desconocido',
        fechaHora: DateTime.now().toIso8601String(),
        datos: null,
        error: e.error?.toString(),
      );
    }
  }

  /// Obtiene mensajes paginados de una postulación
  /// Endpoint: /api/chats/{postId}/messages?page=0&size=30
  Future<ApiRespuesta<List<MensajeDto>>> obtenerMensajesPaginados({
    required int postulacionId,
    required int page,
    required int size,
  }) async {
    try {
      final response = await _dio.get(
        'api/chats/$postulacionId/messages',
        queryParameters: {
          'page': page,
          'size': size,
        },
        // 🔴 DESARROLLO: Sin validación de token
        // 🟢 PRODUCCIÓN: Agregar Options(extra: {"tokenRequerido": true})
      );

      return ApiRespuesta.fromJson(
        response.data as Map<String, dynamic>,
        (json) => (json as List<dynamic>)
            .map((e) => MensajeDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      if (e.response?.data is Map<String, dynamic>) {
        return ApiRespuesta.fromJson(e.response!.data as Map<String, dynamic>);
      }
      return ApiRespuesta<List<MensajeDto>>(
        codigoEstado: e.response?.statusCode ?? -1,
        mensaje: e.message ?? 'Error desconocido',
        fechaHora: DateTime.now().toIso8601String(),
        datos: null,
        error: e.error?.toString(),
      );
    }
  }

  /// Marca mensajes como leído
  /// Endpoint: POST /api/chats/{postId}/read?userId=...
  Future<ApiRespuesta<int>> marcarComoLeido({
    required int postulacionId,
    required int userId,
  }) async {
    try {
      final response = await _dio.post(
        'api/chats/$postulacionId/read',
        queryParameters: {'userId': userId},
        // 🔴 DESARROLLO: Sin validación de token
        // 🟢 PRODUCCIÓN: Agregar Options(extra: {"tokenRequerido": true})
      );

      return ApiRespuesta.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as int,
      );
    } on DioException catch (e) {
      if (e.response?.data is Map<String, dynamic>) {
        return ApiRespuesta.fromJson(e.response!.data as Map<String, dynamic>);
      }
      return ApiRespuesta<int>(
        codigoEstado: e.response?.statusCode ?? -1,
        mensaje: e.message ?? 'Error desconocido',
        fechaHora: DateTime.now().toIso8601String(),
        datos: null,
        error: e.error?.toString(),
      );
    }
  }

  /// Envía un nuevo mensaje
  /// Endpoint: POST /api/messages
  Future<ApiRespuesta<MensajeDto>> enviarMensaje({
    required int postulacionId,
    required int usuarioId,
    required String texto,
  }) async {
    try {
      final response = await _dio.post(
        'api/messages',
        data: {
          'postulacionId': postulacionId,
          'usuarioId': usuarioId,
          'texto': texto,
        },
        // 🔴 DESARROLLO: Sin validación de token
        // 🟢 PRODUCCIÓN: Agregar Options(extra: {"tokenRequerido": true})
      );

      return ApiRespuesta.fromJson(
        response.data as Map<String, dynamic>,
        (json) => MensajeDto.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      if (e.response?.data is Map<String, dynamic>) {
        return ApiRespuesta.fromJson(e.response!.data as Map<String, dynamic>);
      }
      return ApiRespuesta<MensajeDto>(
        codigoEstado: e.response?.statusCode ?? -1,
        mensaje: e.message ?? 'Error desconocido',
        fechaHora: DateTime.now().toIso8601String(),
        datos: null,
        error: e.error?.toString(),
      );
    }
  }
}

