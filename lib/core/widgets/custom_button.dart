import 'package:flutter/material.dart';

/// Highly customizable micro-animated button supporting loading states and outline styles.
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foregroundColor = isOutlined
        ? theme.colorScheme.primary
        : (theme.brightness == Brightness.light ? Colors.white : Colors.black);

    if (isOutlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: theme.colorScheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _buildContent(foregroundColor),
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: _buildContent(foregroundColor),
    );
  }

  Widget _buildContent(Color color) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: TextStyle(color: color),
        ),
      ],
    );
  }
}
