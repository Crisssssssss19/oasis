import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:oasis/core/constants/country_prefixes.dart';
import 'package:oasis/core/theme/colores_extra.dart';
import 'package:oasis/core/ui/barra_superior.dart';
import 'package:oasis/presentation/aspirante/registro/paso1/registro_paso1_provider.dart';
import 'package:oasis/presentation/aspirante/registro/paso1/registro_paso1_state.dart';

class RegistroPaso1Screen extends ConsumerStatefulWidget {
  const RegistroPaso1Screen({super.key});

  @override
  ConsumerState<RegistroPaso1Screen> createState() =>
      _RegistroPaso1ScreenState();
}

class _RegistroPaso1ScreenState extends ConsumerState<RegistroPaso1Screen> {
  late final TextEditingController _celularController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(registroPaso1Provider);
    _celularController = TextEditingController(text: state.celular);
  }

  @override
  void dispose() {
    _celularController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registroPaso1Provider);
    final notifier = ref.read(registroPaso1Provider.notifier);
    final colores = Theme.of(context).colorScheme;
    final coloresExtra = Theme.of(context).extension<ColoresExtra>()!;

    // 🔎 Escuchar cambios de estado
    ref.listen<RegistroPaso1State>(registroPaso1Provider, (prev, next) {
      // Reset visual del campo celular
      if (prev?.celular != next.celular && next.celular.isEmpty) {
        _celularController.text = "";
      }
      // Navegación al paso 2: solo cuando pasa de "no exitoso" a "exitoso"
      final antesNoExitoso = prev?.pinRespuesta?.exito != true;
      final ahoraExitoso = next.pinRespuesta?.exito == true;

      if (antesNoExitoso && ahoraExitoso) {
        context.pushNamed('asp_reg_paso2');
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            children: [
              BarraSuperior(
                onBack: () => context.pop(),
                rightIconAsset: 'assets/images/logo_app.png',
              ),
              const SizedBox(height: 20),

              // Título
              Text(
                "¿Puedes darnos tu número telefónico?",
                style: TextStyle(
                  color: colores.primary,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Ícono
              CircleAvatar(
                radius: 45,
                backgroundColor: colores.primary,
                child: SvgPicture.asset(
                  'assets/icons/ic_phone.svg',
                  width: 40,
                  height: 40,
                  colorFilter: ColorFilter.mode(
                    colores.onPrimary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Texto explicativo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "La App enviará un código al número celular indicado, esto se "
                  "realiza para verificar que efectivamente el número celular "
                  "corresponde al número del aspirante",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colores.outline,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
              const SizedBox(height: 24),

              // Prefijo + Celular
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        initialValue: state.prefijo.isNotEmpty
                            ? state.prefijo
                            : defaultPrefix,
                        items: countryPrefixes
                            .map(
                              (codigo) => DropdownMenuItem(
                                value: codigo,
                                child: Text(codigo),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) notifier.setPrefijo(val);
                        },
                        decoration: InputDecoration(
                          labelText: "País",
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: state.errorPais != null
                                  ? colores.error
                                  : colores.outline,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 5,
                      child: TextField(
                        controller: _celularController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(15),
                        ],
                        decoration: InputDecoration(
                          labelText: "Número de celular",
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: state.errorCelular != null
                                  ? colores.error
                                  : colores.outline,
                            ),
                          ),
                        ),
                        onChanged: notifier.setCelular,
                      ),
                    ),
                  ],
                ),
              ),

              // Errores
              if (state.errorCelular != null || state.errorPais != null)
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      [
                        if (state.errorCelular != null) state.errorCelular!,
                        if (state.errorPais != null) state.errorPais!,
                      ].join(" - "),
                      style: TextStyle(color: colores.error, fontSize: 13),
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Botón enviar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: state.cargando
                      ? null
                      : () async {
                          FocusScope.of(context).unfocus();
                          await notifier.validarYEnviar();
                        },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: state.cargando
                        ? coloresExtra.disabled
                        : colores.primary,
                    foregroundColor: colores.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(state.cargando ? "Enviando..." : "Enviar código"),
                ),
              ),

              // Mensaje de respuesta
              if (state.pinRespuesta != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    state.pinRespuesta!.mensaje,
                    style: TextStyle(
                      color: state.pinRespuesta!.exito
                          ? colores.primary
                          : colores.error,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),

      // Footer
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lock, size: 20, color: colores.error),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                "Esta información es privada y no se comparte con ninguna empresa a menos que el aspirante haga Match en una vacante",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 14,
                  color: colores.outline,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
