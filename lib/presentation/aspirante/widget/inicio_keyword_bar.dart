import 'package:flutter/material.dart';

class InicioKeywordBar extends StatelessWidget {
  final List<String> palabrasClave;

  const InicioKeywordBar({super.key, required this.palabrasClave});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: palabrasClave.map((palabra) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            palabra,
            softWrap: true, // 👈 permite salto de línea
            overflow: TextOverflow.visible,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }
}
