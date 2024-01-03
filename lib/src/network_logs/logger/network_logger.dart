import 'dart:async';
import 'dart:io';

import 'package:chili_debug_view/src/network_logs/model/network_log.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class NetworkLogger {
  static Map<String, NetworkLog> logs = <String, NetworkLog>{};
  static StreamController<List<NetworkLog>> logsStreamController =
      StreamController<List<NetworkLog>>();

  static File? _file;
  static String? _path;

  static File? getFile() => _file;

  static void log({
    required String id,
    required NetworkLog log,
  }) {
    _writeLogInFile(log);

    logs[id] = log;
    logsStreamController.add(logs.values.toList());
  }

  static void clearLogs() {
    logs = {};
    logsStreamController.add([]);
  }

  static void disposeListeners() {
    logsStreamController.close();
    logsStreamController = StreamController<List<NetworkLog>>();
  }

  static Future<void> _createFile() async {
    try {
      final directory = await getTemporaryDirectory();
      final name = 'network_logs_${DateTime.now().millisecondsSinceEpoch}.txt';
      final path = '${directory.path}/$name';
      _path = path;
      _file = File(path);
    } on Exception catch (ex, st) {
      debugPrintStack(
        label: 'Failed to create logs file: $ex',
        stackTrace: st,
      );
    }
  }

  static void _writeLogInFile(NetworkLog log) async {
    try {
      if (_path == null) {
        await _createFile();
      }
      _file?.writeAsStringSync(
        '${log.toString()}\n------------------------------------------------\n',
        mode: FileMode.append,
      );
    } on Exception catch (ex, st) {
      debugPrintStack(
        label: 'Failed to write network log in file: $ex',
        stackTrace: st,
      );
    }
  }
}
