class TimeProvider {
  static String prettyDuration(Duration duration) {
    var seconds = duration.inMilliseconds / 1000;
    return '${seconds.toStringAsFixed(2)}s';
  }
}
