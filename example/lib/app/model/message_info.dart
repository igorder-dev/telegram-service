import 'package:telegram_service/td_api.dart';
import 'package:time_formatter/time_formatter.dart';

import 'channel_info.dart';
import 'channel_info_store.dart';

class TelegramChannelMessageInfo {
  final int id;
  final int channelId;
  final MessageContent content;
  final int messageTimeStamp;
  final int viewsCount;

  TelegramChannelMessageInfo.fromMessage(Message message)
      : id = message.id,
        channelId = message.chatId,
        content = message.content,
        messageTimeStamp = message.date,
        viewsCount = message.views;

  String get messageTimeFormatted {
    return formatTime(messageTimeStamp * 1000);
  }

  String get contentType => content.getConstructor();

  TelegramChannelInfo get channel {
    final channelsStore = TelegramChannelInfoStore();
    // TODO : Implement chatInfo loading from telegram service if it is not found in the store
    return channelsStore[channelId];
  }
}
