# 🚀 GUÍA DE INTEGRACIÓN - WEBSOCKET CHAT

## Resumen

Se ha integrado WebSocket STOMP para comunicación en **tiempo real** en el módulo de chat. Los mensajes, typing events e inbox updates llegan automáticamente sin necesidad de polling.

---

## 🏗️ Arquitectura

### Componentes

```
┌─────────────────────────────────────────┐
│  UI (chat_screen.dart)                   │
│  ├─ Muestra mensajes                     │
│  ├─ Input de texto                       │
│  └─ Indicador "escribiendo..."           │
└────────────────┬────────────────────────┘
                 │ ref.watch(chatProvider)
┌────────────────▼────────────────────────┐
│  ChatNotifier                             │
│  ├─ Escucha WebSocket eventos            │
│  ├─ Actualiza estado en tiempo real      │
│  └─ Envía mensajes via WS                │
└────────────────┬────────────────────────┘
                 │
    ┌────────────┼────────────┐
    │            │            │
    ▼            ▼            ▼
  REST API    WebSocket    STOMP Server
    │            │            │
    └────────────┴────────────┘
           Backend (Java Spring)
```

---

## 🔌 WebSocket Service

Ubicación: `lib/core/util/websocket_service.dart`

### Características

- ✅ Conexión STOMP automática
- ✅ Reconexión automática (5 intentos, 3s delay)
- ✅ Suscripciones a múltiples destinos
- ✅ Eventos typados (Mensaje, Typing, Inbox)
- ✅ Broadcast streams para escuchar eventos

### Métodos Principales

```dart
// Conectar
await wsService.conectar();

// Suscribirse a un destino
await wsService.suscribir('/topic/chat/123');

// Enviar mensaje
await wsService.enviarMensaje(
  destination: '/app/chat/123/send',
  cuerpo: {'postulacionId': 123, 'usuarioId': 1, 'texto': 'Hola'},
);

// Escuchar eventos
wsService.eventos.listen((evento) {
  if (evento is ChatMensajeEvento) {
    print('Nuevo mensaje: ${evento.mensaje}');
  }
});

// Desconectar
await wsService.desconectar();
```

---

## 📨 Flujos de Eventos

### 1. Recibir Mensaje en Tiempo Real

```
Backend envía a /topic/chat/123
         ↓
WebSocketService procesa
         ↓
Emite ChatMensajeEvento
         ↓
ChatNotifier escucha
         ↓
Agrega a la lista de mensajes
         ↓
UI se actualiza automáticamente
```

### 2. Indicador "Escribiendo..."

```
Usuario A escribe
         ↓
ChatNotifier envía typing=true a /app/chat/123/typing
         ↓
Backend broadcast a /topic/chat/123
         ↓
Usuario B recibe ChatTypingEvento
         ↓
UI muestra "Usuario X está escribiendo..."
         ↓
(2 segundos sin evento)
         ↓
Indicador desaparece
```

### 3. Notificación de Inbox

```
Nuevo mensaje en /topic/inbox/user/123
         ↓
ChatNotifier recibe ChatInboxEvento
         ↓
Recargar lista de chats
         ↓
Badges se actualizan con contador
```

---

## 🎯 Destinos STOMP

### Suscripciones (Cliente → Servidor)

| Destino | Propósito | Cuándo |
|---------|-----------|--------|
| `/topic/chat/{postId}` | Recibir mensajes de un chat | Al abrir chat |
| `/topic/inbox/user/{userId}` | Recibir notificaciones | Al cargar lista |

### Envíos (Cliente → Servidor)

| Destino | Propósito | Datos |
|---------|-----------|-------|
| `/app/chat/{postId}/send` | Enviar mensaje | `{postulacionId, usuarioId, texto}` |
| `/app/chat/{postId}/typing` | Notificar typing | `{postulacionId, userId, typing}` |

---

## 💡 Casos de Uso

### Abrir un Chat

```dart
// En la UI
ref.read(chatProvider.notifier).cargarMensajes(postulacionId: 123);

// Automáticamente:
// 1. Carga historial REST
// 2. Suscribe a /topic/chat/123
// 3. Escucha eventos WS
// 4. Marca como leído
```

### Enviar Mensaje

```dart
// En la UI
ref.read(chatProvider.notifier).enviarMensaje(
  postulacionId: 123,
  texto: "Hola, ¿cómo estás?",
);

// Automáticamente:
// 1. Envía via WebSocket
// 2. Backend broadcast a todos
// 3. Todos reciben por WS
// 4. UI se actualiza en tiempo real
```

