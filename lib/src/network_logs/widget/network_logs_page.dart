import 'package:chili_debug_view/src/network_logs/logger/network_logger.dart';
import 'package:chili_debug_view/src/network_logs/model/network_log.dart';
import 'package:chili_debug_view/src/network_logs/widget/network_logs_details_page.dart';
import 'package:chili_debug_view/src/network_logs/widget/network_logs_item.dart';
import 'package:chili_debug_view/src/network_logs/widget/network_logs_proxy_page.dart';
import 'package:chili_debug_view/src/share/share_provider.dart';
import 'package:chili_debug_view/src/theme/alert/adaptive_alert_dialog.dart';
import 'package:chili_debug_view/src/theme/animation/app_animations.dart';
import 'package:chili_debug_view/src/theme/button/small_icon_button.dart';
import 'package:chili_debug_view/src/theme/button/small_text_button.dart';
import 'package:chili_debug_view/src/theme/typography/app_typography.dart';
import 'package:flutter/material.dart';

class NetworkLogsPage extends StatefulWidget {
  final ValueNotifier<bool> showDebugButtonNotifier;
  final ValueChanged<String>? onProxySaved;
  final String? proxyUrl;

  const NetworkLogsPage({
    super.key,
    required this.showDebugButtonNotifier,
    this.onProxySaved,
    this.proxyUrl,
  });

  @override
  State<NetworkLogsPage> createState() => _NetworkLogsPageState();
}

class _NetworkLogsPageState extends State<NetworkLogsPage> {
  static const _toolbarHeight = 54.0;

  late final TextEditingController _filterTextController;
  late List<NetworkLog> _filteredLogs;
  late List<NetworkLog> _selectedLogs;

  var _isSelectableMode = false;

  @override
  void initState() {
    super.initState();

    _filterTextController = TextEditingController();
    _filteredLogs = List.of(NetworkLogger.logs.values.toList());
    _selectedLogs = [];

    NetworkLogger.logsStreamController.stream.listen((_) => _filterLogs());

    _toggleShowDebugNotificationValue(false);
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafeArea = MediaQuery.paddingOf(context).bottom;
    final selectedAll = _selectedLogs.length == _filteredLogs.length;
    final bottomBarHeight =
        _isSelectableMode ? _toolbarHeight + bottomSafeArea : 0.0;

    final onProxySavedUnwrapped = widget.onProxySaved;

    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: AnimatedContainer(
        curve: Curves.easeOut,
        duration: AppAnimations.defaultDuration,
        color: Colors.black26,
        height: bottomBarHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SmallTextButton(
                title: selectedAll ? 'Unselect all' : 'Select all',
                onTap: () => _onSelectAll(selectedAll),
              ),
              const Spacer(),
              SmallTextButton(
                title: 'Remove',
                onTap: _selectedLogs.isEmpty ? null : _onRemoveLogs,
              ),
              const SizedBox(width: 12),
              SmallTextButton(
                title: 'Export',
                onTap: _selectedLogs.isEmpty
                    ? null
                    : () => ShareProvider.shareNetworkLogs(_selectedLogs),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        title: const Text(
          'Network logs',
          style: AppTypography.headline,
        ),
        actions: [
          if (onProxySavedUnwrapped != null)
            SmallTextButton(
              title: 'Proxy',
              onTap: () => _onProxyTap(onProxySavedUnwrapped),
            ),
          const SizedBox(width: 8),
          SmallTextButton(
            title: _isSelectableMode ? 'Cancel' : 'Select',
            onTap: _onChangeSelectableMode,
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
                style: const TextStyle(color: Colors.white),
                controller: _filterTextController,
                onChanged: (_) => _filterLogs(),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  hintText: 'Search by url, status code, method',
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
        padding: const EdgeInsets.only(bottom: 100, top: 8),
        itemBuilder: (context, index) {
          final item = _filteredLogs.reversed.toList()[index];

          return NetworkLogsItem(
            item: item,
            isSelected: _selectedLogs.contains(item),
            isSelectableMode: _isSelectableMode,
            onTap: _isSelectableMode
                ? () => _onItemSelect(item)
                : () => _onDetailsTap(item),
          );
        },
        itemCount: _filteredLogs.length,
      ),
    );
  }

  @override
  void dispose() {
    NetworkLogger.disposeListeners();
    _toggleShowDebugNotificationValue(true);

    super.dispose();
  }

  void _toggleShowDebugNotificationValue(bool value) =>
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.showDebugButtonNotifier.value = value,
      );

  void _onSearchBarCancel() => setState(
        () {
          _filteredLogs = List.of(NetworkLogger.logs.values.toList());
          _filterTextController.clear();
        },
      );

  void _onSelectAll(bool selectedAll) => setState(
        () {
          selectedAll
              ? _selectedLogs = []
              : _selectedLogs = List.of(_filteredLogs);
        },
      );

  void _onChangeSelectableMode() => setState(
        () {
          _isSelectableMode = !_isSelectableMode;
          _selectedLogs = [];
        },
      );

  void _onItemSelect(NetworkLog item) => setState(
        () {
          if (_selectedLogs.contains(item)) {
            _selectedLogs.remove(item);
          } else {
            _selectedLogs.add(item);
          }
        },
      );

  void _onDetailsTap(NetworkLog log) => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => NetworkLogsDetailsPage(log: log),
        ),
      );

  void _onProxyTap(ValueChanged<String> onSaveProxy) =>
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => NetworkLogsProxyPage(
            onSaveProxy: onSaveProxy,
            proxyUrl: widget.proxyUrl,
          ),
        ),
      );

  void _onRemoveLogs() {
    if (NetworkLogger.logs.isEmpty) return;

    final targetPlatform = Theme.of(context).platform;
    final alert = AdaptiveAlertDialog(targetPlatform);

    showAdaptiveDialog(
      context: context,
      builder: (context) => alert.build(
        context,
        title: 'Remove selected network logs',
        description: 'Are you sure you want to remove selected network logs?',
        buttonTitle: 'Remove',
        onButtonTap: () {
          NetworkLogger.clearSelectedLogs(_selectedLogs);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _filterLogs() {
    final searchText = _filterTextController.text.toLowerCase();
    final filteredLogsByType = NetworkLogger.logs.values.where(
      (log) {
        final containsStatusCode =
            log.statusCode.toString().toLowerCase().contains(searchText);
        final containsUri =
            log.uri.toString().toLowerCase().contains(searchText);
        final containsMethod =
            log.method.toString().toLowerCase().contains(searchText);

        return containsStatusCode || containsUri || containsMethod;
      },
    ).toList();

    setState(() => _filteredLogs = List.of(filteredLogsByType));
  }

  OutlineInputBorder get _border => const OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.white24,
          width: 0,
        ),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      );
}
