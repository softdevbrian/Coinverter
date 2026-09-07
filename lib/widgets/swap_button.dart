import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';

/// An animated circular swap button that rotates 180° on each tap.
/// Uses the dynamic color palette from [ThemeProvider].
class SwapButton extends StatefulWidget {
  final VoidCallback onTap;

  const SwapButton({super.key, required this.onTap});

  @override
  State<SwapButton> createState() => _SwapButtonState();
}

class _SwapButtonState extends State<SwapButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: kAnimDurationMedium,
      vsync: this,
    );
    _rotation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.85), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward(from: 0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<ThemeProvider>().palette;
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: Transform.rotate(
            angle: _rotation.value * 2 * 3.14159,
            child: child,
          ),
        ),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [palette.primary, palette.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: palette.primary.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.swap_vert_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }
}