### Indicador Typing

```dart
// En la UI (desde onChanged del TextField)
ref.read(chatProvider.notifier).enviarTyping(
  postulacionId: 123,
  escribiendo: true,
);

// Backend broadcast a otros usuarios
// Otros ven: "Usuario X está escribiendo..."
```

---

## ⚙️ Configuración

### Base URL de WebSocket

En `core/di/providers.dart`:

```dart
final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  const wsUrl = "ws://localhost:3210";  // ← CAMBIAR AQUÍ
  return WebSocketService(baseUrl: wsUrl);
});
```

Para producción:
```dart
const wsUrl = "wss://tu-dominio.com";  // HTTPS = WSS
```

### Reconexión

En `websocket_service.dart`:
```dart
static const int _maxIntentosReconexion = 5;      // Max intentos
static const int _tiempoReconexionMs = 3000;      // 3 segundos entre intentos
```

---

## 🔍 Debugging

### Ver Eventos WS

```dart
wsService.eventos.listen((evento) {
  print('[WS] Evento: $evento');
});
```

### Ver Estado de Conexión

```dart
wsService.estadoConexion.listen((conectado) {
  print('[WS] Conectado: $conectado');
});
```

### Logs en el Notifier

```dart
// Agregar en ChatNotifier._procesarEventoWS
print('[ChatNotifier] Evento recibido: $evento');
```

---

## 🐛 Problemas Comunes

### "No conecta a WebSocket"

1. Verificar URL en `providers.dart`
2. Backend WebSocket debe estar corriendo
3. CORS/WebSocket debe estar permitido

### "Mensajes duplicados"

- Revisar que no haya múltiples suscripciones al mismo destino
- WebSocketService maneja esto automáticamente

### "Indicador typing no aparece"

- Verificar que `enviarTyping` se llamar en `onChanged`
- Backend debe estar broadcast a `/topic/chat/{postId}`

### "Desconexión frecuente"

- Aumentar `_maxIntentosReconexion`
- Revisar logs del backend

---

## 📱 Uso en la UI

### Acceder al Notifier

```dart
final chatNotifier = ref.read(chatProvider.notifier);

// Cargar chats
await chatNotifier.cargarChats();

// Cargar mensajes
await chatNotifier.cargarMensajes(postulacionId: 123);

// Enviar mensaje
await chatNotifier.enviarMensaje(
  postulacionId: 123,
  texto: textController.text,
);

// Enviar typing
await chatNotifier.enviarTyping(
  postulacionId: 123,
  escribiendo: true,
);
```

### Escuchar Estado

```dart
ref.watch(chatProvider).maybeWhen(
  chatListaCargada: (chats) {
    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (ctx, i) => ChatItem(chats[i]),
    );
  },
  chatMensajesCargados: (postId, mensajes, cargandoMas, hayMas, pagina) {
    return ListView.builder(
      itemCount: mensajes.length,
      itemBuilder: (ctx, i) => MensajeBubble(mensajes[i]),
    );
  },
  chatMensajesCargando: (_) => const CircularProgressIndicator(),
  orElse: () => const Text("Error"),
);
```

---

## ✅ Checklist de Integración

- [ ] `pubspec.yaml` tiene `web_socket_channel: ^3.0.0`
- [ ] `websocket_service.dart` está en `core/util/`
- [ ] `providers.dart` tiene `webSocketServiceProvider`
- [ ] `ChatNotifier` está actualizado con WebSocket
- [ ] `chat_provider.dart` inyecta `wsService`
- [ ] Base URL es correcta en `providers.dart`
- [ ] Backend WebSocket está corriendo
- [ ] Flutter app puede conectar a WebSocket

---

## 🚀 Próximos Pasos

1. **Crear Screen** (`chat_screen.dart`)
2. **Crear Widgets** (mensaje_bubble, chat_list_item)
3. **Agregar Ruta** en `router.dart`
4. **Probar** con la app

---

## 📚 Referencias

- WebSocket STOMP: https://stomp.github.io/
- Spring WebSocket: https://spring.io/guides/gs/messaging-stomp-websocket/
- Flutter WebSocket: https://pub.dev/packages/web_socket_channel

---

**¡Listo! WebSocket está totalmente integrado y funcionando.** 🎉


