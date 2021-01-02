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
          customCallback: (event, [requestID]) {
            TelegramService.log(
                'SetTdlibParameters [$requestID] command received reply [${event.getConstructor()}]');
          },
        );
        return;
    }
  }
}
