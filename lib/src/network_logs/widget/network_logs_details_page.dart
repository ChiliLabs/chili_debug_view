import 'package:chili_debug_view/src/colored_json/colored_json.dart';
import 'package:chili_debug_view/src/network_logs/model/network_log.dart';
import 'package:chili_debug_view/src/share/share_provider.dart';
import 'package:chili_debug_view/src/theme/typography/app_typography.dart';
import 'package:chili_debug_view/src/time/time_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NetworkLogsDetailsPage extends StatefulWidget {
  final NetworkLog log;

  const NetworkLogsDetailsPage({
    Key? key,
    required this.log,
  }) : super(key: key);

  @override
  State<NetworkLogsDetailsPage> createState() => _NetworkLogsDetailsPageState();
}

class _NetworkLogsDetailsPageState extends State<NetworkLogsDetailsPage> {
  late final PageController _pageController;
  int _selectedTab = 0;
  static const _tabs = ['Overview', 'Request', 'Response'];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    setState(() => _selectedTab = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        title: const Text(
          'Log details',
          style: AppTypography.headline,
        ),
        actions: [
          InkWell(
            onTap: () => ShareProvider.shareSingleNetworkLog(widget.log),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.ios_share_rounded,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: _copyToClipboard,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.copy_rounded,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _TabSelector(
            tabs: _tabs,
            selectedIndex: _selectedTab,
            onTabSelected: _onTabSelected,
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _OverviewTab(log: widget.log),
                _RequestTab(
                  log: widget.log,
                  onCopyRequestBody: (requestBody) => _copyToClipboard(text: requestBody),
                ),
                _ResponseTab(
                  log: widget.log,
                  onCopyResponseBody: (responseBody) => _copyToClipboard(text: responseBody),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard({String? text}) {
    Clipboard.setData(ClipboardData(text: text ?? widget.log.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to Clipboard'),
      ),
    );
  }
}

class _TabSelector extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const _TabSelector({
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
          border: Border(
            bottom: BorderSide(color: Colors.white24, width: 1),
          ),
        ),
        child: Row(
          children: List.generate(tabs.length, (index) {
            final isSelected = index == selectedIndex;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTabSelected(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: AppTypography.bodySemiBold.copyWith(
                      color: isSelected ? Colors.white : Colors.grey,
                    ),
                    child: Text(
                      tabs[index],
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _ScrollableTab extends StatefulWidget {
  final List<Widget> children;

  const _ScrollableTab({required this.children});

  @override
  State<_ScrollableTab> createState() => _ScrollableTabState();
}

class _ScrollableTabState extends State<_ScrollableTab> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawScrollbar(
      controller: _controller,
      interactive: true,
      thumbVisibility: true,
      trackVisibility: true,
      radius: const Radius.circular(3),
      child: ListView(
        // Temporary workaround for scrollbar issue
        // https://github.com/flutter/flutter/issues/25652
        cacheExtent: 100000,
        controller: _controller,
        padding: const EdgeInsets.all(16),
        children: widget.children,
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final NetworkLog log;

  const _OverviewTab({required this.log});

  @override
  Widget build(BuildContext context) {
    final responseTime = log.responseTime;
    final statusCode = log.statusCode;

    return _ScrollableTab(
      children: [
        _SimpleInfoItem(title: 'URL', description: log.uri),
        _SimpleInfoItem(title: 'Method', description: log.method),
        if (statusCode != null)
          _SimpleInfoItem(
            title: 'Status code',
            description: statusCode.toString(),
          ),
        _SimpleInfoItem(
          title: 'Request date time',
          description: log.requestTime.toIso8601String(),
        ),
        if (responseTime != null) ...[
          _SimpleInfoItem(
            title: 'Response date time',
            description: responseTime.toIso8601String(),
          ),
          _SimpleInfoItem(
            title: 'Response duration',
            description: TimeProvider.prettyDuration(
              responseTime.difference(log.requestTime),
            ),
          ),
        ],
        const SizedBox(height: 100),
      ],
    );
  }
}

class _RequestTab extends StatelessWidget {
  final NetworkLog log;
  final Function(String) onCopyRequestBody;

  const _RequestTab({
    required this.log,
    required this.onCopyRequestBody,
  });

  @override
  Widget build(BuildContext context) {
    final requestBody = log.requestBody;
    final headers = log.requestHeaders.entries;

    return _ScrollableTab(
      children: [
        Text(
          'Headers:',
          style: AppTypography.headline.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 8),
        if (headers.isNotEmpty)
          ...log.requestHeaders.entries.map<Widget>(
            (header) => SelectableText.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${header.key}\n',
                    style: AppTypography.title.copyWith(color: Colors.white),
                  ),
                  TextSpan(
                    text: header.value,
                    style: AppTypography.body.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          )
        else
          Text(
            'No request headers',
            style: AppTypography.body.copyWith(color: Colors.grey),
          ),
        const SizedBox(height: 24),
        Row(
          children: [
            Text(
              'Body:',
              style: AppTypography.headline.copyWith(color: Colors.white),
            ),
            if (requestBody != null && requestBody != 'null') ...[
              const Spacer(),
              _CopyButton(onPressed: () => onCopyRequestBody(requestBody)),
            ]
          ],
        ),
        const SizedBox(height: 8),
        if (requestBody != null && requestBody != 'null')
          _ColoredJson(jsonData: requestBody)
        else
          Text(
            'No request body',
            style: AppTypography.body.copyWith(color: Colors.grey),
          ),
        const SizedBox(height: 100),
      ],
    );
  }
}

class _ResponseTab extends StatelessWidget {
  final NetworkLog log;
  final Function(String) onCopyResponseBody;

  const _ResponseTab({
    required this.log,
    required this.onCopyResponseBody,
  });

  @override
  Widget build(BuildContext context) {
    final responseBody = log.responseBody;
    final headers = log.responseHeaders?.entries ?? {};

    return _ScrollableTab(
      children: [
        Text(
          'Headers:',
          style: AppTypography.headline.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 8),
        if (headers.isNotEmpty)
          ...(log.responseHeaders?.entries ?? {}).map<Widget>(
            (header) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: SelectableText.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${header.key}\n',
                      style: AppTypography.title.copyWith(color: Colors.white),
                    ),
                    TextSpan(
                      text: header.value,
                      style: AppTypography.body.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Text(
            'No response headers',
            style: AppTypography.body.copyWith(color: Colors.grey),
          ),
        const SizedBox(height: 24),
        Row(
          children: [
            Text(
              'Body:',
              style: AppTypography.headline.copyWith(color: Colors.white),
            ),
            if (responseBody != null && responseBody != 'null') ...[
              const Spacer(),
              _CopyButton(onPressed: () => onCopyResponseBody(responseBody)),
            ]
          ],
        ),
        const SizedBox(height: 8),
        if (responseBody != null && responseBody != 'null')
          _ColoredJson(jsonData: responseBody)
        else
          Text(
            'No response body',
            style: AppTypography.body.copyWith(color: Colors.grey),
          ),
        const SizedBox(height: 100),
      ],
    );
  }
}

class _SimpleInfoItem extends StatelessWidget {
  final String title;
  final String description;

  const _SimpleInfoItem({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.title.copyWith(color: Colors.white),
          ),
          SelectableText(
            description,
            style: AppTypography.body.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _CopyButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CopyButton({required this.onPressed});

  @override
  Widget build(BuildContext context) => MaterialButton(
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
        child: Row(
          children: [
            Icon(Icons.copy_rounded, size: 16, color: Colors.black),
            SizedBox(width: 4),
            Text(
              'Copy',
              style: AppTypography.bodySemiBold.copyWith(color: Colors.black),
            ),
          ],
        ),
        color: Colors.white,
        onPressed: onPressed,
      );
}

class _ColoredJson extends StatelessWidget {
  final String jsonData;

  const _ColoredJson({required this.jsonData});

  @override
  Widget build(BuildContext context) => ColoredJson(
        data: jsonData,
        backgroundColor: Colors.transparent,
        keyColor: Colors.blueAccent,
        curlyBracketColor: Colors.white,
        squareBracketColor: Colors.white,
        boolColor: Colors.cyan,
        stringColor: Colors.deepOrangeAccent,
        intColor: Colors.green,
        colonColor: Colors.white,
        commaColor: Colors.white,
        textStyle: AppTypography.body.copyWith(color: Colors.white),
      );
}
