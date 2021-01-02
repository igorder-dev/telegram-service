import 'package:telegram_service/tdapi.dart';

abstract class TdClientInterface {
  Future<bool> create();
  Future<void> destroy();
  Future<void> send(TdFunction command);
  Future<TdObject> execute(TdFunction command);
  TdObject executeSync(TdFunction command);
  Future<TdObject> recieve([double timeout]);
  bool get isActive;
  Stream<TdObject> get eventsStream;
}
