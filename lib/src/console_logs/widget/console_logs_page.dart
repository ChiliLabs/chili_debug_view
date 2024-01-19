import 'package:chili_debug_view/src/console_logs/logger/console_logger.dart';
import 'package:chili_debug_view/src/console_logs/model/log_message_color.dart';
import 'package:chili_debug_view/src/share/share_provider.dart';
import 'package:chili_debug_view/src/theme/alert/adaptive_alert_dialog.dart';
import 'package:chili_debug_view/src/theme/animation/app_animations.dart';
import 'package:chili_debug_view/src/theme/button/small_icon_button.dart';
import 'package:chili_debug_view/src/theme/button/small_text_button.dart';
import 'package:chili_debug_view/src/theme/typography/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_log_handler/flutter_native_logs.dart';

const _toolbarHeight = 54.0;

class ConsoleLogsPage extends StatefulWidget {
  const ConsoleLogsPage({super.key});

  @override
  State<ConsoleLogsPage> createState() => _ConsoleLogsPageState();
}

class _ConsoleLogsPageState extends State<ConsoleLogsPage> {
  late List<NativeLogMessage> _filteredLogs;
  late final ScrollController _scrollController;
  late final TextEditingController _filterTextController;
  var _follow = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _filterTextController = TextEditingController();
    _filteredLogs = ConsoleLogger.logs;
    ConsoleLogger.logsStreamController.stream.listen((_) => _filterLogs());
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafeArea = MediaQuery.paddingOf(context).bottom;
    final bottomBarHeight = _toolbarHeight + bottomSafeArea;

    return Scaffold(
      bottomNavigationBar: AnimatedContainer(
        curve: Curves.easeOut,
        duration: AppAnimations.defaultDuration,
        color: Colors.black26,
        height: bottomBarHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SmallTextButton(
                title: 'To bottom',
                onTap: _filteredLogs.isEmpty ? null : _scrollToBottom,
              ),
              SmallTextButton(
                title: 'Export',
                onTap: _filteredLogs.isEmpty
                    ? null
                    : () => ShareProvider.shareConsoleLogs(_filteredLogs),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text(
          'Console logs',
          style: AppTypography.headline,
        ),
        actions: [
          SmallTextButton(
            title: 'Follow',
            onTap: () => setState(() {
              _follow = !_follow;
            }),
          ),
          SmallTextButton(
            title: 'Remove',
            onTap: _onRemoveLogs,
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size(double.infinity, _toolbarHeight),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: SizedBox(
              height: _toolbarHeight,
              child: TextFormField(
                controller: _filterTextController,
                onChanged: (_) => _filterLogs(),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  hintText: 'Search',
                  hintStyle: const TextStyle(color: Colors.white54),
                  focusedBorder: _border,
                  enabledBorder: _border,
                  border: _border,
                  suffixIcon: _filterTextController.text.isNotEmpty
                      ? SmallIconButton(
                          icon: Icons.cancel_outlined,
                          onTap: _onSearchBarCancel,
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: _filteredLogs.length,
        itemBuilder: (context, index) {
          final message = _filteredLogs[index];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            color: message.level.getColor,
            child: Text(
              message.message,
            ),
          );
        },
      ),
    );
  }

  OutlineInputBorder get _border => const OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.white24,
          width: 0,
        ),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      );

  void _filterLogs() {
    var filteredLogs = ConsoleLogger.logs;

    if (_filterTextController.text.isNotEmpty) {
      filteredLogs = ConsoleLogger.logs
          .where(
            (message) => message.message
                .toLowerCase()
                .contains(_filterTextController.text.toLowerCase()),
          )
          .toList();
    }
    setState(() => _filteredLogs = filteredLogs);
    if (_follow) _scrollToBottom();
  }

  void _onSearchBarCancel() => setState(
        () {
          _filteredLogs = ConsoleLogger.logs;
          _filterTextController.clear();
        },
      );

  void _scrollToBottom() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  void _onRemoveLogs() {
    if (ConsoleLogger.logs.isEmpty) return;

    final targetPlatform = Theme.of(context).platform;
    final alert = AdaptiveAlertDialog(targetPlatform);

    showAdaptiveDialog(
      context: context,
      builder: (context) => alert.build(
        context,
        title: 'Remove all console logs',
        description: 'Are you sure you want to remove all console logs?',
        buttonTitle: 'Remove',
        onButtonTap: () {
          ConsoleLogger.clearLogs();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  void dispose() {
    ConsoleLogger.disposeListeners();
    _scrollController.dispose();
    _filterTextController.dispose();
    super.dispose();
  }
}
