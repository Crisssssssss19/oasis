import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BarraSuperior extends StatelessWidget {
  final VoidCallback onBack;
  final String? title;

  // Icono izquierdo (back)
  final String? backIconAsset; // Puede ser SVG o PNG
  final IconData? backIconData;

  // Icono derecho opcional (solo decorativo)
  final String? rightIconAsset; // Puede ser SVG o PNG
  final IconData? rightIconData;

  const BarraSuperior({
    super.key,
    required this.onBack,
    this.title,
    this.backIconAsset = 'assets/icons/ic_back.svg',
    this.backIconData,
    this.rightIconAsset,
    this.rightIconData,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      height: kToolbarHeight + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Botón back alineado a la izquierda
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: onBack,
              icon: _buildLeadingIcon(onSurface),
            ),
          ),

          // Título centrado
          if (title != null)
            Text(
              title!,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),

          // Icono derecho opcional (solo decorativo)
          if (rightIconAsset != null || rightIconData != null)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _buildRightIcon(onSurface),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLeadingIcon(Color color) {
    if (backIconAsset != null) {
      return _buildAssetIcon(backIconAsset!, color, size: 20);
    }
    return Icon(backIconData ?? Icons.arrow_back, size: 20, color: color);
  }

  Widget _buildRightIcon(Color color) {
    if (rightIconAsset != null) {
      return _buildAssetIcon(rightIconAsset!, color, size: kToolbarHeight * 0.6);
    }
    return Icon(rightIconData!, color: color, size: kToolbarHeight * 0.6);
  }

  /// Soporta tanto SVG como PNG/JPG
  Widget _buildAssetIcon(String asset, Color color, {double size = 24}) {
    if (asset.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        asset,
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
    } else {
      return Image.asset(
        asset,
        height: kToolbarHeight * 0.8, // ocupa casi todo el alto de la barra
        fit: BoxFit.contain,
      );
    }
  }
}