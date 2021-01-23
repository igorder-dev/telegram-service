import 'dart:async';

import 'package:telegram_service/src/tdclient/tdlcient.dart';
import 'package:telegram_service/tdapi.dart';
import 'package:id_mvc_app_framework/framework.dart';

import 'ffi/ffi_td_json_client.dart';

class FFITdClient extends TdClientInterface {
  JsonClient _client; // clinet instance which does inital FFI mapping

  /// default recieve comand time out
  static const double RECIEVE_TIMEOUT = 10;

  @override
  Future<bool> create() async {
    _client = await JsonClient.create("");
    return isActive;
  }

  @override
  Future<void> destroy() async {
    await _client.destroy();
  }

  @override
  Stream<TdObject> get eventsStream async* {
    while (isActive) {
      var obj = await recieve(0.0);
      if (obj != null) yield obj;
    }
  }

  @override
  Future<TdObject> execute(TdFunction command) async => await Get.asap(() {
        return convertToObject(_client.execute(command.toJson()));
      });

  @override
  TdObject executeSync(TdFunction command) {
    return convertToObject(_client.execute(command.toJson()));
  }

  @override
  bool get isActive => _client?.active ?? false;

  @override
  Future<TdObject> recieve([double timeout = RECIEVE_TIMEOUT]) async =>
      Get.asap(() => convertToObject(_client.receive(timeout)));

  @override
  Future<void> send(TdFunction command) async =>
      await Get.asap(() => _client.send(command.toJson()));

  @override
  Future<void> destroyPrevInstance() async {
    await _client.destroySaved();
  }
}
