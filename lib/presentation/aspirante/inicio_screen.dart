import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oasis/core/di/providers.dart';
import 'package:oasis/core/ui/app_bottom_bar.dart';
import 'package:oasis/core/ui/app_top_bar.dart';
import 'package:oasis/presentation/aspirante/vacante/vacante_precache.dart';
import 'package:oasis/presentation/aspirante/vacante/vacante_provider.dart';
import 'package:oasis/presentation/aspirante/vacante/vacante_screen.dart';
import 'package:oasis/presentation/aspirante/vacante/vacante_state.dart';

class InicioScreen extends ConsumerStatefulWidget {
  const InicioScreen({super.key});

  @override
  ConsumerState<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends ConsumerState<InicioScreen> {
  PageController? _pageController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = ref.read(vacanteNotifierProvider);

    if (state is VacanteData) {
      _pageController ??= PageController(initialPage: state.currentIndex);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        precacheVacanteImages(context, state.vacantes);
      });
    } else {
      _pageController ??= PageController();
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final state = ref.watch(vacanteNotifierProvider);

    return Scaffold(
      appBar: AppTopBar(
        title: "Vacantes",
        notificacionesCount: 3,
        chatCount: 1,
        onNotificacionesPressed: () => context.go('/notificaciones'),
        onChatPressed: () => context.push('/chat'),
      ),
      body: switch (state) {
        VacanteLoading() => const Center(child: CircularProgressIndicator()),
        VacanteError(:final mensaje) => Center(child: Text(mensaje)),
        VacanteData(:final vacantes) => PageView.builder(
          controller: _pageController,
          itemCount: vacantes.length,
          onPageChanged: (index) {
            ref.read(vacanteNotifierProvider.notifier).setCurrentIndex(index);
          },
          itemBuilder: (context, index) {
            final vacante = vacantes[index];
            return VacanteScreen(
              vacante: vacante,
              pageController: _pageController!,
              totalPages: vacantes.length,
            );
          },
        ),
      },
      bottomNavigationBar: AppBottomBar(
        currentIndex: 0,
        profileImageBase64: session.imageBase64,
      ),
    );
  }
}
