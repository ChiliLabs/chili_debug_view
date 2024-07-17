import 'package:chili_debug_view/src/debug_view/widget/draggable_floating_action_button.dart';
import 'package:chili_debug_view/src/network_logs/widget/network_logs_page.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final app = widget.app;
    final viewPadding = MediaQuery.paddingOf(context);
    final safeAreaBottomPadding = viewPadding.bottom;
    const buttonPadding = 80.0;

    return ValueListenableBuilder<bool>(
      valueListenable: _showDebugButtonNotifier,
      builder: (_, showDebugButton, __) {
        return LayoutBuilder(
          builder: (_, constraints) {
            final horizontalOffset = constraints.maxWidth - buttonPadding;
            final verticalOffset =
                constraints.maxHeight - safeAreaBottomPadding - buttonPadding;

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
    );
  }

  VoidCallback? _onDebugButtonPressed(bool showDebugButton) {
    if (!showDebugButton) return null;

    return () => widget.navigatorKey?.currentState?.push(
          MaterialPageRoute(
            builder: (context) => NetworkLogsPage(
              showDebugButtonNotifier: _showDebugButtonNotifier,
            ),
          ),
        );
  }
}
