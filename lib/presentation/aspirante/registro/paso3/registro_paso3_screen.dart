import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oasis/core/ui/barra_superior.dart';
import 'package:oasis/core/theme/colores_extra.dart';
import 'package:oasis/domain/model/pin_peticion.dart';
import 'package:oasis/presentation/aspirante/registro/paso3/registro_paso3_notifier.dart';
import 'package:oasis/presentation/aspirante/registro/paso3/registro_paso3_state.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import 'registro_paso3_provider.dart';

class RegistroPaso3Screen extends ConsumerStatefulWidget {
  final PinPeticion pinPeticion;

  const RegistroPaso3Screen({super.key, required this.pinPeticion});

  @override
  ConsumerState<RegistroPaso3Screen> createState() =>
      _RegistroPaso3ScreenState();
}

class _RegistroPaso3ScreenState extends ConsumerState<RegistroPaso3Screen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nombresController;
  late final TextEditingController _apellidosController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(registroPaso3Provider);

    _nombresController = TextEditingController(text: state.nombres)
      ..addListener(
        () => ref
            .read(registroPaso3Provider.notifier)
            .updateNombres(_nombresController.text),
      );

    _apellidosController = TextEditingController(text: state.apellidos)
      ..addListener(
        () => ref
            .read(registroPaso3Provider.notifier)
            .updateApellidos(_apellidosController.text),
      );

    _emailController = TextEditingController(text: state.email)
      ..addListener(
        () => ref
            .read(registroPaso3Provider.notifier)
            .updateEmail(_emailController.text),
      );

    _passwordController = TextEditingController(text: state.password)
      ..addListener(
        () => ref
            .read(registroPaso3Provider.notifier)
            .updatePassword(_passwordController.text),
      );

    _confirmPasswordController =
        TextEditingController(text: state.confirmPassword)..addListener(
          () => ref
              .read(registroPaso3Provider.notifier)
              .updateConfirmPassword(_confirmPasswordController.text),
        );
  }

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registroPaso3Provider);
    final notifier = ref.read(registroPaso3Provider.notifier);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            children: [
              BarraSuperior(
                onBack: () => context.pop(),
                rightIconAsset: 'assets/images/logo_app.png',
              ),
              _InfoCard(telefonoActual: widget.pinPeticion.telefonoAcceso),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _NombresField(controller: _nombresController),
                      const SizedBox(height: 16),
                      _ApellidosField(controller: _apellidosController),
                      const SizedBox(height: 16),
                      _EmailField(controller: _emailController),
                      const SizedBox(height: 16),
                      _PasswordField(controller: _passwordController),
                      const SizedBox(height: 16),
                      _ConfirmPasswordField(
                        controller: _confirmPasswordController,
                        passwordController: _passwordController,
                      ),
                      const SizedBox(height: 10),
                      const _TerminosCheckbox(),
                      const SizedBox(height: 10),
                      _SubmitButton(
                        state: state,
                        notifier: notifier,
                        telefonoActual: widget.pinPeticion.telefonoAcceso,
                        formKey: _formKey,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NombresField extends StatelessWidget {
  final TextEditingController controller;

  const _NombresField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: "Nombres",
        border: UnderlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return "Campo requerido";
        if (value.length < 3) return "Mínimo 3 caracteres";
        if (value.length > 20) return "Máximo 20 caracteres";
        if (RegExp(r'[0-9]').hasMatch(value)) return "No se permiten números";
        return null;
      },
    );
  }
}

class _ApellidosField extends StatelessWidget {
  final TextEditingController controller;

  const _ApellidosField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: "Apellidos",
        border: UnderlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return "Campo requerido";
        if (value.length < 3) return "Mínimo 3 caracteres";
        if (value.length > 20) return "Máximo 20 caracteres";
        if (RegExp(r'[0-9]').hasMatch(value)) return "No se permiten números";
        return null;
      },
    );
  }
}

class _EmailField extends StatelessWidget {
  final TextEditingController controller;

