import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Evento que puede ser un mensaje o typing
abstract class ChatEventoWS {
  const ChatEventoWS();
}

/// Evento de nuevo mensaje
class ChatMensajeEvento extends ChatEventoWS {
  final Map<String, dynamic> mensaje;
  
  const ChatMensajeEvento(this.mensaje);
}

/// Evento de usuario escribiendo
class ChatTypingEvento extends ChatEventoWS {
  final Map<String, dynamic> typing;
  
  const ChatTypingEvento(this.typing);
}

/// Evento de inbox (nuevo mensaje en bandeja)
class ChatInboxEvento extends ChatEventoWS {
  final Map<String, dynamic> inbox;
  
  const ChatInboxEvento(this.inbox);
}

/// Servicio WebSocket para comunicación en tiempo real
/// Maneja conexión STOMP, suscripciones y eventos
class WebSocketService {
  final String baseUrl;
  final String? token;
  late WebSocketChannel _channel;
  bool _conectado = false;
  bool _conectando = false;
  int _intentosReconexion = 0;
  static const int _maxIntentosReconexion = 5;
  static const int _tiempoReconexionMs = 3000;

  /// Streams para escuchar eventos
  final _eventosController = StreamController<ChatEventoWS>.broadcast();
  final _estadoController = StreamController<bool>.broadcast();

  /// Mapa de suscripciones activas
  final Map<String, int> _suscripciones = {};

  /// Contador de IDs para suscripciones
  int _sumaIdSuscripcion = 0;

  /// ID de cliente para STOMP
  final String _clientId = "flutter_${DateTime.now().millisecondsSinceEpoch}";

  /// Constructor
  WebSocketService({
    required this.baseUrl,
    this.token,
  });

  /// Stream de eventos
  Stream<ChatEventoWS> get eventos => _eventosController.stream;

  /// Stream de estado (conectado/desconectado)
  Stream<bool> get estadoConexion => _estadoController.stream;

  /// ¿Está conectado?
  bool get estaConectado => _conectado;

