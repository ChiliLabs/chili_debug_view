enum NetworkLoggerLogType { request, response, error }

extension NetworkLoggerLogTypeFiltering on NetworkLoggerLogType {
  bool containsLevel(Set<NetworkLoggerLogType> types) {
    if (types.isEmpty) return true;

    return types.contains(this);
  }
}
