import 'dart:async';
import 'package:flutter/material.dart';

class AnimacionMosaico extends StatefulWidget {
  final int rows;
  final int cols;
  final int durationMillis;
  final bool startReveal;
  final Widget child;

  const AnimacionMosaico({
    super.key,
    required this.rows,
    required this.cols,
    required this.durationMillis,
    required this.startReveal,
    required this.child,
  });

  @override
  State<AnimacionMosaico> createState() => _AnimacionMosaicoState();
}

class _AnimacionMosaicoState extends State<AnimacionMosaico>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    final total = widget.rows * widget.cols;
    _controllers = List.generate(
      total,
      (_) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: widget.durationMillis),
      ),
    );

    if (widget.startReveal) {
      _startAnimations();
    }
  }

  void _startAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      final row = i ~/ widget.cols;
      final col = i % widget.cols;
      final delay = (row + col) * 40; // escalonado diagonal
      Future.delayed(Duration(milliseconds: delay), () {
        if (mounted) _controllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child, // 👈 contenido debajo
        Positioned.fill(
          child: IgnorePointer(
            // 👈 no intercepta taps
            ignoring: true,
            child: CustomPaint(
              painter: _MosaicoPainter(
                rows: widget.rows,
                cols: widget.cols,
                animations: _controllers,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MosaicoPainter extends CustomPainter {
  final int rows;
  final int cols;
  final List<AnimationController> animations;

  _MosaicoPainter({
    required this.rows,
    required this.cols,
    required this.animations,
  }) : super(repaint: Listenable.merge(animations));

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / cols;
    final cellHeight = size.height / rows;
    final paint = Paint()..color = Colors.black;

    for (int i = 0; i < animations.length; i++) {
      final row = i ~/ cols;
      final col = i % cols;
      final alpha = 1.0 - animations[i].value; // de 1 a 0
      if (alpha > 0) {
        paint.color = Colors.black.withValues(alpha: alpha);
        canvas.drawRect(
          Rect.fromLTWH(
            col * cellWidth,
            row * cellHeight,
            cellWidth,
            cellHeight,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MosaicoPainter oldDelegate) => true;
}
