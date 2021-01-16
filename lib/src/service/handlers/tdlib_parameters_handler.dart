import 'package:tdlib/td_api.dart';

import '../telegram_event_handler.dart';
import '../telegram_service.dart';

///Telegram event handler that sends [TdlibParameters] object required by TdLib plugin for initialization
///Called when [UpdateAuthorizationState] event recieved
///
///Used internally by [TelegramService]
class TdlibParametersHandler extends TelegramEventHandler {
  final TdlibParameters parameters;
  final TelegramErrorCallback onError;
  String requestID;

  TdlibParametersHandler(this.parameters, this.onError);

  @override
  List<String> get eventsToHandle => [UpdateAuthorizationState.CONSTRUCTOR];

  @override
  void onTelegramEvent(TdObject event, [String requestID]) {
    final _authState = event as UpdateAuthorizationState;
    switch (_authState.authorizationState.getConstructor()) {
      case AuthorizationStateWaitTdlibParameters.CONSTRUCTOR:
        sendCommand(
          SetTdlibParameters(
            parameters: parameters,
          ),
          onError: onError,
          withCallBack: true,
          customCallback: (event, [requestID]) async {
            TelegramService.log(
                'SetTdlibParameters [$requestID] command received reply [${event.getConstructor()}]');
            if (event is Ok) {
              TelegramService.instance.clientConfigured = true;
            } else {
              if (event is TdError &&
                  event.code == 400 &&
                  event.message.contains("td.binlog")) {
                await TelegramService.instance.tdClient.destroyPrevInstance();
              }
              TelegramService.restart();
            }
          },
        );
        return;
    }
  }
}
