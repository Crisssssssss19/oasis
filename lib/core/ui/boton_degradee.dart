import 'package:flutter/material.dart';

class BotonDegradee extends StatelessWidget {
  final String text;
  final VoidCallback onClick;
  final List<Color> gradiente;
  final Color contentColor;
  final bool enabled;
  final double height;

  const BotonDegradee({
    super.key,
    required this.text,
    required this.onClick,
    required this.gradiente,
    required this.contentColor,
    this.enabled = true,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = enabled ? gradiente : [Colors.grey, Colors.grey];
    final effectiveContentColor = enabled ? contentColor : Colors.black26;

    return GestureDetector(
      onTap: enabled ? onClick : null,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: effectiveGradient,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: effectiveContentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
