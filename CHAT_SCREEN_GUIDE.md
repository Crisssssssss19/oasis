# 🎨 GUÍA - PANTALLAS DE CHAT

## Resumen

Se han creado dos pantallas principales para el módulo de chat:

1. **ChatTestScreen** - Pantalla de prueba para ingresar parámetros
2. **ChatScreen** - Pantalla principal de chat con dos pestañas

---

## 📱 ChatTestScreen

**Ubicación:** `lib/presentation/aspirante/chat/chat_test_screen.dart`

### Propósito
Pantalla inicial que permite al usuario ingresar parámetros para filtrar chats durante el testing.

### Parámetros

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| **User ID** | Int | ✅ Sí | ID del usuario logueado |
| **Empresa ID** | Int | ❌ No | Filtro por empresa (solo reclutadores) |
| **Vacante ID** | Int | ❌ No | Filtro por vacante específica |

### Flujo

```
ChatTestScreen
    ↓
Usuario ingresa parámetros
    ↓
Presiona "Cargar Chats"
    ↓
ChatNotifier.setUsuarioId()
ChatNotifier.cargarChats(empresaId, vacanteId)
    ↓
Navega a ChatScreen
```

### Cómo Usar en Desarrollo

```dart
// En router.dart o donde quieras
GoRoute(
  path: '/chat-test',
  name: 'chat_test',
  pageBuilder: (context, state) => NoTransitionPage(
    key: state.pageKey,
    child: const ChatTestScreen(),
  ),
),

// O navegar directo
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const ChatTestScreen()),
);
```

### Interfaz

```
┌─────────────────────────────────┐
│  🧪 Prueba de Chat              │ ← AppBar
├─────────────────────────────────┤
│                                 │
│  Parámetros de Prueba           │ ← Título
│  Ingresa los parámetros...      │ ← Descripción
│                                 │
│  ┌─────────────────────────┐    │
│  │ User ID: [101]          │    │ ← Campo requerido
│  └─────────────────────────┘    │
│  ┌─────────────────────────┐    │
│  │ Empresa ID: []          │    │ ← Opcional
│  └─────────────────────────┘    │
│  ┌─────────────────────────┐    │
│  │ Vacante ID: []          │    │ ← Opcional
│  └─────────────────────────┘    │
│                                 │
│  ╭─ 💡 Notas: ─────────────╮   │
│  │ • User ID es requerido  │   │
│  │ • Los otros son opcionales│   │
│  ╰─────────────────────────╯   │
│                                 │
│  [  Cargar Chats  ]             │ ← Botón principal
│  [Usar valores por defecto]     │ ← Botón secundario
│                                 │
└─────────────────────────────────┘
```

---

## 💬 ChatScreen

**Ubicación:** `lib/presentation/aspirante/chat/chat_screen.dart`

### Propósito
Pantalla principal con dos vistas:
1. **Pestaña Chats** - Lista de conversaciones
2. **Pestaña Conversación** - Vista de mensajes

### Pestaña 1: Lista de Chats

Muestra todos los chats del usuario con:
- Título de la vacante
- Último mensaje (preview)
- Fecha del último mensaje
- Badge con contador de no leídos

#### Características

✅ **Pull to refresh** - Desliza hacia abajo para actualizar
✅ **Selección** - Toca un chat para verlo
✅ **Badges** - Muestra número de mensajes sin leer
✅ **Estado de carga** - Spinner mientras carga

#### Interfaz

```
Chats | Conversación   ← Pestañas
  
┌─────────────────────────────────┐
│ Vacante 1                       │ 5  ← Badge (no leídos)
│ Último mensaje que fue...       │
├─────────────────────────────────┤
│ Vacante 2                    01/15 │ ← Fecha
│ Otro mensaje importante...      │
├─────────────────────────────────┤
│ Vacante 3                       │
│ Más mensajes...                 │
└─────────────────────────────────┘
```

### Pestaña 2: Conversación

Muestra los mensajes del chat seleccionado con:
- Burbujas de chat (derecha/izquierda)
- Hora de cada mensaje
- Campo de entrada para escribir
- Botón de envío

#### Características

✅ **Burbujas de chat** - Diseño moderno
✅ **Typing indicator** - Se envía automáticamente
✅ **Auto-marca como leído** - Al abrir el chat
✅ **Envío por WebSocket** - Tiempo real
✅ **Fallback a REST** - Si WS falla

#### Interfaz

```
Chats | Conversación   ← Pestañas
  
┌─────────────────────────────────┐
│                                 │
│               Hola! ¿Qué tal?   │ ← Mensaje enviado (azul)
│          Bien, ¿y tú? 14:32    │    (derecha)
│                                 │
│  Mucho trabajo aquí 14:33      │ ← Mensaje recibido (gris)
│                                 │    (izquierda)
│              Entiendo 14:35     │
│                                 │
├─────────────────────────────────┤
│ ┌───────────────────────────┐   │
│ │ Escribe un mensaje...  ↗️ │   │ ← Input + botón envío
│ └───────────────────────────┘   │
└─────────────────────────────────┘
```

---

## 🔄 Flujo Completo

