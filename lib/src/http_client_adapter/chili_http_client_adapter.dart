import 'dart:io';

import 'package:dio/io.dart';

final class ChiliHttpClientAdapter extends IOHttpClientAdapter {
  ChiliHttpClientAdapter({String? proxyUrl})
      : super(
          createHttpClient: () => HttpClient()
            ..badCertificateCallback =
                ((X509Certificate cert, String host, int port) => true)
            ..findProxy = proxyUrl == null || proxyUrl.isEmpty
                ? null
                : (uri) => 'PROXY $proxyUrl',
        );
}
