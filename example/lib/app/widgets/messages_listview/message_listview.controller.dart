import 'package:flutter/material.dart';
import 'package:id_mvc_app_framework/framework.dart';
import 'package:telegram_service_example/app/model/channel_info.dart';
import 'package:telegram_service_example/app/model/channel_info_store.dart';
import 'package:telegram_service_example/app/model/message_info.dart';
import 'package:telegram_service_example/app/model/message_info_store.dart';
import 'package:telegram_service_example/utils/telegram/handlers/telegram_chats_handler.dart';

class TelegramMessagesListController extends MvcController {
  final int channelId;
  final messagesStore = TelegramChannelMessageInfoStore();
  final channelsStore = TelegramChannelInfoStore();

  List<TelegramChannelMessageInfo> get messages =>
      messagesStore.getMessagesByChannelId(channelId: channelId);
  int get messagesCount => messages?.length ?? 0;

  String getChannelTitleById(int channelId) {
    if (this.channelId != null) return "";
    TelegramChannelInfo channel = channelsStore[channelId];
    return (channel == null) ? "" : channel.title;
  }

  TelegramMessagesListController({@required this.channelId}) {}

  @override
  void onInit() {
    if (channelId != null) {
      TdlibChatsHandler.instance.getChatMessages(channelId);
    }

    debounce(
      messagesStore,
      (_) {
        update();
      },
      time: 1.seconds,
    );
  }
}
