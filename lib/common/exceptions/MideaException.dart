

class MideaException implements Exception {
  final dynamic message;

  MideaException([this.message]);

  @override
  String toString() {
    Object? message = this.message;
    if (message == null) return "Exception";
    return "Exception: $message";
  }

}