import 'dart:async';

import 'package:flutter_native_log_handler/flutter_native_logs.dart';

class ConsoleLogger {
  static List<NativeLogMessage> logs = <NativeLogMessage>[];
  static StreamController<List<NativeLogMessage>> logsStreamController =
      StreamController<List<NativeLogMessage>>();

  static void log(
    NativeLogMessage message,
  ) {
    final logLevel = message.message.split(' ').elementAtOrNull(4) ?? '';
    logs.add(
      message.copyWith(
        level: message.level is NativeLogMessageLevelUnparsable
            ? NativeLogMessageLevel.parse(
                level: logLevel,
              )
            : message.level,
      ),
    );
    logsStreamController.add(logs);
  }

  static void clearLogs() {
    logs = [];
    logsStreamController.add(logs);
  }

  static void disposeListeners() {
    logsStreamController.close();
    logsStreamController = StreamController<List<NativeLogMessage>>();
  }
}
