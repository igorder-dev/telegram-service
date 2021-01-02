import 'package:tdlib/td_api.dart';

import '../telegram_event_handler.dart';
import '../telegram_service.dart';

///Telegram event handler that sends [CheckDatabaseEncryptionKey]
///or  [SetDatabaseEncryptionKey] command required by TdLib plugin for initialization
///
///Called when [UpdateAuthorizationState] event recieved
///
///Used internally by [TelegramService]
class EncryptionKeyHandler extends TelegramEventHandler {
  final String encryptionKey;
  EncryptionKeyHandler(this.encryptionKey);

  @override
  List<String> get eventsToHandle => [UpdateAuthorizationState.CONSTRUCTOR];

  void eventResponseHandler(TdObject event, [String requestID]) {
    TelegramService.log(
        '[$requestID] command received reply [${event.getConstructor()}]');
    if (event.getConstructor() == TdError.CONSTRUCTOR) {
      final error = event as TdError;
      TelegramService.log(
          "[$requestID] returned error code [${error.code}] with message [${error.message}].");
    }
  }

  @override
  void onTelegramEvent(TdObject event, [String requestID]) async {
    final _authState = event as UpdateAuthorizationState;
    switch (_authState.authorizationState.getConstructor()) {
      case AuthorizationStateWaitEncryptionKey.CONSTRUCTOR:
        bool _isEncrypted = (_authState.authorizationState
                as AuthorizationStateWaitEncryptionKey)
            .isEncrypted;

        await sendCommand(
          _isEncrypted
              ? CheckDatabaseEncryptionKey(
                  encryptionKey: encryptionKey,
                )
              : SetDatabaseEncryptionKey(
                  newEncryptionKey: encryptionKey,
                ),
          withCallBack: true,
          customCallback: eventResponseHandler,
        );

        return;
    }
  }
}
