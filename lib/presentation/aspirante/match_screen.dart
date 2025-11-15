import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oasis/core/di/providers.dart';
import 'package:oasis/core/ui/app_bottom_bar.dart';
import 'package:oasis/core/ui/app_top_bar.dart';

import 'package:oasis/presentation/aspirante/match_card.dart';
import 'package:oasis/presentation/aspirante/mock/vacante_mock.dart';

class MatchScreen extends ConsumerWidget {
  const MatchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppTopBar(
        title: "Macthes",
        notificacionesCount: 3,
        chatCount: 1,
        onNotificacionesPressed: () => context.go('/notificaciones'),
        onChatPressed: () => context.go('/chat'),
      ),

      body: ListView.builder(
        itemCount: vacantesMock.length,
        itemBuilder: (context, index) {
          final vacante = vacantesMock[index];
          return MatchCard(vacante: vacante);
        },
      ),

      bottomNavigationBar: AppBottomBar(
        currentIndex: 2,
        profileImageBase64: session.imageBase64,
        activeColor: colorScheme.tertiary,
      ),
    );
  }
}
