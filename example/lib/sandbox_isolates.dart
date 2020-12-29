import 'dart:math';

import 'package:id_mvc_app_framework/framework.dart';
import 'package:iso/iso.dart';
import 'package:telegram_service/td_api.dart';
import 'package:telegram_service_example/app/model/channel_info_store.dart';

import 'app/model/channel_info.dart';

void main() async {
  final TestIsoRunner runner = TestIsoRunner();
  final iso = Iso(TestIsoRunner.run, onDataOut: null);
  final channelsStore = TelegramChannelInfoStore();
  iso.dataOut.listen((data) {
    if (data is TelegramChannelInfo) {
      print("Recieved from isolate ${data.toJson()}");
      print("store check ${channelsStore.values.length}");
    }
  });
  iso.run();
  await iso.onCanReceive;
  iso.send(channelsStore);
  iso.send(channelsStore);
  iso.send(channelsStore);
  iso.send(channelsStore);
  iso.send(channelsStore);
  iso.send(channelsStore);
  iso.send(channelsStore);
  iso.send(channelsStore);
  iso.send(channelsStore);
  iso.send(channelsStore);
}

typedef TelegramChannelInfo HandlerFunc(TelegramChannelInfoStore store);

class TestIsoRunner {
  static int runs = 0;

  static TelegramChannelInfo createChannelnfo(TelegramChannelInfoStore store) {
    final channelsStore = TelegramChannelInfoStore();
    int id = Random().nextInt(10000);
    channelsStore[id] =
        TelegramChannelInfo(id, "test channel $id", Rx(ChatPhotoInfo()));
    return channelsStore[id];
  }

  static Future<void> run(IsoRunner iso) async {
    iso.receive().listen((data) {
      if (data is TelegramChannelInfoStore) {
        print("Recieved from main $data");
        print("Runs number ${runs++}");
        iso.send(createChannelnfo(data));
      }
    });
  }
}
