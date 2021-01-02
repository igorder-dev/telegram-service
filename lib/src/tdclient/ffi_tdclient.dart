import 'dart:async';

import 'package:telegram_service/src/tdclient/tdlcient.dart';
import 'package:telegram_service/tdapi.dart';
import 'package:id_mvc_app_framework/framework.dart';

import 'ffi/ffi_td_json_client.dart';

class FFITdClient extends TdClientInterface {
  JsonClient _client; // clinet instance which does inital FFI mapping

  /// default recieve comand time out
  static const double RECIEVE_TIMEOUT = 20;

  /// maximum number of empty [recieve] event before cycle swithes to loose frequirency
  static const int NULLS_LIMITS = 100;

  /// Frequency in milliseconds when events loop is in frequent call mode
  static const double FREQ_RECIVIE_INTERVAL = 1;

  /// Frequency in millescands when event loop is in loose call mode
  static const double LOOSE_RECIVIE_INTERVAL = 5000;

  double _recieveInterval = FREQ_RECIVIE_INTERVAL;
  int _nullCounter = 0;

  void _resetReciveInterval() {
    _recieveInterval = FREQ_RECIVIE_INTERVAL;
    _nullCounter = 0;
  }

  @override
  Future<bool> create() async {
    _client = JsonClient.create("");
    return isActive;
  }

  @override
  Future<void> destroy() async {
    _client.destroy();
  }

  @override
  Stream<TdObject> get eventsStream async* {
    while (isActive) {
      //calling recieve function in Future with defined delay -> made to avoid blocking UI isolate events loop
      var obj = await Future.delayed(
        _recieveInterval.milliseconds,
        () async => await recieve(0.0),
      );
      // print(obj);
      // if recieve returns nothing skip event processing an update empy results counters
      if (obj == null) {
        _nullCounter++;
        //If counter exceeds number of repetative empty inputs switch events loop to loos frequence
        _recieveInterval = _nullCounter > NULLS_LIMITS
            ? LOOSE_RECIVIE_INTERVAL
            : FREQ_RECIVIE_INTERVAL;
      } else {
        //if actual object recieved reset empty results counter and event loop interval + send object to the stream
        _resetReciveInterval();
        yield obj;
      }
    }
  }

  @override
  Future<TdObject> execute(TdFunction command) async =>
      await Future.delayed(1.milliseconds, () {
        _resetReciveInterval();
        return convertToObject(_client.execute(command.toJson()));
      });

  @override
  TdObject executeSync(TdFunction command) {
    _resetReciveInterval();
    return convertToObject(_client.execute(command.toJson()));
  }

  @override
  bool get isActive => _client?.active ?? false;

  @override
  Future<TdObject> recieve([double timeout = RECIEVE_TIMEOUT]) async =>
      convertToObject(_client.receive(timeout));

  @override
  Future<void> send(TdFunction command) async =>
      await Future.delayed(1.milliseconds, () {
        _resetReciveInterval();
        _client.send(command.toJson());
      });
}
