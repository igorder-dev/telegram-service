import 'package:id_mvc_app_framework/model.dart';
import 'package:tdlib/td_api.dart';
import 'package:telegram_service/src/service/telegram_service.dart';

/// Abstract class that can be registered in [TelegramService.start] for specific event types
/// - [eventsToHandle] - List describing list of eventTypes to handle
/// - [onTelegramEvent] - callback function called everytime when message of eventType sent by TdLib
///
/// Example:
/// TelegramService.start( eventHandlers: [Get.put<TdlibLoginHandler>(TdlibLoginHandler()), ],)
///
abstract class TelegramEventHandler with ModelStateProvider {
  /// List describing list of eventTypes to handle
  List<String> get eventsToHandle;

  /// Callback function called everytime when message of eventType sent by TdLib
  /// [event] - TdLib object of one of eventTypes listed in  [eventsToHandle]. Can be [TdError] or [OK] if function called as callback to specific command.
  /// See [this.sendCommand] for reference
  void onTelegramEvent(TdObject event, [String requestID]);

  /// Sends [command] to TdLib plugin for execution. Can't be null
  ///
  /// Returns generated unique callback identifier
  ///
  ///  - [customCallback] - callback function for handling response from TdLib plugin
  ///  - [onError] - custom callback for handling error if returned tdLib or raised during command execution
  ///  - [withCallBack] - lets TegramService know if reponse to the command should be passed to specific callback. By default False.
  ///    If [customCallback] is Null will call onTelegramEvent as callback function
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
