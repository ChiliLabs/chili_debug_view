# Changelog

## 2.0.0

- **Breaking:** Minimum supported Dart SDK is 3.13.0 and Flutter is 3.47.0. On older Flutter versions use 1.4.x
- Migrated from `package:flutter/material.dart` to `package:material_ui` and `package:cupertino_ui`
- Debug screens work in apps on either `package:material_ui` or `package:flutter/material.dart`
- Requires `share_plus` 13.3.1+, `dio` 5.11.1+ and `path_provider` 2.1.6+
- Replaced deprecated `cacheExtent` with `scrollCacheExtent` in log details screen

## 1.4.0

- Support `share_plus` 13.x (12.x still supported)
- Minimum supported Dart SDK is 3.4.0 and Flutter is 3.22.0
- Fixed overflow and text compressing in network logs list item header

## 1.3.2
- Show error response of `List<int>` endpoints as a JSON instead of `List<int>`

## 1.3.1

- Non-JSON responses/requests are now properly displayed in log details screen
- Added pretty formatting for error response headers

## 1.3.0

- Redesigned log details screen
- Small UI improvements & fixes
- Update packages to latest:
    - dio

## 1.2.0

- Add possibility to add proxy address
- Update packages to latest:
    - dio
    - share_plus

## 1.1.0

- Update packages to latest:
  - share_plus
  - dio
  - path_provider

## 1.0.0

- Initial version