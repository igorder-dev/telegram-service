import 'dart:async';
import 'dart:isolate';

import 'package:id_mvc_app_framework/framework.dart';
import './iso/iso.dart';

export './iso/iso.dart';

import 'package:meta/meta.dart';

class IsoServiceRunner with GetxServiceMixin {
  static const TAG_PREFIX = "iso_service_tag";

  IsoServicePortal _isoPortal;
  IsoServicePortal get isoPortal {
    assert(_zone == IsoServiceZone.isolate,
        "Can be called only from isolate thread intsance of service");
    return _isoPortal;
  }

  IsoServiceZone _zone;
  IsoServiceZone get zone => _zone;

  Iso _iso;
  Iso get iso {
    assert(_zone == IsoServiceZone.main,
        "Can be called only from main thread intsance of service");
    return _iso;
  }

  IsoServiceRunner._(this._zone);

  final _dataInStream = StreamController<dynamic>.broadcast();

  static void initMainInstance(IsoOnData onError, String tag) =>
      Get.put<IsoServiceRunner>(
        IsoServiceRunner._(IsoServiceZone.main),
        tag: tag,
      );

  static void initIsoInstance(String tag) => Get.put<IsoServiceRunner>(
        IsoServiceRunner._(IsoServiceZone.isolate),
        tag: tag,
      );

  static IsoServiceRunner instance({String tag}) =>
      Get.find<IsoServiceRunner>(tag: tag);

  static Future<IsoServiceRunner> start(
    void Function(IsoServicePortal) runFunction, {
    IsoOnData onError,
    IsoOnData onData,
    List<dynamic> args = const <dynamic>[],
    String tag,
  }) async {
    assert(runFunction != null, "runFunction must not be null");
    initMainInstance(onError, tag);
    final runner = instance(tag: tag);

    runner._iso = Iso(runFunction, onError: onError);

    await runner.iso.run(
      tag: tag,
      args: args,
    );
    await runner.iso.onCanReceive;
    runner.iso.dataOut.listen((data) {
      if (data is RunnerStop) {
        stop(tag: data.tag);
        return;
      }
      runner._dataInStream.add(data);
    });
    return runner;
  }

  static void stop({String tag}) {
    final runner = instance(tag: tag);
    if (runner.zone == IsoServiceZone.main) {
      runner.iso.dispose();
    } else {
      send(RunnerStop(tag), tag: tag);
    }
    runner.dispose();
  }

  static void send(dynamic data, {String tag}) {
    final runner = instance(tag: tag);
    if (runner.zone == IsoServiceZone.main) {
      print("[Send from main] $data");
      runner.iso.send(data);
    } else {
      print("[Send from Isolate] $data");
      runner.isoPortal.send(data);
    }
  }

  static Stream<dynamic> dataIn({String tag}) {
    final runner = instance(tag: tag);
    return runner._dataInStream.stream;
  }

  static bool isInIsolateZone({String tag}) {
    final runner = instance(tag: tag);
    return runner.zone == IsoServiceZone.isolate;
  }

  void dispose() {
    _dataInStream.close();
  }
}

class RunnerStop {
  final String tag;

  RunnerStop(this.tag);
}

enum IsoServiceZone {
  main,
  isolate,
}

class IsoServicePortal {
  /// A [_chanOut] has to be provided
  IsoServicePortal(this._chanOut, {this.tag, this.args})
      : assert(_chanOut != null);

  /// The [SendPort] to send data into the isolate
  final SendPort _chanOut;

  /// The arguments for the run function
  List<dynamic> args;

  /// Does the run function has arguments
  bool get hasArgs => args.isNotEmpty;

  /// Send data to the main thread
  void send(dynamic data) => _chanOut.send(data);

  final String tag;

  /// Initialize the receive channel
  ///
  /// This must be done before sending messages into the isolate
  /// after this the [Iso.onCanReceive] future will be completed
  ReceivePort _receive() {
    final listener = ReceivePort();
    send(listener.sendPort);
    return listener;
  }

  void init() {
    IsoServiceRunner.initIsoInstance(tag);
    final runner = IsoServiceRunner.instance(tag: tag);

    runner._isoPortal = this;
    _receive().listen((data) {
      runner._dataInStream.add(data);
    });
  }
}
