import 'package:flutter/material.dart';

class EstablecerTextoFooter extends StatelessWidget {
  final String text;
  final double textSize;

  const EstablecerTextoFooter({
    super.key,
    required this.text,
    this.textSize = 15,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: textSize,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}