import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oasis/core/di/providers.dart';
import 'package:oasis/core/ui/app_bottom_bar.dart';
import 'package:oasis/core/ui/app_top_bar.dart';
import 'package:oasis/presentation/aspirante/explorar_card.dart';
import 'package:oasis/presentation/aspirante/mock/vacante_mock.dart';

class ExplorarScreen extends ConsumerStatefulWidget {
  const ExplorarScreen({super.key});

  @override
  ConsumerState<ExplorarScreen> createState() => _ExplorarScreenState();
}

class _ExplorarScreenState extends ConsumerState<ExplorarScreen> {
  String query = "";

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // 🔎 Filtrado dinámico por título, empresa o keywords
    final filteredVacantes = vacantesMock.where((v) {
      final q = query.toLowerCase();
      return v.titulo.toLowerCase().contains(q) ||
          v.empresa.toLowerCase().contains(q) ||
          v.keyWords.any((kw) => kw.toLowerCase().contains(q));
    }).toList();

    return Scaffold(
      appBar: AppTopBar(
        title: "Explorar",
        notificacionesCount: 3,
        chatCount: 1,
        onNotificacionesPressed: () => context.go('/notificaciones'),
        onChatPressed: () => context.go('/chat'),
      ),

      body: Column(
        children: [
          // Caja de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) => setState(() => query = value),
              decoration: InputDecoration(
                hintText: "Buscar empleos",
                hintStyle: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: colorScheme.onSurface.withValues(alpha: 0.8),
                ),
                filled: true,
                fillColor: colorScheme.surface, // 👈 fondo neutro
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: colorScheme.outline, // 👈 usa el outline de la paleta
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: colorScheme.primary, // 👈 al enfocar, resalta con primary
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
            ),
          ),

          // Lista de tarjetas filtradas
          Expanded(
            child: ListView.builder(
              itemCount: filteredVacantes.length,
              itemBuilder: (context, index) {
                final vacante = filteredVacantes[index];
                return ExplorarCard(vacante: vacante);
              },
            ),
          ),
        ],
      ),

      bottomNavigationBar: AppBottomBar(
        currentIndex: 3,
        profileImageBase64: session.imageBase64,
      ),
    );
  }
}