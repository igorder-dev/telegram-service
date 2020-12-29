import 'dart:async';

class AsyncLock {
  final Completer _completer = Completer();
  Future get lock => _completer.future;
  void release() {
    _completer.complete();
  }
}
