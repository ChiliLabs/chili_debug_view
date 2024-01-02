## Overview

This package allows to see network and console logs from mobile device. 
This can help QA engineers to better debug your app features

## Usage

1. Wrap your app via DebugView providing navigation key

```dart
import 'package:chili_debug_view/chili_debug_view.dart';

...
DebugView(
  navigatorKey: rootNavigationKey,
  showDebugViewButton: true,
  app: MaterialApp()
);
...
```

2. To see network logs you need to add interceptor

```dart
import 'package:chili_debug_view/chili_debug_view.dart';

dio.interceptors.add(NetworkLoggerInterceptor());
```
