import 'package:flutter/material.dart';
import 'package:oasis/core/theme/colores_extra.dart';
import 'package:oasis/presentation/aspirante/mock/vacante_mock.dart';

class PostulacionCard extends StatelessWidget {
  final Vacante vacante;

  const PostulacionCard({super.key, required this.vacante});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final extra = Theme.of(context).extension<ColoresExtra>()!;
    final brightness = Theme.of(context).brightness;


    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(vacante.imagenAsset, fit: BoxFit.cover),
          ),

          // Overlay degradado para mejorar legibilidad
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: brightness == Brightness.light
                      ? [
                    Colors.black.withValues(alpha: 0.6), // overlay oscuro en light
                    Colors.black.withValues(alpha: 0.0),
                    Colors.black.withValues(alpha: 0.7),
                  ]
                      : [
                    Colors.white.withValues(alpha: 0.4), // overlay claro en dark
                    Colors.white.withValues(alpha: 0.0),
                    Colors.white.withValues(alpha: 0.5),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,

                ),
              ),
            ),
          ),

          // Contenido
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Text(
                  vacante.titulo,
                  style: textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Empresa
                Text(
                  vacante.empresa,
                  style: textTheme.bodyMedium?.copyWith(
                    color: extra.verdeClaro,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),

                // Keywords
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: vacante.keyWords.map((kw) {
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
                        kw,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 8),

                // Salario
                Text(
                  vacante.textoValorOferta,
                  style: textTheme.bodyLarge?.copyWith(
                    color: extra.verdeClaro,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}