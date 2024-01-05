import 'dart:async';

import 'package:chili_debug_view/src/console_logs/logger/console_logger.dart';
import 'package:chili_debug_view/src/debug_view/widget/debug_console_page.dart';
import 'package:chili_debug_view/src/debug_view/widget/draggable_floating_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_log_handler/flutter_native_logs.dart';

const _buttonPadding = 80.0;

class DebugView extends StatefulWidget {
  final GlobalKey<NavigatorState>? navigatorKey;
  final bool showDebugViewButton;
  final Widget? app;

  const DebugView({
    super.key,
    required this.navigatorKey,
    required this.showDebugViewButton,
    required this.app,
  });

  @override
  State<DebugView> createState() => _DebugViewState();
}

class _DebugViewState extends State<DebugView> {
  final _showDebugButtonNotifier = ValueNotifier(true);
  final _flutterNativeLogsPlugin = FlutterNativeLogs();
  StreamSubscription<NativeLogMessage>? _logStreamSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _logStreamSubscription = _flutterNativeLogsPlugin.logStream.listen(
        ConsoleLogger.log,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.app;
    final viewPadding = MediaQuery.of(context).viewPadding;
    final safeAreaBottomPadding = viewPadding.bottom;

    return Theme(
      data: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF343434),
        primaryColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF343434),
          foregroundColor: Colors.white,
        ),
        useMaterial3: true,
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
      ),
      child: ValueListenableBuilder<bool>(
        valueListenable: _showDebugButtonNotifier,
        builder: (context, showDebugButton, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final horizontalOffset = constraints.maxWidth - _buttonPadding;
              final verticalOffset = constraints.maxHeight -
                  safeAreaBottomPadding -
                  _buttonPadding;

              return Stack(
                children: [
                  if (app != null) app,
                  if (widget.showDebugViewButton)
                    DraggableFloatingActionButton(
                      scaleFactor: showDebugButton ? 1 : 0,
                      topPadding: viewPadding.top,
                      bottomPadding: safeAreaBottomPadding,
                      width: constraints.maxWidth,
                      height: constraints.maxHeight - safeAreaBottomPadding,
                      initialOffset: Offset(horizontalOffset, verticalOffset),
                      onPressed: _onDebugButtonPressed(showDebugButton),
                      onError: (e) => debugPrint(
                        'Failed to init DraggableFloatingActionButton: $e',
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  VoidCallback? _onDebugButtonPressed(bool showDebugButton) {
    if (!showDebugButton) return null;

    return () => widget.navigatorKey?.currentState?.push(
          MaterialPageRoute(
            builder: (context) => DebugConsolePage(
              showDebugButtonNotifier: _showDebugButtonNotifier,
            ),
          ),
        );
  }

  @override
  void dispose() {
    super.dispose();
    _logStreamSubscription?.cancel();
  }
}
