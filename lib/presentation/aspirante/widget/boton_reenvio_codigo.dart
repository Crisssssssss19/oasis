import 'dart:async';
import 'package:flutter/material.dart';
import 'package:oasis/core/theme/colores_extra.dart';
import 'package:oasis/core/util/tiempo_suspension_helper.dart';

class BotonReenvioCodigo extends StatefulWidget {
  final String fechaCreacion;
  final int minutosBloqueo;
  final VoidCallback onReenviar;
  final int? intentoActual;
  final int? totalIntentos;

  const BotonReenvioCodigo({
    super.key,
    required this.fechaCreacion,
    required this.minutosBloqueo,
    required this.onReenviar,
    this.intentoActual,
    this.totalIntentos,
  });

  @override
  State<BotonReenvioCodigo> createState() => _BotonReenvioCodigoState();
}

class _BotonReenvioCodigoState extends State<BotonReenvioCodigo> {
  late Duration _restante;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _restante = calcularTiempoRestante(widget.fechaCreacion, widget.minutosBloqueo);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _restante = _restante - const Duration(seconds: 1);
        if (_restante <= Duration.zero) {
          _timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _textoBoton {
    if (_restante > Duration.zero) {
      final mm = _restante.inMinutes.remainder(60).toString().padLeft(2, '0');
      final ss = _restante.inSeconds.remainder(60).toString().padLeft(2, '0');
      return "Reenviar en $mm:$ss";
    }
    return "Reenviar código";
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final coloresExtra = Theme.of(context).extension<ColoresExtra>()!;

    return Column(
      children: [
        FractionallySizedBox(
          widthFactor: 0.87,
          child: ElevatedButton(
            onPressed: _restante <= Duration.zero ? widget.onReenviar : null,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(40),
              backgroundColor: _restante <= Duration.zero
                  ? coloresExtra.verdeIntenso
                  : coloresExtra.disabled,
              foregroundColor: colores.onTertiary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(_textoBoton),
          ),
        ),
        const SizedBox(height: 8),
        if (widget.intentoActual != null && widget.totalIntentos != null)
          Text(
            "Intento ${widget.intentoActual} de ${widget.totalIntentos}",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colores.outline,
              fontSize: 14,
            ),
          ),
      ],
    );
  }
}