import "package:dio/dio.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:oasis/data/remote/acceso_api.dart";
import "package:oasis/data/remote/pin_api.dart";
import "package:oasis/data/remote/registro_api.dart";
import "package:oasis/data/repository/acceso_repositorio_impl.dart";
import "package:oasis/data/repository/pin_repositorio_impl.dart";
import "package:oasis/data/repository/registro_repositorio_impl.dart";
import "package:oasis/domain/model/acceso_sesion.dart";
import "package:oasis/application/sesion_notifier.dart";
import "package:oasis/domain/repository/acceso_repositorio.dart";
import "package:oasis/domain/repository/pin_repositorio.dart";
import "package:oasis/domain/repository/registro_repositorio.dart";
import "package:oasis/domain/usecase/acceso_caso_uso.dart";
import "package:oasis/domain/usecase/pin_caso_uso.dart";
import "package:oasis/domain/usecase/registro_caso_uso.dart";

import "package:oasis/data/remote/vacante_api.dart";
import "package:oasis/data/repository/vacante_repositorio_impl.dart";
import "package:oasis/domain/repository/vacante_repository.dart";
import "package:oasis/domain/usecase/vacante_caso_uso.dart";

import "package:oasis/data/remote/chat_api.dart";
import "package:oasis/data/repository/chat_repositorio_impl.dart";
import "package:oasis/domain/repository/chat_repositorio.dart";
import "package:oasis/domain/usecase/chat_caso_uso.dart";

import "package:oasis/core/util/websocket_service.dart";

// PROVIDERS DE VACANTES EMPRESA

import 'package:oasis/data/remote/vacante_empresa_api.dart';
import 'package:oasis/data/repository/vacante_empresa_repositorio_impl.dart';
import 'package:oasis/domain/repository/vacante_empresa_repository.dart';
import 'package:oasis/domain/usecase/vacante_empresa_caso_uso.dart';

final dioProvider = Provider<Dio>((ref) {
  final options = BaseOptions(
    // 🔴 PRODUCCIÓN: Backend del profesor
    baseUrl: "https://propocol.backcoreunimag.com/",

    // 🟢 DESARROLLO: Backend local proColombia (comentado)
    // baseUrl: "http://localhost:3210/",
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {"Content-Type": "application/json", "Accept": "application/json"},
    validateStatus: (status) => true,
  );

  final dio = Dio(options);

  // Logs
  // dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

  // Interceptor para Authorization (excluyendo endpoints de autenticación)
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        // No agregar token a endpoints de autenticación
        final excludedPaths = ['auth/login', 'auth/register', 'auth/pin'];
        final isAuthEndpoint = excludedPaths.any(
          (path) => options.path.contains(path),
        );

        // DEBUG: indicar si la petición requiere autorización y si existe un token
        try {
          final session = ref.read(sessionProvider);
          final tokenPresent = session.token != null && session.token!.isNotEmpty;
          print('🔐 [HTTP] ${isAuthEndpoint ? 'auth-excluded' : 'auth-required'} ${options.path} - tokenPresent=$tokenPresent');

          if (!isAuthEndpoint) {
            // Agregar token de sesión a peticiones autenticadas
            final token = session.token;
            if (token != null && token.isNotEmpty) {
              options.headers["Authorization"] = "Bearer $token";
            }
          }
        } catch (e) {
          print('⚠️ [HTTP] Error al leer session para headers: $e');
        }
        return handler.next(options);
      },
    ),
  );

  return dio;
});

// *****************************************************************************

final authApiProvider = Provider<AccesoApi>((ref) {
  final dio = ref.watch(dioProvider);
  return AccesoApi(dio);
});

final sessionProvider = StateNotifierProvider<SesionNotifier, AccesoSesion>(
  (ref) => SesionNotifier(),
);

final authRepositoryProvider = Provider<AccesoRepositorio>((ref) {
  final api = ref.watch(authApiProvider);
  return AccesoRepositorioImpl(api);
});

final loginUseCaseProvider = Provider<AccesoCasoUso>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AccesoCasoUso(repo);
});

// *****************************************************************************

/// Provider de PinApi
final pinApiProvider = Provider<PinApi>((ref) {
  final dio = ref.watch(dioProvider);
  return PinApi(dio);
});

/// Provider de PinRepositorio
final pinRepositoryProvider = Provider<PinRepositorio>((ref) {
  final api = ref.watch(pinApiProvider);
  return PinRepositorioImpl(api);
});

/// Provider de SolicitarPinUseCase
final solicitarPinUseCaseProvider = Provider<PinCasoUso>((ref) {
  final repo = ref.watch(pinRepositoryProvider);
  return PinCasoUso(repo);
});

// *****************************************************************************

final registroApiProvider = Provider<RegistroApi>((ref) {
  final dio = ref.watch(dioProvider);
  return RegistroApi(dio);
});

final registroRepositoryProvider = Provider<RegistroRepositorio>((ref) {
  final api = ref.watch(registroApiProvider);
  return RegistroRepositorioImpl(api);
});

final registroUseCaseProvider = Provider<RegistroCasoUso>((ref) {
  final repo = ref.watch(registroRepositoryProvider);
  return RegistroCasoUso(repo);
});

