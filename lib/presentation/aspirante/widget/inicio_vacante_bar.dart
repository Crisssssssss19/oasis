import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InicioVacanteBar extends StatefulWidget {
  final VoidCallback onExpandirClick;
  final VoidCallback onFavoritoClick;
  final VoidCallback onCompartirClick;

  const InicioVacanteBar({
    super.key,
    required this.onExpandirClick,
    required this.onFavoritoClick,
    required this.onCompartirClick,
  });

  @override
  State<InicioVacanteBar> createState() => _InicioVacanteBarState();
}

class _InicioVacanteBarState extends State<InicioVacanteBar>
    with SingleTickerProviderStateMixin {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final backgroundCircle = colorScheme.surface;
    final iconColor = colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔝 Botón fijo: cambia entre maximizar y minimizar
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: expanded
                ? _circleSvgButton(
                    key: const ValueKey("minimizar"),
                    asset: "assets/icons/ic_minimizar.svg",
                    background: backgroundCircle,
                    iconColor: iconColor,
                    onTap: () => setState(() => expanded = false),
                  )
                : _circleSvgButton(
                    key: const ValueKey("maximizar"),
                    asset: "assets/icons/ic_maximizar.svg",
                    background: backgroundCircle,
                    iconColor: iconColor,
                    onTap: () => setState(() => expanded = true),
                  ),
          ),

          // Íconos adicionales que aparecen debajo
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: expanded
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      _circleSvgButton(
                        asset: "assets/icons/ic_corazon.svg",
                        background: colorScheme.error,
                        iconColor: colorScheme.onError,
                        size: 60,
                        onTap: widget.onFavoritoClick,
                      ),
                      const SizedBox(height: 8),
                      _circleSvgButton(
                        asset: "assets/icons/ic_abajo.svg",
                        background: backgroundCircle,
                        iconColor: iconColor,
                        onTap: widget.onExpandirClick,
                      ),
                      const SizedBox(height: 8),
                      _circleSvgButton(
                        asset: "assets/icons/ic_compartir.svg",
                        background: backgroundCircle,
                        iconColor: iconColor,
                        onTap: widget.onCompartirClick,
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _circleSvgButton({
    Key? key,
    required String asset,
    required Color background,
    required Color iconColor,
    required VoidCallback onTap,
    double size = 46,
  }) {
    return SizedBox(
      key: key,
      width: 62,
      height: 62,
      child: Center(
        child: IconButton(
          onPressed: onTap,
          icon: SvgPicture.asset(
            asset,
            width: size * 0.55,
            height: size * 0.55,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
          style: IconButton.styleFrom(
            backgroundColor: background,
            shape: const CircleBorder(),
            fixedSize: Size(size, size),
          ),
        ),
      ),
    );
  }
}
