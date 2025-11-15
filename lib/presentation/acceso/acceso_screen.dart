import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oasis/core/theme/colores_bienvenida.dart';
import 'package:oasis/core/theme/tema_bienvenida.dart';
import 'package:oasis/core/ui/barra_superior.dart';
import 'package:oasis/core/ui/logo_principal.dart';
import 'package:oasis/presentation/acceso/acceso_provider.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';

class AccesoScreen extends ConsumerStatefulWidget {
  final VoidCallback onAccesoExitoso;
  final VoidCallback onBackToBienvenida;

  const AccesoScreen({
    super.key,
    required this.onAccesoExitoso,
    required this.onBackToBienvenida,
  });

  @override
  ConsumerState<AccesoScreen> createState() => _AccesoScreenState();
}

class _AccesoScreenState extends ConsumerState<AccesoScreen> {
  late final TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(accesoProvider);
    final notifier = ref.read(accesoProvider.notifier);

    final focusScope = FocusScope.of(context);

    if (state.password.isEmpty && passwordController.text.isNotEmpty) {
      passwordController.clear();
    }

    final overlay = Overlay.of(context);
    final statusBarHeight = MediaQuery.of(context).padding.top;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tema = isDark ? temaBienvenidaOscuro : temaBienvenidaClaro;
    final colorScheme = tema.colorScheme;

    final gradiente = isDark
        ? [temaOscuroBotonGradienteInicio, temaOscuroBotonGradienteFin]
        : [temaClaroBotonGradienteInicio, temaClaroBotonGradienteFin];

    final contentColor = isDark
        ? temaOscuroBotonGradienteContent
        : temaClaroBotonGradienteContent;

    return Theme(
      data: tema,
      child: Scaffold(
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: statusBarHeight + kToolbarHeight),

                  Transform.translate(
                    offset: const Offset(0, -3),
                    child: const LogoPrincipal(top: 0),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    "Usuarios registrados",
                    textAlign: TextAlign.center,
                    style: tema.textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Campo de correo ---
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Correo electrónico",
                      errorText: state.submitted ? state.emailError : null,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.next,
                    onChanged: notifier.setEmail,
                  ),

                  const SizedBox(height: 12),

                  // --- Campo de contraseña ---
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: "Contraseña",
                      errorText: state.submitted ? state.passwordError : null,
                    ),
                    obscureText: true,
                    onChanged: notifier.setPassword,
                  ),
                  const SizedBox(height: 20),

                  // --- Botón con gradiente ---
                  ElevatedButton(
                    onPressed: state.loading
                        ? null
                        : () async {
                            final camposValidos = notifier.validarCampos();
                            if (!camposValidos) return;

                            final result = await notifier.login();

                            if (result.success) {
                              widget.onAccesoExitoso();
                            } else {
                              showTopSnackBar(
                                overlay,
                                CustomSnackBar.error(
                                  message: "Credenciales incorrectas",
                                ),
                                displayDuration: const Duration(seconds: 3),
                                padding: EdgeInsets.only(
                                  top: statusBarHeight,
                                  left: 16,
                                  right: 16,
                                ),
                              );
                              focusScope.unfocus();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: state.loading
                            ? null
                            : LinearGradient(
                                colors: gradiente,
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                        color: state.loading ? Colors.grey : null,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        height: 50,
                        alignment: Alignment.center,
                        child: Text(
                          state.loading
                              ? "Verificando credenciales"
                              : "Iniciar sesión",
                          style: tema.textTheme.labelLarge?.copyWith(
                            color: state.loading
                                ? colorScheme.onSurface
                                : contentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),

            BarraSuperior(onBack: widget.onBackToBienvenida),
          ],
        ),
      ),
    );
  }
}
