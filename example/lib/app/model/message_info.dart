import 'package:telegram_service/tdapi.dart';
import 'package:time_formatter/time_formatter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'channel_info.dart';
import 'channel_info_store.dart';

import 'package:id_mvc_app_framework/framework.dart';

part 'message_info.g.dart';

@JsonSerializable()
class TelegramChannelMessageInfo {
  final int id;
  final int channelId;

  final int messageTimeStamp;
  final int viewsCount;

  @RxMessageContentSerializer()
  final Rx<MessageContent> messageContentRx;

  MessageContent get content => messageContentRx.value;
  set content(MessageContent value) => messageContentRx.value = value;

  TelegramChannelMessageInfo.fromMessage(Message message)
      : id = message.id,
        channelId = message.chatId,
        messageTimeStamp = message.date,
        //
        viewsCount = 0,
        messageContentRx = message.content.obs;

  String get messageTimeFormatted {
    return formatTime(messageTimeStamp * 1000);
  }

  String get contentType => content.getConstructor();

  TelegramChannelInfo get channel {
    final channelsStore = TelegramChannelInfoStore();
    // TODO : Implement chatInfo loading from telegram service if it is not found in the store
    return channelsStore[channelId];
  }

  // Default constructor for serialization purposes
  TelegramChannelMessageInfo(this.id, this.channelId, this.messageContentRx,
      this.messageTimeStamp, this.viewsCount);

  // JSON serialization/deserialization
  factory TelegramChannelMessageInfo.fromJson(Map<String, dynamic> json) =>
      _$TelegramChannelMessageInfoFromJson(json);

  Map<String, dynamic> toJson() => _$TelegramChannelMessageInfoToJson(this);
}

class RxMessageContentSerializer
    implements JsonConverter<Rx<MessageContent>, Map<String, dynamic>> {
  const RxMessageContentSerializer();

  @override
  Rx<MessageContent> fromJson(Map<String, dynamic> json) =>
      Rx(MessageContent.fromJson(json));

  @override
  Map<String, dynamic> toJson(Rx<MessageContent> messageContent) =>
      messageContent.toJson();
}
