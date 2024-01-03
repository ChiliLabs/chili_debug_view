import 'package:chili_debug_view/src/console_logs/widget/console_logs_page.dart';
import 'package:chili_debug_view/src/network_logs/widget/network_logs_page.dart';
import 'package:chili_debug_view/src/theme/typography/app_typography.dart';
import 'package:flutter/material.dart';

class DebugConsolePage extends StatefulWidget {
  final ValueNotifier<bool> showDebugButtonNotifier;

  const DebugConsolePage({
    super.key,
    required this.showDebugButtonNotifier,
  });

  @override
  State<DebugConsolePage> createState() => _DebugConsolePageState();
}

class _DebugConsolePageState extends State<DebugConsolePage> {
  @override
  void initState() {
    super.initState();

    _toggleShowDebugNotificationValue(false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'Debug console',
            style: AppTypography.headline,
          ),
        ),
        body: SafeArea(
          child: ListView(
            children: [
              const SizedBox(
                height: 16,
              ),
              _DebugViewItem(
                title: 'Network logs',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const NetworkLogsPage(),
                    ),
                  );
                },
              ),
              _DebugViewItem(
                title: 'Console logs',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ConsoleLogsPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );

  @override
  void dispose() {
    super.dispose();

    _toggleShowDebugNotificationValue(true);
  }

  void _toggleShowDebugNotificationValue(bool value) =>
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.showDebugButtonNotifier.value = value,
      );
}

class _DebugViewItem extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const _DebugViewItem({
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: TextButton(
          onPressed: onPressed,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color?>(
              (states) => Colors.white12,
            ),
            shape: MaterialStateProperty.resolveWith<OutlinedBorder?>(
              (state) => const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            overlayColor: MaterialStateProperty.resolveWith<Color?>(
              (states) {
                if (states.contains(MaterialState.pressed)) {
                  return Colors.white24;
                }

                return Colors.white12;
              },
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              title,
              style: AppTypography.title.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
}
