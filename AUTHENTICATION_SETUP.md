# 🔐 GUÍA - AUTENTICACIÓN Y TOKENS

## 🔴 Estado Actual (DESARROLLO)

**La validación de token está DESACTIVADA para permitir pruebas sin login.**

---

## 📝 Lo que se cambió en `providers.dart`

### Código Actual (Desarrollo)
```dart
// En el interceptor de Dio
if (tokenRequerido && token != null && token.isNotEmpty) {
  options.headers["Authorization"] = "Bearer $token";
}
// Token será NULL/VACÍO, pero la request SE PERMITE
```

**Resultado:** 
- ✅ Puedes hacer requests sin token
- ✅ El backend también debe permitir requests sin token (por desarrollo)
- ✅ Puedes probar el chat sin login

---

## 🟢 Cómo Reactivar en Producción

Cuando tengas login funcional y quieras pasar a producción:

### Paso 1: Asegúrate que el login funciona
```dart
// En AccesoNotifier (login exitoso debe guardar el token)
await ref.read(sessionProvider.notifier).saveSession(
  token,  // ← Token obtenido del backend
  imageBase64,
  expiresAt,
);
```

### Paso 2: Valida que SessionProvider tenga token
```dart
// El token debe estar disponible después de login
final session = ref.read(sessionProvider);
print('Token: ${session.token}'); // NO debe ser null/vacío
```

### Paso 3: Reemplaza el interceptor en `providers.dart`

**ANTES (Desarrollo):**
```dart
// 🔴 DESARROLLO
if (tokenRequerido && token != null && token.isNotEmpty) {
  options.headers["Authorization"] = "Bearer $token";
}
```

**DESPUÉS (Producción):**
```dart
// 🟢 PRODUCCIÓN
if (tokenRequerido) {
  if (token == null || token.isEmpty) {
    // Token requerido pero no disponible → ERROR
    return handler.reject(
      DioException(
        requestOptions: options,
        error: "Token no disponible. Requiere autenticación.",
        type: DioExceptionType.unknown,
      ),
    );
  }
  options.headers["Authorization"] = "Bearer $token";
}
```

---

## ⚠️ Cambios en el Backend (IMPORTANTE)

Para producción, el backend TAMBIÉN debe validar:

### ANTES (Desarrollo - Permite sin token)
```java
// En Spring Security
@Override
protected void configure(HttpSecurity http) throws Exception {
    http.authorizeRequests()
        .antMatchers("/api/chats/**").permitAll() // 🔴 SIN VALIDACIÓN
        .anyRequest().authenticated();
}
```

### DESPUÉS (Producción - Requiere token)
```java
// En Spring Security
@Override
protected void configure(HttpSecurity http) throws Exception {
    http.authorizeRequests()
        .antMatchers("/api/chats/**").authenticated() // 🟢 CON VALIDACIÓN
        .anyRequest().authenticated();
}
```

---

## 📋 Checklist Producción

- [ ] Login funciona correctamente
- [ ] Token se guarda en SessionProvider
- [ ] Token se incluye en Authorization header
- [ ] Backend valida token en /api/chats/**
- [ ] Backend rechaza requests sin token válido
- [ ] Interceptor en providers.dart reactivado
- [ ] Variables de entorno configuradas (si aplica)
- [ ] HTTPS en lugar de HTTP
- [ ] Tokens con expiración

---

## 🔍 Debugging

### Ver si el token se envía
```dart
// En providers.dart, descomenta LogInterceptor
dio.interceptors.add(
  LogInterceptor(
    requestBody: true,
    responseBody: true,
  ),
);
// Verás el header "Authorization: Bearer ..." en logs
```

### Verificar token en SessionProvider
```dart
ref.read(sessionProvider).token  // Debe ser String no-vacío
```

### Ver estado de autenticación
```dart
ref.read(sessionProvider).isLoggedIn   // true si hay token
ref.read(sessionProvider).isExpired    // true si expiró
```

---

## 💡 Variables de Entorno (Recomendado)

Para diferentes ambientes, usa variables:

```dart
// lib/core/config/environment.dart
abstract class Environment {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://localhost:3210',
  );
  
  static const bool requireAuth = String.fromEnvironment(
    'REQUIRE_AUTH',
    defaultValue: 'false',
  ) == 'true';
}

// Usar en providers.dart
if (Environment.requireAuth && (token == null || token.isEmpty)) {
  // Rechazar
}
```

---

## 📚 Archivos Relacionados

- `DEVELOPMENT_MODE.md` - Configuración de desarrollo
- `providers.dart` - Interceptor de Dio
- `sesion_notifier.dart` - Gestión de tokens
- Backend `SecurityConfig.java` - Validación de seguridad

---

## 🎯 Resumen

| Aspecto | Desarrollo | Producción |
|---------|-----------|-----------|
| **Token requerido** | ❌ No | ✅ Sí |
| **Header Authorization** | Opcional | ✅ Obligatorio |
| **Validación backend** | ❌ No | ✅ Sí |
| **Login requerido** | ❌ No | ✅ Sí |
| **Expiración** | ❌ No | ✅ Sí |

---

**Cuando estés listo para producción, activa la validación de token.** 🔐


