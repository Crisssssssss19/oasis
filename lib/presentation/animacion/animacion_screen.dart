import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:oasis/core/theme/colores_bienvenida.dart';
import 'package:oasis/core/theme/tema_bienvenida.dart';
import 'package:oasis/core/ui/logo_principal.dart';
import 'package:oasis/core/util/user_role_helper.dart'; // 👈 NUEVO

class AnimacionScreen extends StatefulWidget {
  final VoidCallback onAnimacionTerminada;

  const AnimacionScreen({super.key, required this.onAnimacionTerminada});

  @override
  State<AnimacionScreen> createState() => _AnimacionScreenState();
}

class _AnimacionScreenState extends State<AnimacionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimacionTerminada();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradienteFondo = isDark ? gradienteOscuroBienvenida : gradienteClaroBienvenida;
    final tema = isDark ? temaBienvenidaOscuro : temaBienvenidaClaro;
    final colorScheme = tema.colorScheme;
    final textTheme = tema.textTheme;

    return Theme(
      data: tema,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradienteFondo,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const LogoPrincipal(top: 53),
                const SizedBox(height: 30),
                Text(
                  "Volando hacia",
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: 18,
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "nuevas oportunidades",
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: 18,
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                Lottie.asset(
                  "assets/animations/progreso.json",
                  controller: _controller,
                  width: 300,
                  height: 200,
                  onLoaded: (composition) {
                    _controller
                      ..duration = composition.duration
                      ..forward();
                  },
                ),
                const SizedBox(height: 40),
                SizedBox(
                  height: 70,
                  child: Image.asset(
                    isDark
                        ? "assets/images/from_oscuro.png"
                        : "assets/images/from_claro.png",
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}