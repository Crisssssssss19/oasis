import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oasis/core/theme/colores_bienvenida.dart';
import 'package:oasis/core/ui/animacion_mosaico.dart';
import 'package:oasis/core/ui/boton_degradee.dart';
import 'package:oasis/core/ui/establecer_texto_footer.dart';
import 'package:oasis/core/ui/logo_principal.dart';

class BotonesBienvenida extends StatelessWidget {
  const BotonesBienvenida({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        BotonDegradee(
          text: "Iniciar sesión",
          onClick: () => context.push('/acceso'),
          gradiente: isDark
              ? [temaOscuroBotonGradienteInicio, temaOscuroBotonGradienteFin]
              : [temaClaroBotonGradienteInicio, temaClaroBotonGradienteFin],
          contentColor: isDark
              ? temaOscuroBotonGradienteContent
              : temaClaroBotonGradienteContent,
          height: 50,
        ),
        const SizedBox(height: 16),
        BotonDegradee(
          text: "Crear cuenta",
          onClick: () => context.push('/registro_inicio'),
          gradiente: isDark
              ? [temaOscuroBotonGradienteInicio, temaOscuroBotonGradienteFin]
              : [temaClaroBotonGradienteInicio, temaClaroBotonGradienteFin],
          contentColor: isDark
              ? temaOscuroBotonGradienteContent
              : temaClaroBotonGradienteContent,
          height: 50,
        ),
      ],
    );
  }
}

/// Screen bienvenida con animación mosaico
class BienvenidaScreen extends StatelessWidget {
  const BienvenidaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradienteFondo = isDark
        ? gradienteOscuroBienvenida
        : gradienteClaroBienvenida;

    final contenido = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradienteFondo,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                LogoPrincipal(onTap: () => context.go('/')),
                const SizedBox(height: 30),
                Text(
                  "Volando hacia",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "nuevas oportunidades",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 80),
                const BotonesBienvenida(),
              ],
            ),
            EstablecerTextoFooter(
              text: "Powered by ©CIEUnimagdalena - ${DateTime.now().year}",
            ),
          ],
        ),
      ),
    );

    return AnimacionMosaico(
      rows: 8,
      cols: 6,
      durationMillis: 600,
      startReveal: true,
      child: contenido,
    );
  }
}
