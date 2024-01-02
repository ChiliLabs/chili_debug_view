import 'package:chili_debug_view/src/network_logs/model/network_log.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NetworkLogsDetailsPage extends StatelessWidget {
  final NetworkLog log;

  const NetworkLogsDetailsPage({
    Key? key,
    required this.log,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusCode = log.statusCode;
    final requestBody = log.requestBody;
    final responseBody = log.responseBody;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(describeEnum(log.type).toUpperCase()),
          const SizedBox(height: 16),
          Text(log.method),
          const SizedBox(height: 16),
          if (statusCode != null) ...[
            Text(statusCode.toString()),
            const SizedBox(height: 16),
          ],
          SelectableText(log.uri),
          const SizedBox(height: 16),
          const Divider(
            height: 1,
            color: Colors.grey,
          ),
          if (requestBody != null) ...[
            const SizedBox(height: 16),
            const Text('Request body'),
            const SizedBox(height: 16),
            SelectableText(requestBody),
            const SizedBox(height: 16),
            const Divider(
              height: 1,
              color: Colors.grey,
            ),
          ],
          if (responseBody != null) ...[
            const SizedBox(height: 16),
            const Text('Response body'),
            const SizedBox(height: 16),
            SelectableText(responseBody),
            const SizedBox(height: 16),
            const Divider(
              height: 1,
              color: Colors.grey,
            ),
          ],
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
