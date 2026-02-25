import 'dart:convert';

final class JsonUtils {
  static bool isJson(String data) {
    try {
      final decoded = jsonDecode(data);
      return decoded is Map || decoded is List;
    } catch (e) {
      return false;
    }
  }
}