```
ChatTestScreen
    ↓
1. Usuario ingresa userId=101
2. Presiona "Cargar Chats"
    ↓
ChatNotifier.setUsuarioId(101)
    ↓
ChatNotifier.cargarChats()
    ↓ (por REST)
Backend devuelve lista de chats
    ↓
State: ChatListaCargada
    ↓
ChatScreen muestra lista
    ↓
Usuario tapa un chat
    ↓
ChatNotifier.cargarMensajes(postulacionId)
    ↓ (por REST)
Carga historial de mensajes
    ↓
State: ChatMensajesCargados
    ↓
Se suscribe a /topic/chat/123 (WebSocket)
    ↓
ChatScreen muestra conversación
    ↓
Usuario escribe "Hola"
    ↓
onChanged → ChatNotifier.enviarTyping(true)
    ↓ (por WebSocket)
Backend broadcast a otros usuarios
    ↓
Usuario presiona envío
    ↓
ChatNotifier.enviarMensaje()
    ↓ (por WebSocket)
Backend recibe y guarda
    ↓
Backend broadcast a subscribers
    ↓
Otros usuarios reciben por WebSocket
    ↓
ChatNotifier recibe ChatMensajeEvento
    ↓
Agrega mensaje a la lista
    ↓
UI se redibuja automáticamente
```

---

## 🛠️ Cómo Integrar en la App

### 1. Agregar a router.dart

```dart
// En lib/presentation/router.dart

GoRoute(
  path: '/chat-test',
  name: 'chat_test',
  pageBuilder: (context, state) => NoTransitionPage(
    key: state.pageKey,
    child: const ChatTestScreen(),
  ),
),

// Opcional: ruta directa al chat si ya tienes usuario
GoRoute(
  path: '/chat',
  name: 'chat',
  pageBuilder: (context, state) => NoTransitionPage(
    key: state.pageKey,
    child: const ChatScreen(),
  ),
),
```

### 2. Navegar desde otra pantalla

```dart
// Opción 1: Con GoRouter
context.push('/chat-test');

// Opción 2: Con Navigator
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const ChatTestScreen()),
);

// Opción 3: En un botón
ElevatedButton(
  onPressed: () => context.push('/chat-test'),
  child: const Text("Ir a Chat"),
)
```

### 3. Usar en BottomBar (si quieres agregar a la navegación)

```dart
// En app_bottom_bar.dart o donde manejes la navegación

// Agregar ícono de chat
navigationDestinations: [
  // ... otros destinos
  NavigationDestination(
    icon: Icon(Icons.chat),
    label: 'Chat',
  ),
],

// Manejar navegación
currentPageIndex == chatIndex 
  ? const ChatTestScreen()
  : /* otro widget */
```

---

## 🧪 Valores de Prueba

### Usuario sin filtros

```
User ID: 101
Empresa ID: (vacío)
Vacante ID: (vacío)
```

**Resultado:** Todos los chats del usuario 101

### Usuario por vacante

```
User ID: 101
Empresa ID: (vacío)
Vacante ID: 1
```

**Resultado:** Chats del usuario 101 en la vacante 1

### Empresa (reclutador)

```
User ID: 1
Empresa ID: 5
Vacante ID: (vacío)
```

**Resultado:** Todos los chats de la empresa 5

---

## 🐛 Troubleshooting

### "No carga los chats"

1. ✅ Verificar que el backend esté corriendo
2. ✅ Verificar base URL en `providers.dart`
3. ✅ Revisar token si es necesario
4. ✅ Ver logs de la consola

### "Los mensajes no se envían"

1. ✅ Verificar conexión WebSocket en logs
2. ✅ Revisar que el backend permita WebSocket
3. ✅ Comprobar URL de WebSocket (ws:// no http://)

### "Las pantallas no se actualizan"

1. ✅ Asegurarse que estés usando `ref.watch(chatProvider)`
2. ✅ No usar `ref.read()` en widgets (solo en listeners)
3. ✅ Revisar que el estado cambia correctamente

---

## 📊 Estados Posibles

| Estado | Pantalla | Qué Pasa |
|--------|----------|----------|
| `ChatListaCargando` | Lista | Muestra spinner |
| `ChatListaCargada` | Lista | Muestra chats |
| `ChatListaError` | Lista | Error con botón reintentar |
| `ChatMensajesCargando` | Conv. | Muestra spinner |
| `ChatMensajesCargados` | Conv. | Muestra mensajes |
| `ChatMensajesError` | Conv. | Error con botón reintentar |
| `ChatEnviandoMensaje` | Conv. | Estado intermedio (rápido) |
| `ChatUsuarioEscribiendo` | Conv. | "Usuario X está escribiendo..." |

---

## ✅ Checklist de Testing

- [ ] ChatTestScreen abre correctamente
- [ ] Puedo ingresar userId, empresaId, vacanteId
- [ ] Botón "Cargar Chats" funciona
- [ ] Se navega a ChatScreen
- [ ] Lista de chats se carga
- [ ] Puedo seleccionar un chat
- [ ] Se navega a conversación
- [ ] Se cargan los mensajes
- [ ] Puedo escribir un mensaje
- [ ] Se envía el mensaje
- [ ] El mensaje aparece en la lista
- [ ] Otros usuarios lo reciben en tiempo real (WebSocket)
- [ ] Pull to refresh funciona
- [ ] Los badges de no leídos se actualizan

---

## 🚀 Próximos Pasos

1. ✅ Pantalla de Test → **HECHO**
2. ✅ Pantalla de Chat → **HECHO**
3. ⏳ Agregar a router
4. ⏳ Crear widgets auxiliares (opcional, por ahora está inline)
5. ⏳ Testing end-to-end con backend
6. ⏳ Mejorar UI/UX
7. ⏳ Agregar indicador de escritura visual

---

**¡Listo para probar!** 🎉


