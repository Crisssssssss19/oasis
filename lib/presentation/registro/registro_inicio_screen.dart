import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oasis/core/theme/colores_bienvenida.dart';
import 'package:oasis/core/ui/barra_superior.dart';
import 'package:oasis/core/ui/boton_degradee.dart';
import 'package:oasis/core/ui/establecer_texto_footer.dart';
import 'package:oasis/core/ui/logo_principal.dart';

class BotonesRegistro extends StatelessWidget {
  const BotonesRegistro({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        BotonDegradee(
          text: "Soy aspirante",
          onClick: () => context.push('/asp_reg_paso1'),
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
          text: "Soy empresa",
          onClick: () => context.push('/empresa/vacantes'),
          gradiente: isDark
              ? [
            temaOscuroBotonGradienteAmarilloInicio,
            temaOscuroBotonGradienteAmarilloFin,
          ]
              : [
            temaClaroBotonGradienteAmarilloInicio,
            temaClaroBotonGradienteAmarilloFin,
          ],
          contentColor: isDark
              ? temaOscuroBotonGradienteAmarilloContent
              : temaClaroBotonGradienteAmarilloContent,
          height: 50,
        ),
      ],
    );
  }
}

class RegistroInicioScreen extends StatelessWidget {
  const RegistroInicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradienteFondo =
    isDark ? gradienteOscuroBienvenida : gradienteClaroBienvenida;

    return Scaffold(
      body: Stack(
        children: [
          // Fondo con gradiente
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradienteFondo,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Contenido scrollable arriba
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
            // 👆 dejamos espacio inferior para no tapar botones con el footer
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const LogoPrincipal(),
                const SizedBox(height: 30),
                Text(
                  "Antes de empezar",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "¿Quién soy?",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 80),
                const BotonesRegistro(),
              ],
            ),
          ),

          // Barra flotante arriba
          BarraSuperior(onBack: () => context.pop()),

          // 👇 Footer fijo dentro del gradiente
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: EstablecerTextoFooter(
                text: "Powered by ©CIEUnimagdalena - ${DateTime.now().year}",
              ),
            ),
          ),
        ],
      ),
    );
  }
}