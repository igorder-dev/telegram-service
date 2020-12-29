import 'dart:async';

import 'package:id_mvc_app_framework/framework.dart';
import 'package:iso/iso.dart';

class IsoServiceRunner with GetxServiceMixin {
  IsoRunner _isoRunner;
  IsoRunner get isoRunner {
    assert(_zone == IsoServiceZone.isolate,
        "Can be called only from isolate thread intsance of service");
    return _isoRunner;
  }

  IsoServiceZone _zone;
  IsoServiceZone get zone => _zone;

  Iso _iso;
  Iso get iso {
    assert(_zone == IsoServiceZone.main,
        "Can be called only from main thread intsance of service");
    return _iso;
  }

  static Future<void> Function(IsoRunner) runFunction;
  IsoOnData onDataOut;
  IsoOnData onError;

  IsoServiceRunner._(this.onError, this._zone);

  final _dataInStream = StreamController<dynamic>.broadcast();

  static void _initMainInstance(IsoOnData onError) =>
      Get.put(IsoServiceRunner._(onError, IsoServiceZone.main));

  static void _initIsoInstance() =>
      Get.put(IsoServiceRunner._(null, IsoServiceZone.isolate));

  static IsoServiceRunner get instance => Get.find();

  static Future<IsoServiceRunner> start(
    Future<void> Function(IsoRunner) runFunction, {
    IsoOnData onError,
    IsoOnData onData,
    List<dynamic> args = const <dynamic>[],
  }) async {
    assert(runFunction != null, "runFunction must not be null");
    _initMainInstance(onError);
    instance._iso = Iso(_run, onDataOut: onData, onError: onError);

    await instance.iso.run(args);
    await instance.iso.onCanReceive;
    return instance;
  }

  //entry point to isolate
  static Future<void> _run(IsoRunner isoRunner) async {
    _initIsoInstance();
    instance._isoRunner = isoRunner;
    isoRunner.receive();
    await runFunction?.call(isoRunner);
  }

  static void stop() {
    final runner = instance;
    if (runner.zone == IsoServiceZone.main) {
      runner._dataInStream.close();
    } else {}
    runner.dispose();
  }

  static void send(dynamic data) {
    final runner = instance;
    if (runner.zone == IsoServiceZone.main) {
      runner.iso.send(data);
    } else {
      runner.isoRunner.send(data);
    }
  }

  Stream<dynamic> get dataIn {
    final runner = instance;
    if (runner.zone == IsoServiceZone.main) {
      return runner.iso.dataOut;
    } else {
      return runner.dataIn;
    }
  }

  void dispose() {
    _dataInStream.close();
  }
}

class RunnerStop {}

enum IsoServiceZone {
  main,
  isolate,
}
