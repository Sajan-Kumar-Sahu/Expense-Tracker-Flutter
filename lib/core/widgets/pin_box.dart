import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PinBox extends StatelessWidget {
  final bool isFilled;
  final bool isActive;
  final bool hasError;

  const PinBox({
    super.key,
    required this.isFilled,
    required this.isActive,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color borderColor;

    if (hasError) {
      borderColor = theme.colorScheme.error;
    } else if (isActive) {
      borderColor = theme.colorScheme.primary;
    } else {
      borderColor = theme.colorScheme.outline.withValues(alpha: .35);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: 46.w,
      height: 52.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: borderColor,
          width: isActive ? 2 : 1.2,
        ),
        boxShadow: [
          if (isActive)
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: .18),
              blurRadius: 16,
              spreadRadius: 1,
            ),
        ],
      ),
      alignment: Alignment.center,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween(begin: .7, end: 1.0).animate(animation),
              child: child,
            ),
          );
        },
        child: isFilled
            ? Container(
          key: const ValueKey("filled"),
          width: 9.r,
          height: 9.r,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface,
            shape: BoxShape.circle,
          ),
        )
            : const SizedBox(
          key: ValueKey("empty"),
        ),
      ),
    )
        .animate(target: isActive ? 1 : 0)
        .scale(
      begin: const Offset(.98, .98),
      end: const Offset(1.03, 1.03),
      duration: 180.ms,
    );
  }
}