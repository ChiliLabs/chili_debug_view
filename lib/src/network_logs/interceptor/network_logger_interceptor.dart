import 'dart:convert';

import 'package:chili_debug_view/src/network_logs/logger/network_logger.dart';
import 'package:chili_debug_view/src/network_logs/model/network_log.dart';
import 'package:chili_debug_view/src/network_logs/model/network_logger_log_type.dart';
import 'package:chili_debug_view/src/uuid/uuid_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class NetworkLoggerInterceptor extends Interceptor {
  static const _idKey = 'id';

  NetworkLoggerInterceptor();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final requestId = UUIDProvider.generateId();

    NetworkLogger.log(
      id: requestId,
      log: NetworkLog(
        requestTime: DateTime.now(),
        type: NetworkLoggerLogType.started,
        uri: options.uri.toString(),
        method: options.method,
        requestHeaders: options.headers.map(
          (key, value) => MapEntry(key.toString(), value.toString()),
        ),
        requestBody: prettyJson(options.data),
      ),
    );

    final extra = {_idKey: requestId};
    options.extra.addAll(extra);

    handler.next(options);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    final requestId = response.requestOptions.extra[_idKey];
    final request = NetworkLogger.logs[requestId];

    if (request != null) {
      NetworkLogger.log(
        id: requestId,
        log: request.copyWith(
          responseTime: DateTime.now(),
          type: NetworkLoggerLogType.success,
          statusCode: response.statusCode,
          responseBody: prettyJson(response.data),
          responseHeaders: response.headers.map.map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          ),
        ),
      );
    }

    handler.next(response);
  }

  @override
  // Should support older versions
  // ignore: deprecated_member_use
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    final requestId = err.requestOptions.extra[_idKey];
    final request = NetworkLogger.logs[requestId];

    if (request != null) {
      NetworkLogger.log(
        id: requestId,
        log: request.copyWith(
          responseTime: DateTime.now(),
          type: NetworkLoggerLogType.error,
          statusCode: err.response?.statusCode,
          responseBody: prettyJson(err.response?.data),
          requestBody: prettyJson(err.response?.requestOptions.data),
          responseHeaders: err.response?.headers.map.map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          ),
        ),
      );
    }

    handler.next(err);
  }

  String prettyJson(dynamic json) {
    try {
      final spaces = ' ' * 4;
      final encoder = JsonEncoder.withIndent(spaces);
      return encoder.convert(json);
    } catch (ex, st) {
      debugPrintStack(
        label: 'Failed to stringify request body: $ex',
        stackTrace: st,
      );

      return json.toString();
    }
  }
}
