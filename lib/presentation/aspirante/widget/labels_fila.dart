import 'package:flutter/material.dart';
import 'package:oasis/core/theme/colores_extra.dart';

class LabelsFila extends StatelessWidget {
  final String label1;
  final String label2;
  final String label3;

  const LabelsFila({
    super.key,
    required this.label1,
    required this.label2,
    required this.label3,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final extra = Theme.of(context).extension<ColoresExtra>()!;
    final textTheme = Theme.of(context).textTheme;

    return Wrap(
      spacing: 8,      // separación horizontal
      runSpacing: 8,   // separación vertical si se baja de fila
      children: [
        // 1️⃣ Label con fondo verdeClaro
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: extra.verdeClaro,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label1,
            style: textTheme.bodySmall?.copyWith(
              color: extra.verdeIntenso,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // 2️⃣ Label con borde verdeClaro, texto outline
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border.all(color: extra.verdeClaro, width: 1.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label2,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.outline,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // 3️⃣ Label con borde verdeIntenso, texto verdeIntenso
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border.all(color: extra.verdeIntenso, width: 1.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label3,
            style: textTheme.bodySmall?.copyWith(
              color: extra.verdeIntenso,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}