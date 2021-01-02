import 'package:flutter/material.dart';
import 'package:id_mvc_app_framework/framework.dart';
import 'package:id_mvc_app_framework/utils/command/MvcCommand.dart';

import 'package:telegram_service_example/app/model/message_info.dart';
import 'package:telegram_service_example/app/model/message_info_store.dart';

import 'load_messages_command.dart';

class TelegramMessagesListController extends MvcController {
  final int channelId;

  final messagesStore = TelegramChannelMessageInfoStore();
  MvcCommand loadCommand;

  List<TelegramChannelMessageInfo> _messages = List();

  List<TelegramChannelMessageInfo> get messages => _messages;
  int get messagesCount => messages?.length ?? 0;

  TelegramMessagesListController({@required this.channelId});

  @override
  void onInit() {
    super.onInit();

    loadCommand = LoadMessagesCmd.cmd(channelId);

    debounce(
      messagesStore,
      (_) {
        _messages = messagesStore.getMessagesByChannelId(channelId: channelId);
        update();
      },
      time: 2.seconds,
    );
  }

  @override
  void onReady() {
    loadCommand.execute();
    _messages = messagesStore.getMessagesByChannelId(channelId: channelId);
    super.onReady();
  }

  @override
  void dispose() {
    loadCommand.dispose();
    super.dispose();
  }
}
