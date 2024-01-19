import 'dart:io';

import 'package:chili_debug_view/src/network_logs/model/network_log.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_native_log_handler/flutter_native_logs.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareProvider {
  static void shareNetworkLogs(List<NetworkLog> networkLogs) async {
    final file = await _writeNetworkLogsInFile(networkLogs);
    Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/*')],
      subject: 'Network logs',
      text: 'Network logs',
    );
  }

  static Future<void> shareConsoleLogs(
    List<NativeLogMessage> consoleLogs,
  ) async {
    final file = await _writeConsoleLogsInFile(consoleLogs);
    Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/*')],
      subject: 'Console logs',
      text: 'Console logs',
    );
  }

  static Future<File> _writeNetworkLogsInFile(List<NetworkLog> logs) async {
    try {
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
    } on Exception catch (ex, st) {
      debugPrintStack(
        label: 'Failed to write network log in file: $ex',
        stackTrace: st,
      );
      rethrow;
    }
  }

  static Future<File> _writeConsoleLogsInFile(
      List<NativeLogMessage> logs) async {
    try {
      final file = await _createFile('console_logs_');

      for (final log in logs) {
        file.writeAsStringSync(
          '${log.message}\n',
          mode: FileMode.append,
        );
      }

      return file;
    } on Exception catch (ex, st) {
      debugPrintStack(
        label: 'Failed to write console log in file: $ex',
        stackTrace: st,
      );
      rethrow;
    }
  }

  static Future<File> _createFile(String prefix) async {
    try {
      final directory = await getTemporaryDirectory();
      final name = '$prefix${DateTime.now().millisecondsSinceEpoch}.txt';
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
