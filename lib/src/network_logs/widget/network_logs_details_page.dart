import 'package:chili_debug_view/src/network_logs/model/network_log.dart';
import 'package:chili_debug_view/src/share/share_provider.dart';
import 'package:chili_debug_view/src/theme/typography/app_typography.dart';
import 'package:chili_debug_view/src/time/time_provider.dart';
import 'package:flutter/cupertino.dart';
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
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();

    _controller = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    final responseTime = widget.log.responseTime;
    final statusCode = widget.log.statusCode;
    final requestBody = widget.log.requestBody;
    final responseBody = widget.log.responseBody;

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
      body: RawScrollbar(
        controller: _controller,
        interactive: true,
        thumbVisibility: true,
        trackVisibility: true,
        radius: Radius.circular(3),
        child: ListView(
          // Temporary workaround for scrollbar issue
          // https://github.com/flutter/flutter/issues/25652
          cacheExtent: 100000,
          controller: _controller,
          padding: const EdgeInsets.all(16),
          children: [
            _SimpleInfoItem(
              title: 'URL:',
              description: widget.log.uri,
            ),
            _SimpleInfoItem(
              title: 'Method:',
              description: widget.log.method,
            ),
            if (statusCode != null)
              _SimpleInfoItem(
                title: 'Status code:',
                description: statusCode.toString(),
              ),
            _SimpleInfoItem(
              title: 'Request date time:',
              description: widget.log.requestTime.toIso8601String(),
            ),
            if (responseTime != null) ...[
              _SimpleInfoItem(
                title: 'Response date time:',
                description: responseTime.toIso8601String(),
              ),
              _SimpleInfoItem(
                title: 'Response duration:',
                description: TimeProvider.prettyDuration(
                  responseTime.difference(widget.log.requestTime),
                ),
              ),
            ],
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(
                height: 1,
                color: Colors.grey,
              ),
            ),
            if (requestBody != null) ...[
              Text(
                'Request Headers:',
                style: AppTypography.bodyBold.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              ...widget.log.requestHeaders.entries.map<Widget>(
                (header) => SelectableText.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${header.key} ',
                        style: AppTypography.bodySemiBold.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: header.value,
                        style: AppTypography.body.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Request body',
                style: AppTypography.bodyBold.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              SelectableText(
                requestBody,
                style: AppTypography.body.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
            if (responseBody != null) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(
                  height: 1,
                  color: Colors.grey,
                ),
              ),
              Text(
                'Response Headers:',
                style: AppTypography.bodyBold.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              ...(widget.log.responseHeaders?.entries ?? {}).map<Widget>(
                (header) => SelectableText.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${header.key} ',
                        style: AppTypography.bodySemiBold.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: header.value,
                        style: AppTypography.body.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Response body',
                style: AppTypography.bodyBold.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              SelectableText(
                responseBody,
                style: AppTypography.body.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.log.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied to Clipboard'),
      ),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.bodyBold.copyWith(color: Colors.white),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: SelectableText(
              description,
              style: AppTypography.body.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
