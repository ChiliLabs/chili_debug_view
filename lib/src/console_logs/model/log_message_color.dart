import 'package:flutter/material.dart';
import 'package:flutter_native_log_handler/flutter_native_logs.dart';

extension LogMessageColor on NativeLogMessageLevel {
  Color get getColor {
    if (this is NativeLogMessageLevelDebug) return Colors.grey;
    if (this is NativeLogMessageLevelError) return Colors.red;
    if (this is NativeLogMessageLevelWarning) return Colors.yellow;
    if (this is NativeLogMessageLevelInformation) return Colors.black;
    return Colors.transparent;
  }
}
