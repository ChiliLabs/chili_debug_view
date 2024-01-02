import 'dart:convert';

import 'package:chili_debug_view/src/network_logs/logger/network_logger.dart';
import 'package:chili_debug_view/src/network_logs/model/network_log.dart';
import 'package:chili_debug_view/src/network_logs/model/network_logger_log_type.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class NetworkLoggerInterceptor extends Interceptor {
  NetworkLoggerInterceptor();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    NetworkLogger.log(
      NetworkLog(
        time: DateTime.now(),
        type: NetworkLoggerLogType.request,
        uri: options.uri.toString(),
        method: options.method,
        requestBody: prettyJson(options.data),
      ),
    );

    handler.next(options);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    NetworkLogger.log(
      NetworkLog(
        time: DateTime.now(),
        type: NetworkLoggerLogType.response,
        uri: response.requestOptions.uri.toString(),
        method: response.requestOptions.method,
        statusCode: response.statusCode,
        requestBody: prettyJson(response.requestOptions.data),
        responseBody: prettyJson(response.data),
      ),
    );

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    NetworkLogger.log(
      NetworkLog(
        time: DateTime.now(),
        type: NetworkLoggerLogType.error,
        uri: err.requestOptions.uri.toString(),
        method: err.requestOptions.method,
        statusCode: err.response?.statusCode,
        responseBody: prettyJson(err.response?.data),
        requestBody: prettyJson(err.response?.requestOptions.data),
      ),
    );

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
