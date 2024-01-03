import 'dart:async';
import 'package:chili_debug_view/src/network_logs/model/network_log.dart';

class NetworkLogger {
  static Map<String, NetworkLog> logs = <String, NetworkLog>{};
  static StreamController<List<NetworkLog>> logsStreamController =
      StreamController<List<NetworkLog>>();

  static void log({
    required String id,
    required NetworkLog log,
  }) {
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
}
