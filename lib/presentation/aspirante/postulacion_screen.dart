import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oasis/core/di/providers.dart';
import 'package:oasis/core/ui/app_bottom_bar.dart';
import 'package:oasis/core/ui/app_top_bar.dart';
import 'package:oasis/presentation/aspirante/mock/vacante_mock.dart';
import 'package:oasis/presentation/aspirante/postulacion_card.dart';

class PostulacionScreen extends ConsumerWidget {
  const PostulacionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);

    return Scaffold(
      appBar: AppTopBar(
        title: "Postulaciones",
        notificacionesCount: 3,
        chatCount: 1,
        onNotificacionesPressed: () => context.go('/notificaciones'),
        onChatPressed: () => context.go('/chat'),
      ),

      body: ListView.builder(
        itemCount: vacantesMock.length,
        itemBuilder: (context, index) {
          final vacante = vacantesMock[index];
          return PostulacionCard(vacante: vacante);
        },
      ),

      bottomNavigationBar: AppBottomBar(
        currentIndex: 1,
        profileImageBase64: session.imageBase64,
      ),
    );
  }
}