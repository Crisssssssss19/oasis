import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:oasis/core/ui/barra_superior.dart';
import 'package:oasis/core/theme/colores_extra.dart';
import 'package:oasis/domain/model/pin_peticion.dart';
import 'package:oasis/presentation/aspirante/registro/paso1/registro_paso1_provider.dart';
import 'package:oasis/presentation/aspirante/widget/boton_reenvio_codigo.dart';
import 'package:oasis/presentation/aspirante/widget/codigo_verificacion_widget.dart';

class RegistroPaso2Screen extends ConsumerStatefulWidget {
  const RegistroPaso2Screen({super.key});

  @override
  ConsumerState<RegistroPaso2Screen> createState() =>
      _RegistroPaso2ScreenState();
}

class _RegistroPaso2ScreenState extends ConsumerState<RegistroPaso2Screen> {
  String _codigoIngresado = "";
  bool _isComplete = false;
  bool _pinIncorrecto = false;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final coloresExtra = Theme.of(context).extension<ColoresExtra>()!;

    final paso1State = ref.watch(registroPaso1Provider);
    final paso1Notifier = ref.read(registroPaso1Provider.notifier);

    final pin = paso1State.pinRespuesta;

    final numeroCelular = paso1State.celular;
    final numeroCompleto = "${paso1State.prefijo} - ${paso1State.celular}";

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          paso1Notifier.reset();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              children: [
                BarraSuperior(
                  onBack: () {
                    paso1Notifier.reset();
                    context.pop();
                  },
                  rightIconAsset: 'assets/images/logo_app.png',
                ),
                const SizedBox(height: 20),

                Text(
                  "Verifica tu número de teléfono",
                  style: TextStyle(
                    color: colores.primary,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                CircleAvatar(
                  radius: 40,
                  backgroundColor: colores.primary,
                  child: SvgPicture.asset(
                    'assets/icons/ic_phone-incoming.svg',
                    width: 35,
                    height: 35,
                    colorFilter: ColorFilter.mode(
                      colores.onPrimary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Enviamos un código de 6 dígitos a:",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colores.outline,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    numeroCompleto,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colores.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Ingresa el código para continuar",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colores.outline,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),

                const SizedBox(height: 35),

                CodigoVerificacionWidget(
                  hasError: _pinIncorrecto,
                  onCodeChanged: (codigo, isComplete) {
                    setState(() {
                      _codigoIngresado = codigo;
                      _isComplete = isComplete;
                      _pinIncorrecto = false; // reset error al escribir
                    });
                  },
                ),

                const SizedBox(height: 30),

                FractionallySizedBox(
                  widthFactor: 0.87,
                  child: ElevatedButton(
                    onPressed: _isComplete
                        ? () {
                            if (_codigoIngresado == pin?.valorPinTemporal) {
                              final peticion = PinPeticion(
                                telefonoAcceso: numeroCelular,
                              );

                              context.pushReplacementNamed(
                                'asp_reg_paso3',
                                extra: peticion,
                              );
                            } else {
                              setState(() {
                                _pinIncorrecto = true;
                              });
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: _pinIncorrecto
                          ? colores
                                .error // estado error
                          : _isComplete
                          ? colores
                                .primary // estado activo
                          : coloresExtra.disabled, // estado inactivo
                      foregroundColor: colores.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      _pinIncorrecto ? "Código incorrecto" : "Verificar código",
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                BotonReenvioCodigo(
                  key: ValueKey(pin?.fechaCreacionPinTemporal),
                  fechaCreacion: pin?.fechaCreacionPinTemporal ?? "",
                  minutosBloqueo: pin?.minutosSuspensionPinTemporal ?? 0,
                  intentoActual: pin?.intentoPinTemporal,
                  totalIntentos: pin?.totalIntentosPinTemporal,
                  onReenviar: () async {
                    await paso1Notifier.reenviarCodigo();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
