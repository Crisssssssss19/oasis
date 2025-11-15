import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oasis/core/di/providers.dart';

class PerfilResumenCard extends ConsumerWidget {
  final String nombre;
  final String subtitulo1;
  final String subtitulo2;
  final double progreso; // valor entre 0.0 y 1.0
  final List<String> palabrasClave;

  const PerfilResumenCard({
    super.key,
    required this.nombre,
    required this.subtitulo1,
    required this.subtitulo2,
    required this.progreso,
    required this.palabrasClave,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);

    // Avatar desde base64
    Widget avatar;
    if (session.imageBase64 != null) {
      try {
        Uint8List bytes = base64Decode(session.imageBase64!);
        avatar = CircleAvatar(radius: 40, backgroundImage: MemoryImage(bytes));
      } catch (_) {
        avatar = const CircleAvatar(radius: 40, child: Icon(Icons.person));
      }
    } else {
      avatar = const CircleAvatar(radius: 40, child: Icon(Icons.person));
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra de progreso
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Completar perfil",
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    "${(progreso * 100).toInt()}%",
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progreso,
                  minHeight: 8,
                  backgroundColor: colorScheme.outline.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Fila con avatar + textos
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              avatar,
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitulo1,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      subtitulo2,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Palabras clave dinámicas
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: palabrasClave.map((palabra) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  palabra,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
