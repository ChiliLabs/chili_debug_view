import 'package:chili_debug_view/src/theme/typography/app_typography.dart';
import 'package:flutter/material.dart';

class SmallTextButton extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const SmallTextButton({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => TextButtonTheme(
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
        child: TextButton(
          onPressed: onTap,
          child: Text(
            title,
            style: AppTypography.actionButton,
          ),
        ),
      );
}
