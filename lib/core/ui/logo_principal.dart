import 'package:flutter/material.dart';

class LogoPrincipal extends StatelessWidget {
  final VoidCallback? onTap;
  final double top;

  const LogoPrincipal({
    super.key,
    this.onTap,
    this.top = 90,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: top),
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.translucent,
          child: SizedBox(
            width: 220,
            child: Image.asset(
              isDark
                  ? "assets/images/logo_mejorado_oscuro.png"
                  : "assets/images/logo_mejorado_claro.png",
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}