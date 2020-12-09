import 'dart:async';

import 'package:id_mvc_app_framework/framework.dart';
import 'package:telegram_service_example/app/model/channel_info.dart';
import 'package:telegram_service_example/app/model/channel_info_store.dart';
import 'package:telegram_service_example/app/screens/messages_screen.dart';

import 'package:telegram_service_example/utils/telegram/handlers/telegram_chats_handler.dart';

class MainScreenController extends MvcController {
  final channelsStore = TelegramChannelInfoStore();

  List<TelegramChannelInfo> get channels => channelsStore.values.toList();
  int get channelsCount => channelsStore?.values?.length ?? 0;
  int _lastChannelsCount = 0;

  void showChannelMessages(TelegramChannelInfo channelInfo) {
    Get.to(TelegramMessagesScreen(
      channelId: channelInfo.id,
      title: channelInfo.title,
    ));
  }

  void onGetChatsPressed() {
    Get.to(TelegramMessagesScreen());
  }

  void loadChats() {
    TdlibChatsHandler.instance.getAllChats();
    Timer.periodic(1.seconds, (timer) {
      if (_lastChannelsCount == channelsStore.length) {
        timer.cancel();
        return;
      }
      TdlibChatsHandler.instance.getAllChats();
      _lastChannelsCount = channelsStore.length;
    });
  }

  @override
  void onInit() {
    super.onInit();
    loadChats();
  }

  @override
  void onReady() {
    super.onReady();
    debounce(
      channelsStore,
      (_) {
        update();
      },
      time: 1.seconds,
    );
  }
}
