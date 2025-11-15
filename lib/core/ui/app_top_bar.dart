import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final int? notificacionesCount;
  final int? chatCount;
  final VoidCallback? onNotificacionesPressed;
  final VoidCallback? onChatPressed;
  final bool isChatActive; // Indica si el icono de chat debe verse "presionado"

  const AppTopBar({
    super.key,
    required this.title,
    this.notificacionesCount,
    this.chatCount,
    this.onNotificacionesPressed,
    this.onChatPressed,
    this.isChatActive = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  Widget _buildIconWithBadge({
    required BuildContext context,
    required String assetPath,
    required int? count,
    required VoidCallback? onPressed,
    bool isActive = false, // Si está activo, muestra fondo
  }) {
    final badgeVisible = count != null && count > 0;
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: isActive
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary,
                )
              : null,
          child: IconButton(
            onPressed: onPressed,
            icon: SvgPicture.asset(
              assetPath,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                isActive ? colorScheme.onPrimary : colorScheme.onSurface,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        if (badgeVisible)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.tertiary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: colorScheme.onTertiary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasNotificaciones = onNotificacionesPressed != null;
    final hasChat = onChatPressed != null;

    return SafeArea(
      child: Container(
        height: preferredSize.height,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 🔹 Título centrado
            Center(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // 🔹 Íconos opcionales a la derecha
            if (hasNotificaciones || hasChat)
              Positioned(
                right: 0,
                child: Row(
                  children: [
                    if (hasNotificaciones)
                      _buildIconWithBadge(
                        context: context,
                        assetPath: "assets/icons/ic_notificaciones.svg",
                        count: notificacionesCount,
                        onPressed: onNotificacionesPressed,
                      ),
                    if (hasNotificaciones && hasChat) const SizedBox(width: 12),
                    if (hasChat)
                      _buildIconWithBadge(
                        context: context,
                        assetPath: "assets/icons/ic_chat.svg",
                        count: chatCount,
                        onPressed: onChatPressed,
                        isActive: isChatActive,
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}