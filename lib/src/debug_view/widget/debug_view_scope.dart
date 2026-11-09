import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Gives a debug screen its own localizations and [ScaffoldMessenger].
///
/// The host app may use either `package:flutter/material.dart` or
/// `package:material_ui`. Widgets from one library do not see the ancestors
/// the other one's `MaterialApp` provides, so debug screens must not rely on
/// the host for them.
class DebugViewScope extends StatelessWidget {
  final Widget child;

  const DebugViewScope({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Localizations(
        locale: const Locale('en'),
        delegates: const [
          DefaultWidgetsLocalizations.delegate,
          DefaultMaterialLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
        ],
        child: ScaffoldMessenger(child: child),
      );
}
