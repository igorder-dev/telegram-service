import 'package:id_mvc_app_framework/framework.dart';
import 'package:id_mvc_app_framework/model.dart';
import 'package:telegram_service/src/service/telegram_service.dart';
import 'package:telegram_service/src/tdapi/tdapi.dart';

abstract class TelegramEventHandler with ModelStateProvider {
  List<String> get eventsToHandle;
  void onTelegramEvent(TdObject event, [String requestID]);

  ///Sends command to Telegram service and assigns callback function to get result in the handler
  ///returns unique command id that can be used for later matching
  Future<dynamic> sendCommand(
    TdFunction command, {
    TelegramErrorCallback onError,
    bool withCallBack = false,
    TelegramEventCallback customCallback,
  }) async {
    final _instance = TelegramService.instance;

    return await _instance.sendCommand(
      command,
      callback: withCallBack ? (customCallback ?? onTelegramEvent) : null,
      onError: onError,
    );
  }
}
