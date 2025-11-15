import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oasis/core/di/providers.dart';
import 'package:oasis/core/ui/app_bottom_bar.dart';
import 'package:oasis/core/ui/app_top_bar.dart';
import 'package:oasis/presentation/aspirante/perfil/mock/mock_perfil_resumen.dart';
import 'package:oasis/presentation/aspirante/perfil/perfil_resumen_card.dart';


class PerfilOpcionesScreen extends ConsumerWidget {
  const PerfilOpcionesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final opciones = [
      "Datos básicos",
      "Mi CV",
      "Competencias y habilidades",
      "Portafolio",
      "Configuración general",
      "Cerrar sesión",
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar que se oculta al hacer scroll
          SliverAppBar(
            pinned: false,
            floating: true,
            snap: true,
            backgroundColor: colorScheme.surface,
            elevation: 2,
            title: const AppTopBar(title: "Perfil"),
          ),

          // PerfilResumenCard envuelto en SliverToBoxAdapter
          SliverToBoxAdapter(
            child: PerfilResumenCard(
              nombre: mockPerfilResumen["nombre"] as String,
              subtitulo1: mockPerfilResumen["subtitulo1"] as String,
              subtitulo2: mockPerfilResumen["subtitulo2"] as String,
              progreso: mockPerfilResumen["progreso"] as double,
              palabrasClave: List<String>.from(
                mockPerfilResumen["palabrasClave"] as List,
              ),
            ),
          ),

          // 🔹 Lista de opciones
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final opcion = opciones[index];
              final isCerrarSesion = opcion == "Cerrar sesión";

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.primary, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.outline.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  title: Text(
                    opcion,
                    style: textTheme.titleMedium?.copyWith(
                      color: isCerrarSesion
                          ? colorScheme.error
                          : colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () async {
                    switch (opcion) {
                      case "Datos básicos":
                        context.go('/perfil/datos');
                        break;
                      case "Mi CV":
                        context.go('/perfil/cv');
                        break;
                      case "Competencias y habilidades":
                        context.go('/perfil/competencias');
                        break;
                      case "Portafolio":
                        context.go('/perfil/portafolio');
                        break;
                      case "Configuración general":
                        context.go('/perfil/configuracion');
                        break;
                      case "Cerrar sesión":
                        final confirmar = await showDialog<bool>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Cerrar sesión"),
                              content: const Text(
                                "¿Estás seguro de que deseas cerrar la sesión?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text("Cancelar"),
                                ),
                                FilledButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text("Aceptar"),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirmar == true) {
                          ref.read(sessionProvider.notifier).clearSession();
                          if (context.mounted) {
                            context.go('/bienvenida');
                          }
                        }

                        break;
                    }
                  },
                ),
              );
            }, childCount: opciones.length),
          ),
        ],
      ),

      // Bottom bar fija
      bottomNavigationBar: AppBottomBar(
        currentIndex: 4,
        profileImageBase64: session.imageBase64,
      ),
    );
  }
}
