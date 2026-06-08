import 'package:flutter/material.dart';
import '../utils/currency_formatter.dart';

/// Animated currency counter that counts up from 0 to [targetAmount].
class AnimatedCounter extends StatelessWidget {
  final double targetAmount;
  final TextStyle? style;
  final Duration duration;

  const AnimatedCounter({
    super.key,
    required this.targetAmount,
    this.style,
    this.duration = const Duration(milliseconds: 1400),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: targetAmount),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Text(
          CurrencyFormatter.format(value),
          style: style,
        );
      },
    );
  }
}
