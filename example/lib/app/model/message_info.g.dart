// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TelegramChannelMessageInfo _$TelegramChannelMessageInfoFromJson(
    Map<String, dynamic> json) {
  return TelegramChannelMessageInfo(
    json['id'] as int,
    json['channelId'] as int,
    json['content'] == null
        ? null
        : MessageContent.fromJson(json['content'] as Map<String, dynamic>),
    json['messageTimeStamp'] as int,
    json['viewsCount'] as int,
  );
}

Map<String, dynamic> _$TelegramChannelMessageInfoToJson(
        TelegramChannelMessageInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'channelId': instance.channelId,
      'content': instance.content.toJson(),
      'messageTimeStamp': instance.messageTimeStamp,
      'viewsCount': instance.viewsCount,
    };
