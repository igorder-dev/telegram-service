import 'package:flutter/material.dart';
import 'package:id_mvc_app_framework/framework.dart';

import 'package:telegram_service_example/app/model/channel_info_store.dart';
import 'package:telegram_service_example/app/model/message_info.dart';
import 'package:telegram_service_example/app/model/message_info_store.dart';
import 'package:telegram_service_example/utils/telegram/handlers/telegram_chats_handler.dart';

class TelegramMessagesListController extends MvcController {
  final int channelId;
  final messagesStore = TelegramChannelMessageInfoStore();
  final channelsStore = TelegramChannelInfoStore();
  List<TelegramChannelMessageInfo> _messages = List();

  List<TelegramChannelMessageInfo> get messages => _messages;
  int get messagesCount => messages?.length ?? 0;

  TelegramMessagesListController({@required this.channelId});

  @override
  void onInit() {
    super.onInit();
    _messages = messagesStore.getMessagesByChannelIdX(channelId,
      TelegramMessageSortDirection.desc, 0, 10);
    if (channelId != null) {
      TdlibChatsHandler.instance.getChatMessages(channelId);
    }

    debounce(
      messagesStore,
      (_) {
        _messages = messagesStore.getMessagesByChannelIdX(channelId,
            TelegramMessageSortDirection.desc, 0, 10);
        update();
      },
      time: 1.seconds,
    );
  }
}