  const _EmailField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      decoration: const InputDecoration(
        labelText: "Correo electrónico",
        border: UnderlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return "Campo requerido";
        if (!EmailValidator.validate(value)) return "Correo inválido";
        return null;
      },
    );
  }
}

class _PasswordField extends ConsumerWidget {
  final TextEditingController controller;

  const _PasswordField({required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registroPaso3Provider);
    final notifier = ref.read(registroPaso3Provider.notifier);

    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: "Contraseña",
        border: const UnderlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(
            state.showPassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: notifier.toggleShowPassword,
        ),
      ),
      obscureText: !state.showPassword,
      validator: (value) {
        if (value == null || value.isEmpty) return "Campo requerido";
        if (value.length < 6) return "Mínimo 6 caracteres";
        return null;
      },
    );
  }
}

class _ConfirmPasswordField extends ConsumerWidget {
  final TextEditingController controller;
  final TextEditingController passwordController;

  const _ConfirmPasswordField({
    required this.controller,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registroPaso3Provider);
    final notifier = ref.read(registroPaso3Provider.notifier);

    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: "Confirmar contraseña",
        border: const UnderlineInputBorder(),
        suffixIcon: IconButton(
          icon: Icon(
            state.showConfirmPassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: notifier.toggleShowConfirmPassword,
        ),
      ),
      obscureText: !state.showConfirmPassword,
      validator: (value) {
        if (value == null || value.isEmpty) return "Campo requerido";
        if (value != passwordController.text) {
          return "Las contraseñas no coinciden";
        }
        return null;
      },
    );
  }
}

class _TerminosCheckbox extends ConsumerWidget {
  const _TerminosCheckbox();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registroPaso3Provider);
    final notifier = ref.read(registroPaso3Provider.notifier);

    return CheckboxListTile(
      value: state.aceptaTerminos,
      onChanged: (val) => notifier.toggleAceptaTerminos(val ?? false),
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(
        "Al registrarme, acepto los términos, condiciones y la política de privacidad",
        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final RegistroPaso3State state;
  final RegistroPaso3Notifier notifier;
  final String telefonoActual;
  final GlobalKey<FormState> formKey;

  const _SubmitButton({
    required this.state,
    required this.notifier,
    required this.telefonoActual,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final coloresExtra = Theme.of(context).extension<ColoresExtra>()!;
    final overlay = Overlay.of(context);
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return FractionallySizedBox(
      widthFactor: 0.9,
      child: ElevatedButton(
        onPressed: state.isSubmitting || !state.allFieldsFilled
            ? null
            : () async {
                if (formKey.currentState?.validate() ?? false) {
                  final respuesta = await notifier.submit(telefonoActual);
                  if (!context.mounted) return;
                  if (respuesta.success) {
                    context.goNamed('inicio');
                  } else {
                    showTopSnackBar(
                      overlay,
                      CustomSnackBar.error(message: respuesta.message),
                      displayDuration: const Duration(seconds: 3),
                      padding: EdgeInsets.only(
                        top: statusBarHeight,
                        left: 16,
                        right: 16,
                      ),
                    );
                  }
                }
              },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          backgroundColor: colores.primary,
          foregroundColor: colores.onPrimary,
          disabledBackgroundColor: coloresExtra.disabled,
          disabledForegroundColor: colores.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: state.isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text("Registrarme como aspirante"),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String telefonoActual;

  const _InfoCard({required this.telefonoActual});

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final extra = Theme.of(context).extension<ColoresExtra>()!;

    return Card(
      color: extra.verdeClaro,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: colores.surface,
              child: Icon(Icons.person, size: 32, color: extra.verdeIntenso),
            ),
            const SizedBox(width: 16),

            // Datos de la card
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Datos básicos",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 3),

                  const Text("Nombres, apellidos, correo"),

                  const SizedBox(height: 3),

                  Row(
                    children: [
                      const Text("Teléfono"),
                      const SizedBox(width: 6),
                      Text(
                        telefonoActual,
                        style: TextStyle(
                          color: colores.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
