import 'package:tdlib/src/tdapi/tdapi.dart';
import 'package:tdlib/td_client.dart';
import 'package:telegram_service/src/tdclient/tdlcient.dart';

class MCTdClient extends TdClientInterface {
  int _clientId;
  static const double RECIEVE_TIMEOUT = 30; // seconds

  @override
  Future<bool> create() async {
    _clientId = await TdClient.createClient();
    return isActive;
  }

  @override
  Future<void> destroy() async {
    await TdClient.destroyClient(_clientId);
  }

  @override
  Stream<TdObject> get eventsStream => TdClient.clientEvents(_clientId);

  @override
  Future<TdObject> execute(TdFunction command) async =>
      await TdClient.clientExecute(_clientId, command);

  @override
  TdObject executeSync(TdFunction command) {
    TdObject _result;
    TdClient.clientExecute(_clientId, command).then((value) => _result = value);
    while (_result == null) {}
    return _result;
  }

  @override
  bool get isActive => !(_clientId == null || _clientId == 0);

  @override
  Future<TdObject> recieve([double timeout = RECIEVE_TIMEOUT]) async =>
      await TdClient.clientReceive(_clientId, timeout);

  @override
  Future<void> send(TdFunction command) async =>
      await TdClient.clientSend(_clientId, command);
}
