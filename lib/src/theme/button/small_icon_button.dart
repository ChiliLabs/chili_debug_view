import 'package:flutter/material.dart';

class SmallIconButton extends StatelessWidget {
  final IconData? icon;
  final VoidCallback onTap;

  const SmallIconButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButtonTheme(
      data: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith<Color?>(
            (states) => states.contains(WidgetState.disabled) ||
                    states.contains(WidgetState.pressed)
                ? Colors.white24
                : Colors.white,
          ),
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (states) => Colors.transparent,
          ),
        ),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
