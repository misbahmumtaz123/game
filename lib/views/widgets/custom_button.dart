import 'package:flutter/material.dart';

/// Interactive button with smooth press animations, gradients, and elevation.
class CustomButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? textColor;
  final List<Color>? gradientColors;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const CustomButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.textColor,
    this.gradientColors,
    this.fontSize = 20.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 42.0, vertical: 15.0),
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32.0),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors:
                  widget.gradientColors ??
                  const [Colors.white, Color(0xFFECEFF1)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(50),
                blurRadius: _isPressed ? 6.0 : 14.0,
                offset: Offset(0, _isPressed ? 3.0 : 7.0),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: widget.textColor, size: 22.0),
                const SizedBox(width: 8.0),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.textColor ?? const Color(0xFF1E293B),
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
