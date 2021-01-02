import 'dart:async';
import "dart:isolate";

import '../iso_service_runner.dart';

/// Data processing function type
typedef IsoOnData = void Function(dynamic data);

/// The isolate runner class
class Iso {
  /// If [onDataOut] is not provided the data coming from the isolate
  /// will print to the screen by default
  Iso(this.runFunction, {this.onError})
      : _fromIsolateReceivePort = ReceivePort(),
        _fromIsolateErrorPort = ReceivePort() {
    onError ??=
        (dynamic err) => throw IsolateRuntimeError("Error in isolate:\n $err");
  }

  /// The function to run in the isolate
  final void Function(IsoServicePortal) runFunction;

  /// The handler for the errors coming from the isolate
  IsoOnData onError;

  Isolate _isolate;
  final ReceivePort _fromIsolateReceivePort;
  final ReceivePort _fromIsolateErrorPort;
  SendPort _toIsolateSendPort;
  final StreamController<dynamic> _dataOutIsolate = StreamController<dynamic>();
  final Completer _isolateReadyToListenCompleter = Completer<void>();
  bool _canReceive = false;

  /// A stream with the data coming out from the isolate
  Stream<dynamic> get dataOut => _dataOutIsolate.stream;

  /// Working state callback
  Future get onCanReceive => _isolateReadyToListenCompleter.future;

  /// The state of the isolate
  bool get canReceive => _canReceive;

  /// Send data to the isolate
  void send(dynamic data) {
    assert(_toIsolateSendPort != null);
    _toIsolateSendPort.send(data);
  }

  /// Run the isolate
  Future<void> run({
    List<dynamic> args = const <dynamic>[],
    String tag,
  }) async {
    //print("I > run");
    final _comChanCompleter = Completer<void>();
    // set runner config
    final portal = IsoServicePortal(
      _fromIsolateReceivePort.sendPort,
      tag: tag,
      args: args,
    );

    // run
    await Isolate.spawn<IsoServicePortal>(runFunction, portal,
            onError: _fromIsolateErrorPort.sendPort)
        .then((Isolate _is) {
      _isolate = _is;
      _fromIsolateReceivePort.listen((dynamic data) {
        if (_toIsolateSendPort == null && data is SendPort) {
          _toIsolateSendPort = data;
          //print("I > com port received $data");
          _comChanCompleter.complete();
        } else {
          //print("I > DATA OUT $data");
          _dataOutIsolate.sink.add(data);
        }
      }, onError: (dynamic err) {
        _fromIsolateErrorPort.sendPort.send(err);
      });
      _fromIsolateErrorPort.listen((dynamic err) {
        onError(err);
      });
      //print("I > init data in");
      //runner.initDataIn();
      return;
    });
    await _comChanCompleter.future;
    _isolateReadyToListenCompleter.complete();
    _canReceive = true;
  }

  /// Kill the isolate
  void _kill() {
    //print("Killing $_isolate");
    if (_isolate != null) {
      _fromIsolateReceivePort.close();
      _fromIsolateErrorPort.close();
      _isolate.kill(priority: Isolate.immediate);
      _isolate = null;
    }
  }

  /// Cleanup
  void dispose() {
    _kill();
    _dataOutIsolate.close();
  }
}

/// An exception for code running in an isolate
class IsolateRuntimeError implements Exception {
  /// Provide a message
  IsolateRuntimeError(this.message);

  /// The error message
  final String message;
}
