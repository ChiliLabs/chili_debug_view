import 'package:chili_debug_view/src/console_logs/widget/console_logs_page.dart';
import 'package:chili_debug_view/src/network_logs/widget/network_logs_page.dart';
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
          title: const Text('Debug console'),
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
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 8,
              ),
              width: double.infinity,
              child: TextButton(
                onPressed: onPressed,
                child: Text(title),
              ),
            ),
          ),
        ],
      );
}
