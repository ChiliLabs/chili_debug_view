import 'package:chili_debug_view/src/network_logs/model/network_logger_log_type.dart';
import 'package:flutter/foundation.dart';

class NetworkLog {
  final DateTime time;
  final NetworkLoggerLogType type;
  final String uri;
  final String method;
  final int? statusCode;
  final String? requestBody;
  final String? responseBody;

  const NetworkLog({
    required this.time,
    required this.type,
    required this.uri,
    required this.method,
    this.statusCode,
    this.requestBody,
    this.responseBody,
  });

  NetworkLog copyWith({
    DateTime? time,
    NetworkLoggerLogType? type,
    String? uri,
    String? method,
    int? statusCode,
    String? requestBody,
    String? responseBody,
  }) =>
      NetworkLog(
        time: time ?? this.time,
        type: type ?? this.type,
        uri: uri ?? this.uri,
        method: method ?? this.method,
        statusCode: statusCode ?? this.statusCode,
        requestBody: requestBody ?? this.requestBody,
        responseBody: responseBody ?? this.responseBody,
      );

  @override
  String toString() {
    final statusCode = this.statusCode;
    final requestBody = this.requestBody;
    final responseBody = this.responseBody;

    var result = '';
    result += 'Uri: $uri\n';
    result += 'Type: ${describeEnum(type)}\n';
    result += 'Method: $method\n';
    result += 'Time: $time\n';

    if (statusCode != null) {
      result += 'Status code: $statusCode\n';
    }

    if (requestBody != null) {
      result += 'Request body: $requestBody\n';
    }

    if (responseBody != null) {
      result += 'Response body: $responseBody\n';
    }

    return result;
  }

  @override
  bool operator ==(Object other) =>
      other is NetworkLog &&
      other.time == time &&
      other.type == type &&
      other.uri == uri &&
      other.method == method &&
      other.statusCode == statusCode &&
      other.requestBody == requestBody &&
      other.responseBody == responseBody;

  @override
  int get hashCode => Object.hash(
        time,
        type,
        uri,
        method,
        statusCode,
        requestBody,
        responseBody,
      );
}
