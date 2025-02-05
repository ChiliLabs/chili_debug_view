import 'dart:math';

import 'package:chili_debug_view/chili_debug_view.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dioFactory = DioFactory();
  final spaceFlightNewsDio = await dioFactory.create(
    baseUrl: 'https://api.spaceflightnewsapi.net/v4',
    isDebugViewEnabled: true,
  );
  final apiClient = ApiClient(dio: spaceFlightNewsDio);

  runApp(
    App(apiClient: apiClient),
  );
}

class App extends StatefulWidget {
  final ApiClient apiClient;

  const App({
    super.key,
    required this.apiClient,
  });

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final rootKey = GlobalKey<NavigatorState>();
  String? _proxyUrl;

  @override
  void initState() {
    super.initState();
    _getProxy();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: rootKey,
      builder: (_, app) {
        return DebugView(
          navigatorKey: rootKey,
          showDebugViewButton: true,
          onProxySaved: _onSaveProxy,
          proxyUrl: _proxyUrl,
          app: app,
        );
      },
      onGenerateRoute: (_) {
        return MaterialPageRoute(
          builder: (_) => HomePage(
            apiClient: widget.apiClient,
          ),
        );
      },
    );
  }

  void _getProxy() async {
    final prefs = await SharedPreferences.getInstance();
    _proxyUrl = prefs.getString('proxyUrl');
  }

  void _onSaveProxy(String url) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('proxyUrl', url);
    _proxyUrl = url;
  }
}

class HomePage extends StatefulWidget {
  final ApiClient apiClient;

  const HomePage({
    super.key,
    required this.apiClient,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () => widget.apiClient.makeSimpleRequest(
            Random().nextInt(100),
          ),
          child: const Text('Make simple request'),
        ),
      ),
    );
  }
}

class DioFactory {
  Future<Dio> create({
    required String baseUrl,
    required bool isDebugViewEnabled,
  }) async {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        responseType: ResponseType.json,
        headers: {
          Headers.acceptHeader: Headers.jsonContentType,
          Headers.contentTypeHeader: Headers.jsonContentType,
        },
      ),
    );

    if (isDebugViewEnabled) {
      final prefs = await SharedPreferences.getInstance();

      dio.interceptors.add(
        NetworkLoggerInterceptor(),
      );

      dio.httpClientAdapter = ChiliHttpClientAdapter(
        proxyUrl: prefs.getString(
          'proxyUrl',
        ),
      );
    }

    return dio;
  }
}

class ApiClient {
  final Dio _dio;

  const ApiClient({
    required Dio dio,
  }) : _dio = dio;

  void makeSimpleRequest(int articleId) =>
      _dio.get(_ApiEndpoints._articles(articleId));
}

class _ApiEndpoints {
  static _articles(id) => '/articles/$id';
}
