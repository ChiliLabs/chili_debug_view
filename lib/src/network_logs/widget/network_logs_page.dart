import 'dart:io';

import 'package:chili_debug_view/src/network_logs/logger/network_logger.dart';
import 'package:chili_debug_view/src/network_logs/model/network_log.dart';
import 'package:chili_debug_view/src/network_logs/model/network_logger_log_type.dart';
import 'package:chili_debug_view/src/network_logs/widget/network_logs_details_page.dart';
import 'package:chili_debug_view/src/theme/alert/adaptive_alert_dialog.dart';
import 'package:chili_debug_view/src/theme/typography/app_typography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class NetworkLogsPage extends StatefulWidget {
  const NetworkLogsPage({super.key});

  @override
  State<NetworkLogsPage> createState() => _NetworkLogsPageState();
}

class _NetworkLogsPageState extends State<NetworkLogsPage> {
  late final TextEditingController _filterTextController;
  late List<NetworkLog> _filteredLogs;

  @override
  void initState() {
    super.initState();

    _filterTextController = TextEditingController();
    _filteredLogs = NetworkLogger.logs.values.toList();

    NetworkLogger.logsStreamController.stream.listen((_) => _filterLogs());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'Network logs',
            style: AppTypography.headline,
          ),
          actions: [
            InkWell(
              onTap: _createShareFile,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.share),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: _onRemoveLogs,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.delete_forever),
              ),
            ),
            const SizedBox(width: 8),
          ],
          bottom: PreferredSize(
            preferredSize: const Size(double.infinity, 64),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                height: 54,
                child: TextFormField(
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
                        ? IconButton(
                            onPressed: _onSearchBarCancel,
                            icon: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.cancel_outlined,
                                color: Colors.white,
                              ),
                            ),
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

            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 4,
                horizontal: 16,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  ),
                  color: logTypeColor(item.type),
                ),
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => _onDetailsTap(item),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          describeEnum(item.type).toUpperCase(),
                          style: AppTypography.bodyBold,
                        ),
                        const SizedBox(height: 16),
                        Text(item.uri),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
          itemCount: _filteredLogs.length,
        ),
      );

  @override
  void dispose() {
    NetworkLogger.disposeListeners();
    super.dispose();
  }

  void _onSearchBarCancel() {
    _filteredLogs = NetworkLogger.logs.values.toList();
    _filterTextController.clear();
    setState(() {});
  }

  void _onRemoveLogs() {
    if (NetworkLogger.logs.isEmpty) return;

    final targetPlatform = Theme.of(context).platform;
    final alert = AdaptiveAlertDialog(targetPlatform);

    showAdaptiveDialog(
      context: context,
      builder: (context) => alert.build(
        context,
        title: 'Remove all network logs',
        description: 'Are you sure you want to remove all network logs?',
        buttonTitle: 'Remove',
        onButtonTap: () {
          NetworkLogger.clearLogs();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _filterLogs() {
    final filteredLogsByType = NetworkLogger.logs.values.where(
      (log) {
        final containsStatusCode = log.statusCode
            .toString()
            .toLowerCase()
            .contains(_filterTextController.text.toLowerCase());

        final containsUri = log.uri
            .toString()
            .toLowerCase()
            .contains(_filterTextController.text.toLowerCase());

        final containsMethod = log.method
            .toString()
            .toLowerCase()
            .contains(_filterTextController.text.toLowerCase());

        return containsStatusCode || containsUri || containsMethod;
      },
    ).toList();

    setState(() => _filteredLogs = filteredLogsByType);
  }

  void _onDetailsTap(NetworkLog log) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NetworkLogsDetailsPage(log: log),
      ),
    );
  }

  Color logTypeColor(NetworkLoggerLogType type) {
    switch (type) {
      case NetworkLoggerLogType.success:
        return Colors.green;
      case NetworkLoggerLogType.error:
        return Colors.red;
      case NetworkLoggerLogType.started:
        return Colors.blue;
    }
  }

  OutlineInputBorder get _border => const OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.white24,
          width: 0,
        ),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      );

  void _createShareFile() async {
    try {
      final file = NetworkLogger.getFile();
      if (file != null) {
        _shareFile(file);
      } else {
        final directory = await getTemporaryDirectory();
        final name =
            'network_logs_${DateTime.now().millisecondsSinceEpoch}.txt';
        final path = '${directory.path}/$name';
        final file = File(path);
        final logs = NetworkLogger.logs.values
            .map((e) => e.toString())
            .join('\n-----------------------\n');
        file.writeAsStringSync(logs);
        _shareFile(file);
      }
    } on Exception catch (ex, st) {
      debugPrintStack(
        label: 'Failed to share logs: $ex',
        stackTrace: st,
      );
    }
  }

  void _shareFile(File file) {
    Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/*')],
      subject: 'Network logs',
      text: 'Network logs',
    );
  }
}