// *****************************************************************************
/// Provider de VacanteApi
final vacanteApiProvider = Provider<VacanteApi>((ref) {
  final dio = ref.watch(dioProvider);
  return VacanteApi(dio);
});

/// Provider de VacanteRepositorio
final vacanteRepositoryProvider = Provider<VacanteRepositorio>((ref) {
  final api = ref.watch(vacanteApiProvider);
  return VacanteRepositorioImpl(api);
});

/// Provider de VacanteCasoUso
final vacanteUseCaseProvider = Provider<VacanteCasoUso>((ref) {
  final repo = ref.watch(vacanteRepositoryProvider);
  return VacanteCasoUso(repo);
});

// *****************************************************************************
/// PROVIDERS DE CHAT

/// StateProvider para almacenar la URL del backend de chat
/// Se actualiza desde ChatTestScreen cuando el usuario configura la URL
final chatBackendUrlProvider = StateProvider<String>((ref) {
  // Valor por defecto (PRODUCCIÓN)
  return "https://propocol.backcoreunimag.com";

  // DESARROLLO (comentado)
  // return "http://localhost:3210";
});

/// Provider de Dio para Chat CON autenticación
/// Usa la URL configurada en chatBackendUrlProvider
/// Incluye el token JWT en todas las peticiones
final dioChatProvider = Provider<Dio>((ref) {
  // Obtener la URL del backend del StateProvider
  final baseUrl = ref.watch(chatBackendUrlProvider);

  // Asegurar que la URL termine con /
  final urlNormalizada = baseUrl.endsWith("/") ? baseUrl : "$baseUrl/";

  final options = BaseOptions(
    baseUrl: urlNormalizada,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {"Content-Type": "application/json", "Accept": "application/json"},
    validateStatus: (status) => true,
  );

  final dio = Dio(options);

  // Interceptor para agregar token de autenticación
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        // DEBUG: mostrar si se está adjuntando token (sin imprimir el token)
        try {
          final session = ref.read(sessionProvider);
          final tokenPresent = session.token != null && session.token!.isNotEmpty;
          print('🔐 [CHAT HTTP] ${options.path} - tokenPresent=$tokenPresent');
          if (tokenPresent) {
            options.headers["Authorization"] = "Bearer ${session.token}";
          }
        } catch (e) {
          print('⚠️ [CHAT HTTP] Error al leer session para headers: $e');
        }
        return handler.next(options);
      },
    ),
  );

  // LOGS para debugging (comentado en producción)
  // dio.interceptors.add(LogInterceptor(
  //   requestBody: true,
  //   responseBody: true,
  //   error: true,
  //   requestHeader: true,
  //   responseHeader: false,
  // ));

  return dio;
});

/// Provider de ChatApi (usa dioChatProvider)
final chatApiProvider = Provider<ChatApi>((ref) {
  final dio = ref.watch(dioChatProvider);
  return ChatApi(dio);
});

/// Provider de ChatRepositorio
final chatRepositoryProvider = Provider<ChatRepositorio>((ref) {
  final api = ref.watch(chatApiProvider);
  return ChatRepositorioImpl(api);
});

/// Provider de ChatCasoUso
final chatUseCaseProvider = Provider<ChatCasoUso>((ref) {
  final repo = ref.watch(chatRepositoryProvider);
  return ChatCasoUso(repo);
});

/// Provider de WebSocketService
/// Se crea con el token de autenticación de la sesión actual
/// Usa la URL configurada en chatBackendUrlProvider
// final webSocketServiceProvider = Provider<WebSocketService>((ref) {
//   final httpUrl = ref.watch(chatBackendUrlProvider);
//   final wsUrl = httpUrl.replaceFirst("http", "ws");
//   final session = ref.watch(sessionProvider);
//
//   return WebSocketService(
//     baseUrl: wsUrl,
//     token: session.token,
//   );
// });

final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final httpUrl = ref.watch(chatBackendUrlProvider);
  final wsUrl = httpUrl.startsWith("https")
      ? httpUrl.replaceFirst("https", "wss")
      : httpUrl.replaceFirst("http", "ws");

  final fullWsUrl = "$wsUrl/ws-chat";
  final session = ref.watch(sessionProvider);

  return WebSocketService(baseUrl: fullWsUrl, token: session.token);
});
/// Provider de VacanteEmpresaApi
final vacanteEmpresaApiProvider = Provider<VacanteEmpresaApi>((ref) {
  final dio = ref.watch(dioProvider);
  return VacanteEmpresaApi(dio);
});

/// Provider de VacanteEmpresaRepositorio
final vacanteEmpresaRepositoryProvider = Provider<VacanteEmpresaRepositorio>((ref) {
  final api = ref.watch(vacanteEmpresaApiProvider);
  return VacanteEmpresaRepositorioImpl(api);
});

/// Provider de ObtenerVacantesEmpresaCasoUso
final obtenerVacantesEmpresaUseCaseProvider = Provider<ObtenerVacantesEmpresaCasoUso>((ref) {
  final repo = ref.watch(vacanteEmpresaRepositoryProvider);
  return ObtenerVacantesEmpresaCasoUso(repo);
});

/// Provider de CrearVacanteCasoUso
final crearVacanteUseCaseProvider = Provider<CrearVacanteCasoUso>((ref) {
  final repo = ref.watch(vacanteEmpresaRepositoryProvider);
  return CrearVacanteCasoUso(repo);
});