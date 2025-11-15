# 🔧 MODO DESARROLLO - GUÍA DE CONFIGURACIÓN

## Estado Actual

**La app está configurada en MODO DESARROLLO para testear el chat sin login.**

---

## 🔄 Lo que se cambió

### 1. Router (`router.dart`)
**ANTES:** Pantalla inicial mostraba `AnimacionScreen` que redirigía a login o inicio
```dart
path: '/',
child: AnimacionScreen(...)
```

**AHORA:** Va directo a `InicioScreen`
```dart
path: '/',
child: const InicioScreen(),
```

### 2. Inicio Screen (`inicio_screen.dart`)
**ANTES:** El ícono de chat iba a `/chat`
```dart
onChatPressed: () => context.go('/chat'),
```

**AHORA:** Va a `/chat-test` (donde configuras parámetros)
```dart
onChatPressed: () => context.push('/chat-test'),
```

---

## 🚀 Cómo Usar Ahora

1. **Ejecuta la app**
   ```bash
   flutter run
   ```

2. **Irás directamente a Inicio Screen**
   - Sin pasar por login

3. **Para ir al chat:**
   - Presiona el ícono 💬 en la esquina superior derecha
   - Verás `ChatTestScreen`
   - Ingresa userId (ej: 101)
   - ¡Listo! Chatea sin restricciones

---

## 🔐 Cuando Tengas Login Funcional

Sigue estos pasos para volver al flujo normal:

### Paso 1: Restaurar AnimacionScreen
En `router.dart`, reemplaza:

```dart
// ❌ DESARROLLO
GoRoute(
  path: '/',
  name: 'animacion',
  pageBuilder: (context, state) => NoTransitionPage(
    key: state.pageKey,
    child: const InicioScreen(),
  ),
),
```

Con:

```dart
// ✅ PRODUCCIÓN
GoRoute(
  path: '/',
  name: 'animacion',
  pageBuilder: (context, state) => NoTransitionPage(
    key: state.pageKey,
    child: AnimacionScreen(
      onAnimacionTerminada: () async {
        final container = ProviderScope.containerOf(context);
        final session = container.read(sessionProvider);

        if (session.isLoggedIn && !session.isExpired) {
          context.go('/inicio');
        } else {
          context.go('/bienvenida');
        }
      },
    ),
  ),
),
```

### Paso 2: Restaurar Ruta de Chat
En `inicio_screen.dart`, reemplaza:

```dart
// ❌ DESARROLLO
onChatPressed: () => context.push('/chat-test'),
```

Con:

```dart
// ✅ PRODUCCIÓN  
onChatPressed: () => context.push('/chat-test'),
// O si quieres que vaya directo (asumiendo que ya está autenticado):
// onChatPressed: () => context.push('/chat'),
```

---

## ✅ Checklist de Desarrollo

- [x] Router va directo a Inicio
- [x] Chat accesible desde ícono
- [x] ChatTestScreen para parámetros
- [x] WebSocket funcionando
- [x] Mensajes en tiempo real

---

## ⚠️ Notas Importantes

1. **El token no se verifica** mientras estés en modo desarrollo
   - En producción, el interceptor de Dio requiere token válido

2. **SessionProvider está vacío**
   - En producción, se llenarápico tras login exitoso

3. **Las rutas de login siguen existiendo**
   - `/bienvenida`, `/acceso`, `/registro_inicio` (comentadas)
   - Puedes descomentar cuando lo necesites

---

## 🐛 Troubleshooting

### "App no inicia"
- Verifica que `InicioScreen` esté correctamente importada
- Revisa que `flutter pub get` se haya ejecutado

### "No puedo acceder al chat"
- Verifica el ícono 💬 en la esquina superior derecha
- Si no ves el ícono, check `inicio_screen.dart` tiene `onChatPressed`

### "Quiero volver a login"
- Descomentar las rutas en `router.dart`
- Restaurar `AnimacionScreen` en ruta `/`

---

## 📚 Referencias

- Documentación router: `CHAT_ROUTER_SETUP.md`
- Documentación chat: `CHAT_SCREEN_GUIDE.md`
- Documentación WebSocket: `CHAT_WEBSOCKET_GUIDE.md`

---

**¡Listo para testear sin login!** 🎉


