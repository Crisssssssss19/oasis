import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class AppBottomBar extends StatelessWidget {
  final int currentIndex;
  final String? profileImageBase64;
  final Color? activeColor;

  const AppBottomBar({
    super.key,
    required this.currentIndex,
    this.profileImageBase64,
    this.activeColor,
  });

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/inicio');
        break;
      case 1:
        context.go('/postulacion');
        break;
      case 2:
        context.go('/match');
        break;
      case 3:
        context.go('/explorar');
        break;
      case 4:
        context.go('/perfil');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      "assets/icons/ic_home.svg",
      "assets/icons/ic_postulaciones.svg",
      "assets/icons/ic_matches.svg",
      "assets/icons/ic_explorar.svg",
      "assets/icons/ic_perfil.svg",
    ];

    final colorScheme = Theme.of(context).colorScheme;
    final activeBgColor = activeColor ?? colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isActive = index == currentIndex;

          Widget iconWidget;

          if (index == 4 && profileImageBase64 != null) {
            try {
              final bytes = base64Decode(profileImageBase64!);
              iconWidget = CircleAvatar(
                radius: 14,
                backgroundImage: MemoryImage(bytes),
              );
            } catch (_) {
              iconWidget = const CircleAvatar(
                radius: 14,
                child: Icon(Icons.person, size: 16),
              );
            }
          } else {
            iconWidget = SvgPicture.asset(
              items[index],
              width: 28,
              height: 28,
              colorFilter: ColorFilter.mode(
                isActive ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                BlendMode.srcIn,
              ),
            );
          }

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            // 👈 asegura que toda el área cuente
            onTap: () => _onItemTapped(context, index),
            child: SizedBox(
              width: 56, // 👈 área mínima de toque
              height: 56,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: isActive
                      ? BoxDecoration(
                          shape: BoxShape.circle,
                          color: activeBgColor,
                        )
                      : null,
                  child: iconWidget,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
