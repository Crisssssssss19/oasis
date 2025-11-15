# 🧭 GUÍA - NAVEGACIÓN A CHAT

## Rutas Agregadas a `router.dart`

Se han agregado dos rutas para acceder al módulo de chat:

```dart
// Pantalla de prueba (ingresa parámetros)
/chat-test

// Pantalla principal (ver y escribir mensajes)
/chat
```

---

## 📍 Cómo Navegar

### Opción 1: Usando GoRouter (Recomendado)

```dart
// Navegar a pantalla de prueba
context.push('/chat-test');

// Navegar directamente a chat (si ya tienes userId configurado)
context.push('/chat');

// Con nombre (más explícito)
context.goNamed('chat_test');
context.goNamed('chat');
```

### Opción 2: Desde un Botón

```dart
ElevatedButton(
  onPressed: () => context.push('/chat-test'),
  child: const Text("💬 Ir a Chat"),
)
```

### Opción 3: Agregar Ícono a BottomBar

```dart
// En tu BottomNavigationBar

NavigationDestination(
  icon: const Icon(Icons.chat),
  label: 'Chat',
),

// En el manejador de navegación
case 4: // Índice del chat
  return const ChatTestScreen();
```

### Opción 4: Desde AppBar

```dart
AppBar(
  actions: [
    IconButton(
      icon: const Icon(Icons.chat),
      onPressed: () => context.push('/chat-test'),
    ),
  ],
)
```

---

## 🧪 Flujo de Navegación Completo

```
Cualquier pantalla
        ↓
Presiona botón "Chat" o ícono 💬
        ↓
context.push('/chat-test')
        ↓
ChatTestScreen abre
        ↓
Usuario ingresa:
  - userId: 101
  - empresaId: (vacío)
  - vacanteId: (vacío)
        ↓
Presiona "Cargar Chats"
        ↓
ChatNotifier.setUsuarioId(101)
ChatNotifier.cargarChats()
        ↓
Se navega a /chat automáticamente
        ↓
ChatScreen muestra lista de chats
```

---

## 💡 Ejemplos Prácticos

### Desde la pantalla de Inicio

```dart
// En inicio_screen.dart
FloatingActionButton(
  onPressed: () => context.push('/chat-test'),
  child: const Icon(Icons.chat),
)
```

### Con DrawerMenu

```dart
ListTile(
  leading: const Icon(Icons.chat),
  title: const Text("Chat"),
  onTap: () {
    Navigator.pop(context); // Cerrar drawer
    context.push('/chat-test');
  },
)
```

### Con BottomBar

```dart
// En app_bottom_bar.dart o donde uses BottomNavigationBar

navigationDestinations: [
  NavigationDestination(icon: Icon(Icons.home), label: 'Inicio'),
  NavigationDestination(icon: Icon(Icons.chat), label: 'Chat'),
  NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
],

// En el onDestinationSelected
onDestinationSelected: (index) {
  switch (index) {
    case 0:
      context.go('/inicio');
    case 1:
      context.push('/chat-test');
    case 2:
      context.go('/perfil');
  }
}
```

---

## 🔍 Parámetros de Ruta (Actuales)

### ChatTestScreen (`/chat-test`)
- No requiere parámetros
- El usuario ingresa los parámetros en la interfaz

### ChatScreen (`/chat`)
- No requiere parámetros URL
- Requiere que userId esté configurado via ChatTestScreen

---

## ⚙️ Si Quieres Pasar Parámetros por URL

**Versión Futura (Opcional):**

```dart
// Pasar userId por parámetro
GoRoute(
  path: '/chat/:userId',
  name: 'chat_with_user',
  pageBuilder: (context, state) {
    final userId = int.parse(state.pathParameters['userId']!);
    return NoTransitionPage(
      key: state.pageKey,
      child: ChatScreen(userId: userId),
    );
  },
),

// Usar así:
context.push('/chat/101');
```

---

## ✅ Verificación

Después de agregar las rutas, verifica que:

- [ ] El archivo `router.dart` compila sin errores
- [ ] Puedes navegar a `/chat-test` desde tu app
- [ ] ChatTestScreen abre sin errores
- [ ] Puedes ingresar parámetros
- [ ] Se navega a `/chat` automáticamente
- [ ] ChatScreen muestra los chats

---

## 🚀 Prueba Rápida

1. En cualquier pantalla de tu app, agrega este botón:

```dart
FloatingActionButton(
  onPressed: () => context.push('/chat-test'),
  child: const Icon(Icons.chat),
)
```

2. Presiona el botón
3. Ingresa `101` como User ID
4. Presiona "Cargar Chats"
5. ¡Listo! Deberías ver la lista de chats

---

## 📚 Referencias Relacionadas

- Ver `CHAT_SCREEN_GUIDE.md` para detalles de las pantallas
- Ver `CHAT_WEBSOCKET_GUIDE.md` para WebSocket
- Ver `presentation/router.dart` para todas las rutas

---

**¡Listo para usar!** 🎉


