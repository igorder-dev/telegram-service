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
    const RxMessageContentSerializer()
        .fromJson(json['messageContentRx'] as Map<String, dynamic>),
    json['messageTimeStamp'] as int,
    json['viewsCount'] as int,
  )..content = json['content'] == null
      ? null
      : MessageContent.fromJson(json['content'] as Map<String, dynamic>);
}

Map<String, dynamic> _$TelegramChannelMessageInfoToJson(
        TelegramChannelMessageInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'channelId': instance.channelId,
      'messageTimeStamp': instance.messageTimeStamp,
      'viewsCount': instance.viewsCount,
      'messageContentRx':
          const RxMessageContentSerializer().toJson(instance.messageContentRx),
      'content': instance.content,
    };
