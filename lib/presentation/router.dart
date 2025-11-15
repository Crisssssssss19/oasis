import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oasis/core/di/providers.dart';
import 'package:oasis/domain/model/pin_peticion.dart';
import 'package:oasis/presentation/acceso/acceso_screen.dart';
import 'package:oasis/presentation/aspirante/explorar_screen.dart';
import 'package:oasis/presentation/aspirante/inicio_screen.dart';
import 'package:oasis/presentation/aspirante/match_screen.dart';
import 'package:oasis/presentation/aspirante/postulacion_screen.dart';
import 'package:oasis/presentation/aspirante/perfil/perfil_opciones_screen.dart';
import 'package:oasis/presentation/aspirante/registro/paso1/registro_paso1_screen.dart';
import 'package:oasis/presentation/aspirante/registro/paso3/registro_paso3_screen.dart';
import 'package:oasis/presentation/aspirante/registro/paso2/registro_paso2_screen.dart';
import 'package:oasis/presentation/bienvenida/bienvenida_screen.dart';
import 'package:oasis/presentation/animacion/animacion_screen.dart';
import 'package:oasis/presentation/registro/registro_inicio_screen.dart';
import 'package:oasis/presentation/aspirante/chat/chat_test_screen.dart';
import 'package:oasis/presentation/aspirante/chat/chat_screen.dart';
import 'package:oasis/presentation/aspirante/chat/chat_conversacion_screen.dart';

class NoTransitionPage<T> extends CustomTransitionPage<T> {
  NoTransitionPage({super.key, required super.child})
    : super(transitionsBuilder: (_, _, _, child) => child);
}

final appRouter = GoRouter(
  routes: [
    // Pantalla de animación inicial con verificación de sesión
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

    GoRoute(
      path: '/bienvenida',
      name: 'bienvenida',
      pageBuilder: (context, state) =>
          NoTransitionPage(key: state.pageKey, child: const BienvenidaScreen()),
    ),

    GoRoute(
      path: '/acceso',
      name: 'acceso',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: AccesoScreen(
          onAccesoExitoso: () => context.go('/inicio'),
          onBackToBienvenida: () => context.go('/bienvenida'),
        ),
      ),
    ),

    GoRoute(
      path: '/registro_inicio',
      name: 'registro_inicio',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const RegistroInicioScreen(),
      ),
    ),

    GoRoute(
      path: '/asp_reg_paso1',
      name: 'asp_reg_paso1',
      pageBuilder: (context, state) =>
          NoTransitionPage(key: state.pageKey, child: RegistroPaso1Screen()),
    ),

    GoRoute(
      path: '/asp_reg_paso2',
      name: 'asp_reg_paso2',
      pageBuilder: (context, state) =>
          NoTransitionPage(key: state.pageKey, child: const RegistroPaso2Screen()),
    ),

    GoRoute(
      path: '/asp_reg_paso3',
      name: 'asp_reg_paso3',
      pageBuilder: (context, state) {
        final pinPeticion = state.extra as PinPeticion;
        return NoTransitionPage(
          key: state.pageKey,
          child: RegistroPaso3Screen(pinPeticion: pinPeticion),
        );
      },
    ),

    GoRoute(
      path: '/inicio',
      name: 'inicio',
      pageBuilder: (context, state) =>
          NoTransitionPage(key: state.pageKey, child: const InicioScreen()),
    ),
    GoRoute(
      path: '/postulacion',
      name: 'postulacion',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const PostulacionScreen(),
      ),
    ),

    GoRoute(
      path: '/match',
      name: 'match',
      pageBuilder: (context, state) =>
          NoTransitionPage(key: state.pageKey, child: const MatchScreen()),
    ),

    GoRoute(
      path: '/explorar',
      name: 'explorar',
      pageBuilder: (context, state) =>
          NoTransitionPage(key: state.pageKey, child: const ExplorarScreen()),
    ),

    GoRoute(
      path: '/perfil',
      name: 'perfil',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const PerfilOpcionesScreen(),
      ),
    ),

    // ========== RUTAS DE CHAT ==========
    
    /// Pantalla de prueba para ingresar parámetros de chat
    /// Ruta: /chat-test
    /// Parámetros: userId (requerido), empresaId (opcional), vacanteId (opcional)
    GoRoute(
      path: '/chat-test',
      name: 'chat_test',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const ChatTestScreen(),
      ),
    ),

    /// Pantalla principal de chat (Lista de todos los chats)
    /// Ruta: /chat
    /// Nota: userId y empresaId se obtienen automáticamente de la sesión
    GoRoute(
      path: '/chat',
      name: 'chat',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const ChatScreen(),
      ),
    ),

    /// Pantalla de conversación individual
    /// Ruta: /chat/:postulacionId
    /// Parámetros: postulacionId (en ruta), extra: {vacanteTitulo, contraparteNombre}
    /// Nota: userId y empresaId se obtienen automáticamente de la sesión
    GoRoute(
      path: '/chat/:postulacionId',
      name: 'chat_conversacion',
      pageBuilder: (context, state) {
        final postulacionId = int.parse(state.pathParameters['postulacionId']!);
        final extra = state.extra as Map<String, dynamic>?;
        final vacanteTitulo = extra?['vacanteTitulo'] as String? ?? 'Chat';
        final contraparteNombre = extra?['contraparteNombre'] as String? ?? '';
        
        return NoTransitionPage(
          key: state.pageKey,
          child: ChatConversacionScreen(
            postulacionId: postulacionId,
            vacanteTitulo: vacanteTitulo,
            contraparteNombre: contraparteNombre,
          ),
        );
      },
    ),
  ],
);
