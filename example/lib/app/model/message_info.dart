import 'package:telegram_service/td_api.dart';

class TelegramChannelMessageInfo {
  final int id;
  final int channelId;
  final MessageContent content;
  TelegramChannelMessageInfo.fromMessage(Message message)
      : id = message.id,
        channelId = message.chatId,
        content = message.content;
}
