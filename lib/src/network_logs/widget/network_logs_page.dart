import 'dart:io';

import 'package:chili_debug_view/src/network_logs/logger/network_logger.dart';
import 'package:chili_debug_view/src/network_logs/model/network_log.dart';
import 'package:chili_debug_view/src/network_logs/model/network_logger_log_type.dart';
import 'package:chili_debug_view/src/network_logs/widget/log_type_cell.dart';
import 'package:chili_debug_view/src/network_logs/widget/network_logs_details_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class NetworkLogsPage extends StatefulWidget {
  const NetworkLogsPage({Key? key}) : super(key: key);

  @override
  State<NetworkLogsPage> createState() => _NetworkLogsPageState();
}

class _NetworkLogsPageState extends State<NetworkLogsPage> {
  final _filterTextController = TextEditingController();
  late List<NetworkLog> _filteredLogs;
  var _selectedLogTypes = <NetworkLoggerLogType>{};

  @override
  void initState() {
    super.initState();
    _filteredLogs = NetworkLogger.logs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network logs'),
        actions: [
          InkWell(
            onTap: _createShareFile,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.share),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _filteredLogs = NetworkLogger.logs;
          _filterTextController.clear();
          _selectedLogTypes = {};
          setState(() {});
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: NetworkLoggerLogType.values.length,
                  itemBuilder: (context, index) {
                    final type = NetworkLoggerLogType.values[index];
                    final isSelected = _selectedLogTypes.contains(type);

                    return LogTypeCell(
                      type: type,
                      isSelected: isSelected,
                      onLevelSelect: () => _filterLogs(type),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextFormField(
                controller: _filterTextController,
                onChanged: (_) => _filterLogs(null),
                decoration: const InputDecoration(
                  hintText: 'Search',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemBuilder: (context, index) {
                  final item = _filteredLogs[index];
                  final statusCode = item.statusCode;

                  return GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => _onDetailsTap(item),
                    child: Container(
                      color: logTypeColor(item.type),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(describeEnum(item.type).toUpperCase()),
                            const SizedBox(height: 16),
                            Text(item.method),
                            const SizedBox(height: 16),
                            if (statusCode != null) ...[
                              Text(statusCode.toString()),
                              const SizedBox(height: 16),
                            ],
                            Text(item.uri),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => const Divider(
                  height: 9,
                  thickness: 1,
                  color: Colors.grey,
                ),
                itemCount: _filteredLogs.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _filterLogs(NetworkLoggerLogType? type) {
    // Updated selected log types set.
    if (type != null) {
      final containsLevel = _selectedLogTypes.contains(type);
      if (containsLevel) {
        _selectedLogTypes.remove(type);
      } else {
        _selectedLogTypes.add(type);
      }
    }

    // Add all selected log types logs.
    final filteredLogsByType = NetworkLogger.logs.where(
      (log) {
        final containsLevel = log.type.containsLevel(_selectedLogTypes);
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

        return containsLevel &&
            (containsStatusCode || containsUri || containsMethod);
      },
    ).toList();

    // Update state.
    setState(() {
      _filteredLogs = filteredLogsByType;
    });
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
      case NetworkLoggerLogType.response:
        return Colors.lightGreen;
      case NetworkLoggerLogType.error:
        return Colors.redAccent;
      case NetworkLoggerLogType.request:
        return Colors.lightBlueAccent;
    }
  }

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
        final logs = NetworkLogger.logs
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
