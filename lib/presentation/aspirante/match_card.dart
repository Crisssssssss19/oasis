import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:oasis/presentation/aspirante/mock/vacante_mock.dart';

class MatchCard extends StatelessWidget {
  final Vacante vacante;

  const MatchCard({super.key, required this.vacante});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final brightness = Theme.of(context).brightness;

    final backgroundCircle = colorScheme.error;
    final iconColor = colorScheme.onError;

    final backgroundCircleChat = colorScheme.tertiary;
    final iconColorChat = colorScheme.onTertiary;

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
                          Colors.black.withValues(alpha: 0.6),
                          Colors.black.withValues(alpha: 0.0),
                          Colors.black.withValues(alpha: 0.7),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.4),
                          Colors.white.withValues(alpha: 0.0),
                          Colors.white.withValues(alpha: 0.5),
                        ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Contenido principal
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Empresa
                Text(
                  vacante.empresa,
                  style: textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Título
                Text(
                  vacante.titulo,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Estado
                Text(
                  "Match confirmado!",
                  style: textTheme.bodyLarge?.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),

          // 🔽 Íconos en la esquina inferior derecha
          Positioned(
            bottom: 12,
            right: 12,
            child: Row(
              children: [
                _circleSvgButton(
                  context,
                  asset: "assets/icons/ic_corazon.svg",
                  background: backgroundCircle,
                  iconColor: iconColor,
                ),
                const SizedBox(width: 12),
                _circleSvgButton(
                  context,
                  asset: "assets/icons/ic_chat.svg",
                  background: backgroundCircleChat,
                  iconColor: iconColorChat,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleSvgButton(
    BuildContext context, {
    required String asset,
    required Color background,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: () => context.go('/inicio'), // 👈 acción provisional
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Center(
          child: SvgPicture.asset(
            asset,
            width: 22,
            height: 22,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}
