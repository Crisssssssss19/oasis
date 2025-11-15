import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CodigoVerificacionWidget extends StatefulWidget {
  final void Function(String codigo, bool isComplete)? onCodeChanged;
  final bool hasError;

  const CodigoVerificacionWidget({
    super.key,
    this.onCodeChanged,
    this.hasError = false,
  });

  @override
  State<CodigoVerificacionWidget> createState() =>
      _CodigoVerificacionWidgetState();
}

class _CodigoVerificacionWidgetState extends State<CodigoVerificacionWidget> {
  final int _length = 6;
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_length, (_) => TextEditingController());
    _focusNodes = List.generate(_length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  bool get _isComplete =>
      _controllers.every((c) => c.text.isNotEmpty && c.text.length == 1);

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      _controllers[index].text = value.characters.last;
      _controllers[index].selection = TextSelection.fromPosition(
        TextPosition(offset: _controllers[index].text.length),
      );
      if (index + 1 < _length) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      } else {
        FocusScope.of(context).unfocus();
      }
    }
    setState(() {
      final codigo = _controllers.map((c) => c.text).join();
      widget.onCodeChanged?.call(codigo, _isComplete);
    });
  }

  void _onKey(KeyEvent event, int index) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_length, (index) {
          return SizedBox(
            width: 45,
            child: KeyboardListener(
              focusNode: FocusNode(),
              onKeyEvent: (event) => _onKey(event, index),
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(1),
                ],
                decoration: InputDecoration(
                  counterText: "",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: widget.hasError ? Colors.red : colores.outline,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: widget.hasError ? Colors.red : colores.outline,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: widget.hasError ? Colors.red : colores.primary,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (val) => _onChanged(val, index),
              ),
            ),
          );
        }),
      ),
    );
  }
}