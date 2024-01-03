import 'dart:io';

import 'package:chili_debug_view/src/network_logs/model/network_log.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareProvider {
  static void share(List<NetworkLog> logs) async {
    final file = await _writeLogsInFile(logs);
    Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/*')],
      subject: 'Network logs',
      text: 'Network logs',
    );
  }

  static Future<File> _writeLogsInFile(List<NetworkLog> logs) async {
    try {
      final file = await _createFile();
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
    } on Exception catch (ex, st) {
      debugPrintStack(
        label: 'Failed to write network log in file: $ex',
        stackTrace: st,
      );
      rethrow;
    }
  }

  static Future<File> _createFile() async {
    try {
      final directory = await getTemporaryDirectory();
      final name = 'network_logs_${DateTime.now().millisecondsSinceEpoch}.txt';
      final path = '${directory.path}/$name';
      final file = File(path);

      return file;
    } on Exception catch (ex, st) {
      debugPrintStack(
        label: 'Failed to create logs file: $ex',
        stackTrace: st,
      );
      rethrow;
    }
  }
}