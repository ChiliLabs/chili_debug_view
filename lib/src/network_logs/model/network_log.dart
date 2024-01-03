import 'package:chili_debug_view/src/network_logs/model/network_logger_log_type.dart';
import 'package:chili_debug_view/src/time/time_provider.dart';

class NetworkLog {
  final NetworkLoggerLogType type;
  final String uri;
  final String method;
  final DateTime requestTime;
  final DateTime? responseTime;
  final Map<String, String> requestHeaders;
  final Map<String, String>? responseHeaders;
  final int? statusCode;
  final String? requestBody;
  final String? responseBody;

  const NetworkLog({
    required this.type,
    required this.uri,
    required this.method,
    required this.requestTime,
    required this.requestHeaders,
    this.requestBody,
    this.statusCode,
    this.responseTime,
    this.responseHeaders,
    this.responseBody,
  });

  NetworkLog copyWith({
    NetworkLoggerLogType? type,
    String? uri,
    String? method,
    DateTime? requestTime,
    DateTime? responseTime,
    Map<String, String>? requestHeaders,
    Map<String, String>? responseHeaders,
    int? statusCode,
    String? requestBody,
    String? responseBody,
  }) =>
      NetworkLog(
        type: type ?? this.type,
        uri: uri ?? this.uri,
        method: method ?? this.method,
        requestTime: requestTime ?? this.requestTime,
        responseTime: responseTime ?? this.responseTime,
        requestHeaders: requestHeaders ?? this.requestHeaders,
        responseHeaders: responseHeaders ?? this.responseHeaders,
        statusCode: statusCode ?? this.statusCode,
        requestBody: requestBody ?? this.requestBody,
        responseBody: responseBody ?? this.responseBody,
      );

  @override
  String toString() {
    final statusCode = this.statusCode;
    final requestBody = this.requestBody;
    final responseBody = this.responseBody;
    final responseTime = this.responseTime;

    var result = '';
    result += 'Uri: $uri\n';
    result += 'Type: ${type.name}\n';
    result += 'Method: $method\n';
    result += 'Request date time: $requestTime\n';

    if (responseTime != null) {
      result += 'Response date time: $responseTime\n';
      result += 'Response duration: ${TimeProvider.prettyDuration(
        responseTime.difference(requestTime),
      )}\n';
    }

    if (statusCode != null) {
      result += 'Status code: $statusCode\n';
    }

    if (requestHeaders.isNotEmpty) {
      result += 'Request headers:\n';
      requestHeaders.forEach((key, value) {
        result += '$key: $value\n';
      });
    }

    if (requestBody != null) {
      result += 'Request body: $requestBody\n';
    }

    if (responseHeaders?.isNotEmpty == true) {
      result += 'Response headers:\n';
      responseHeaders?.forEach((key, value) {
        result += '$key: $value\n';
      });
    }

    if (responseBody != null) {
      result += 'Response body: $responseBody\n';
    }

    return result;
  }

  @override
  bool operator ==(Object other) =>
      other is NetworkLog &&
      other.type == type &&
      other.uri == uri &&
      other.method == method &&
      other.requestTime == requestTime &&
      other.responseTime == responseTime &&
      other.requestHeaders == requestHeaders &&
      other.responseHeaders == responseHeaders &&
      other.statusCode == statusCode &&
      other.requestBody == requestBody &&
      other.responseBody == responseBody;

  @override
  int get hashCode => Object.hash(
        type,
        uri,
        method,
        requestTime,
        responseTime,
        requestHeaders,
        responseHeaders,
        statusCode,
        requestBody,
        responseBody,
      );
}
