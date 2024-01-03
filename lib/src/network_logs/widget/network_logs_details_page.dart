import 'package:chili_debug_view/src/network_logs/model/network_log.dart';
import 'package:chili_debug_view/src/theme/typography/app_typography.dart';
import 'package:chili_debug_view/src/time/time_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NetworkLogsDetailsPage extends StatelessWidget {
  final NetworkLog log;

  const NetworkLogsDetailsPage({
    Key? key,
    required this.log,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responseTime = log.responseTime;
    final statusCode = log.statusCode;
    final requestBody = log.requestBody;
    final responseBody = log.responseBody;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Log details',
          style: AppTypography.headline,
        ),
        actions: [
          InkWell(
            onTap: _copyToClipboard,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.copy,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SimpleInfoItem(
            title: 'URL:',
            description: log.uri,
          ),
          _SimpleInfoItem(
            title: 'Method:',
            description: log.method,
          ),
          if (statusCode != null)
            _SimpleInfoItem(
              title: 'Status code:',
              description: statusCode.toString(),
            ),
          _SimpleInfoItem(
            title: 'Request date time:',
            description: log.requestTime.toIso8601String(),
          ),
          if (responseTime != null) ...[
            _SimpleInfoItem(
              title: 'Response date time:',
              description: responseTime.toIso8601String(),
            ),
            _SimpleInfoItem(
              title: 'Response duration:',
              description: TimeProvider.prettyDuration(
                responseTime.difference(log.requestTime),
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
            const Text(
              'Request Headers:',
              style: AppTypography.bodyBold,
            ),
            const SizedBox(height: 16),
            ...log.requestHeaders.entries
                .map<Widget>(
                  (header) => SelectableText.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${header.key} ',
                          style: AppTypography.bodySemiBold,
                        ),
                        TextSpan(
                          text: header.value,
                          style: AppTypography.body,
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
            const SizedBox(height: 16),
            const Text(
              'Request body',
              style: AppTypography.bodyBold,
            ),
            const SizedBox(height: 16),
            SelectableText(
              requestBody,
              style: AppTypography.body,
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
            const Text(
              'Response Headers:',
              style: AppTypography.bodyBold,
            ),
            const SizedBox(height: 16),
            ...(log.responseHeaders?.entries ?? {})
                .map<Widget>(
                  (header) => SelectableText.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${header.key} ',
                          style: AppTypography.bodySemiBold,
                        ),
                        TextSpan(
                          text: header.value,
                          style: AppTypography.body,
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
            const SizedBox(height: 16),
            const Text(
              'Response body',
              style: AppTypography.bodyBold,
            ),
            const SizedBox(height: 16),
            SelectableText(
              responseBody,
              style: AppTypography.body,
            ),
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: log.toString()));
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
            style: AppTypography.bodyBold,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: SelectableText(
              description,
              style: AppTypography.body,
            ),
          ),
        ],
      ),
    );
  }
}
