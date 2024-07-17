import 'dart:io';

import 'package:chili_debug_view/src/network_logs/model/network_log.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareProvider {
  static void shareNetworkLogs(List<NetworkLog> networkLogs) async {
    try {
      final file = await _writeNetworkLogsInFile(networkLogs);
      Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/*')],
        subject: 'Network logs',
        text: 'Network logs',
      );
    } on Exception catch (ex, st) {
      debugPrintStack(
        label: 'Failed to write network logs in file: $ex',
        stackTrace: st,
      );
    }
  }

  static void shareSingleNetworkLog(NetworkLog log) async {
    try {
      final file = await _createFile('network_log_');
      file.writeAsStringSync(
        log.toString(),
        mode: FileMode.append,
      );
      Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/*')],
        subject: 'Network logs',
        text: 'Network logs',
      );
    } on Exception catch (ex, st) {
      debugPrintStack(
        label: 'Failed to write single network log in fileL $ex',
        stackTrace: st,
      );
    }
  }

  static Future<File> _writeNetworkLogsInFile(List<NetworkLog> logs) async {
    final file = await _createFile('network_logs_');
    final sortedLogs = <NetworkLog>[];
    sortedLogs.addAll(logs);
    sortedLogs.sort((a, b) => b.requestTime.compareTo(a.requestTime));

    for (final log in sortedLogs) {
      file.writeAsStringSync(
        '${log.toString()}\n------------------------------------------------\n',
        mode: FileMode.append,
      );
    }

    return file;
  }

  static Future<File> _createFile(String prefix) async {
    final directory = await getTemporaryDirectory();
    final name = '$prefix${DateTime.now().millisecondsSinceEpoch}.txt';
    final path = '${directory.path}/$name';
    final file = File(path);

    return file;
  }
}