  /// Conecta al servidor WebSocket
  Future<void> conectar() async {
    if (_conectado || _conectando) {
      // print('🔌 [WS] Ya está conectado o conectando...');
      return;
    }

    _conectando = true;
    try {
      final wsUrl = baseUrl.replaceFirst('http', 'ws');
      final fullUrl = '$wsUrl/ws-chat';
      // print('🔌 [WS] Intentando conectar a: $fullUrl');
      // print('💡 [WS] Token se enviará en frame STOMP CONNECT (compatible con Web)');
      
      // Conectar usando WebSocketChannel (compatible con Web y Mobile)
      _channel = WebSocketChannel.connect(Uri.parse(fullUrl));

      await _channel.ready.timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception("Timeout en conexión WS"),
      );

      _conectado = true;
      _conectando = false;
      _intentosReconexion = 0;
      _estadoController.add(true);
      // print('✅ [WS] Conectado exitosamente a $fullUrl');

      _escucharMensajes();

      // Enviar STOMP CONNECT con token de autenticación
      // print('📤 [WS] Enviando STOMP CONNECT...');
      final stompHeaders = {
        'accept-version': '1.0,1.1,1.2',
        'heart-beat': '0,0',
        'client-id': _clientId,
      };
      
      // Agregar token si está disponible
      if (token != null && token!.isNotEmpty) {
        stompHeaders['Authorization'] = 'Bearer $token';
        // print('🔑 [WS] Token incluido en conexión STOMP');
      }
      
      _enviarFrame('CONNECT', stompHeaders);
    } catch (e) {
      // print('❌ [WS] Error al conectar: $e');
      _conectado = false;
      _conectando = false;
      _estadoController.add(false);

      // Reintentar conexión
      if (_intentosReconexion < _maxIntentosReconexion) {
        _intentosReconexion++;
        Future.delayed(
          Duration(milliseconds: _tiempoReconexionMs * _intentosReconexion),
          () => conectar(),
        );
      }
    }
  }

  /// Escucha mensajes del WebSocket
  void _escucharMensajes() {
    _channel.stream.listen(
      (mensaje) {
        _procesarMensajeWS(mensaje);
      },
      onError: (error) {
        desconectar();
      },
      onDone: () {
        desconectar();
      },
    );
  }

  /// Procesa mensajes STOMP del servidor
  void _procesarMensajeWS(dynamic mensaje) {
    try {
      final lineas = (mensaje as String).split('\n');
      if (lineas.isEmpty) return;

      final comando = lineas[0];
      // print('📨 [WS] Comando recibido: $comando');

      if (comando == 'CONNECTED') {
        // Conexión exitosa STOMP
        // print('✅ [WS] STOMP CONNECTED exitosamente');
        return;
      }

      if (comando == 'MESSAGE') {
        // Extraer encabezados y cuerpo
        int destinationIdx = -1;
        int idIdx = -1;

        for (int i = 1; i < lineas.length; i++) {
          if (lineas[i].startsWith('destination:')) {
            destinationIdx = i;
          } else if (lineas[i].startsWith('message-id:')) {
            idIdx = i;
          } else if (lineas[i].isEmpty) {
            // Inicio del cuerpo
            final cuerpo = lineas.skip(i + 1).join('\n').replaceAll('\u0000', '');

            if (destinationIdx != -1) {
              final destination = lineas[destinationIdx].split(':')[1].trim();
              _procesarEvento(destination, cuerpo);
            }
            break;
          }
        }
        return;
      }

      if (comando == 'ERROR') {
        desconectar();
      }
    } catch (e) {
      // Silenciar errores de parseo
    }
  }

  /// Procesa eventos según su destination
  void _procesarEvento(String destination, String cuerpo) {
    try {
      // print('📨 [WS] Evento recibido - destination: $destination');
      // print('📨 [WS] Cuerpo: $cuerpo');
      
      final json = jsonDecode(cuerpo) as Map<String, dynamic>;

      if (destination.startsWith('/topic/chat/')) {
        // Evento de mensaje o typing
        final kind = json['kind'] as String?;
        // print('📨 [WS] Kind: $kind');

        if (kind == 'MESSAGE') {
          // print('💬 [WS] Nuevo mensaje recibido');
          _eventosController.add(ChatMensajeEvento(json['message'] ?? json));
        } else if (kind == 'TYPING') {
          // print('⌨️ [WS] Typing recibido');
          _eventosController.add(ChatTypingEvento(json['typing'] ?? json));
        }
      } else if (destination.startsWith('/topic/inbox/')) {
        // Evento de inbox
        // print('📥 [WS] Inbox recibido');
        _eventosController.add(ChatInboxEvento(json));
      }
    } catch (e) {
      // print('❌ [WS] Error procesando evento: $e');
      // Silenciar errores
    }
  }

  /// Suscribe a un destino STOMP
  Future<void> suscribir(String destination) async {
    if (!_conectado) {
      // print('⚠️ [WS] No conectado, no se puede suscribir a $destination');
      return;
    }

    if (_suscripciones.containsKey(destination)) {
      // print('⚠️ [WS] Ya suscrito a $destination');
      return;
    }

    _sumaIdSuscripcion++;
    final id = _sumaIdSuscripcion;
    _suscripciones[destination] = id;

    // print('📢 [WS] Suscribiendo a: $destination (id: $id)');
    _enviarFrame('SUBSCRIBE', {
      'destination': destination,
      'id': id.toString(),
      'ack': 'auto',
    });
  }

  /// Desuscribe de un destino
  Future<void> desuscribir(String destination) async {
    final id = _suscripciones.remove(destination);
    if (id != null) {
      // print('📢 [WS] Desuscribiendo de: $destination (id: $id)');
      _enviarFrame('UNSUBSCRIBE', {
        'id': id.toString(),
      });
      // print('✅ [WS] Desuscrito de: $destination');
    } else {
      // print('⚠️ [WS] No se encontró suscripción para: $destination');
    }
  }

  /// Envía un mensaje a través de STOMP
  Future<void> enviarMensaje({
    required String destination,
    required Map<String, dynamic> cuerpo,
  }) async {
    if (!_conectado) {
      // print('⚠️ [WS] No conectado, no se puede enviar mensaje a $destination');
      return;
    }

    // print('📤 [WS] Enviando mensaje a: $destination');
    // print('📤 [WS] Cuerpo: $cuerpo');
    _enviarFrame('SEND', {
      'destination': destination,
      'content-type': 'application/json',
    }, jsonEncode(cuerpo));
    // print('✅ [WS] Mensaje enviado');
  }

  /// Envía un frame STOMP
  void _enviarFrame(
    String comando,
    Map<String, String> headers, [
    String? cuerpo,
  ]) {
    if (!_conectado && comando != 'CONNECT') {
      // print('⚠️ [WS] No conectado, no se puede enviar frame $comando');
      return;
    }

    try {
      final headerStr = headers.entries.map((e) => '${e.key}:${e.value}').join('\n');
      final frame = '$comando\n$headerStr\n\n${cuerpo ?? ''}\u0000';
      // print('📤 [WS] Enviando frame: $comando');
      _channel.sink.add(frame);
    } catch (e) {
      // print('❌ [WS] Error enviando frame $comando: $e');
    }
  }

  /// Desconecta del servidor
  Future<void> desconectar() async {
    if (!_conectado) return;

    _conectado = false;
    _suscripciones.clear();

    try {
      _enviarFrame('DISCONNECT', {'receipt': 'disconnect-receipt'});
      await _channel.sink.close();
    } catch (_) {}

    _estadoController.add(false);
  }

  /// Limpia recursos
  void dispose() {
    desconectar();
    _eventosController.close();
    _estadoController.close();
  }
}

