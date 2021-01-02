import 'package:tdlib/td_api.dart';
import 'package:telegram_service/src/service/telegram_event_handler.dart';
import 'package:telegram_service/src/service/telegram_service.dart';

///Telegram event handler that handles logout event.
///if TelegramService.onLogOut is null tries to restart TelegramService, otherwise call callback function
///
///Called when [UpdateAuthorizationState] event recieved
///
///Used internally by [TelegramService]
class AuthorizationClosedHandler extends TelegramEventHandler {
  final TelegramServiceLogoutCallback onLogOut;
  AuthorizationClosedHandler(this.onLogOut);

  @override
  List<String> get eventsToHandle => [UpdateAuthorizationState.CONSTRUCTOR];

  @override
  void onTelegramEvent(TdObject event, [String requestID]) {
    final _authState = event as UpdateAuthorizationState;
    switch (_authState.authorizationState.getConstructor()) {
      case AuthorizationStateClosed.CONSTRUCTOR:
        if (onLogOut == null)
          TelegramService.restart();
        else
          onLogOut();
        return;
    }
  }
}
